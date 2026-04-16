#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"
#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <flutter/texture_registrar.h>
// #include <flutter/pixel_buffer_texture.h>

#include "../../../core/include/renderer/opengl/OpenGLRenderer.hpp"

std::unique_ptr<OpenGLRenderer> glRenderer;
int64_t glTextureId = -1;

std::unique_ptr<flutter::PluginRegistrarWindows> gPluginRegistrar;

std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> gChannel;

std::unique_ptr<flutter::TextureVariant> gTexture;

FlutterWindow::FlutterWindow(const flutter::DartProject &project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
    if (!Win32Window::OnCreate()) {
        return false;
    }

    RECT frame = GetClientArea();

    // The size here must match the window dimensions to avoid unnecessary surface
    // creation / destruction in the startup path.
    flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
        frame.right - frame.left, frame.bottom - frame.top, project_);
    // Ensure that basic setup of the controller was successful.
    if (!flutter_controller_->engine() || !flutter_controller_->view()) {
        return false;
    }
    RegisterPlugins(flutter_controller_->engine());
    SetChildContent(flutter_controller_->view()->GetNativeWindow());

    flutter_controller_->engine()->SetNextFrameCallback([&]() {
        this->Show();
    });

    // Flutter can complete the first frame before the "show window" callback is
    // registered. The following call ensures a frame is pending to ensure the
    // window is shown. It is a no-op if the first frame hasn't completed yet.
    flutter_controller_->ForceRedraw();

    glRenderer = std::make_unique<OpenGLRenderer>(512, 512);

    auto registrar_ref = flutter_controller_->engine()->GetRegistrarForPlugin("LumenRenderer");

    gPluginRegistrar = std::make_unique<flutter::PluginRegistrarWindows>(registrar_ref);
    flutter::TextureRegistrar *registrar = gPluginRegistrar->texture_registrar();

    gTexture = std::make_unique<flutter::TextureVariant>(
        flutter::PixelBufferTexture([](size_t width, size_t height) -> const FlutterDesktopPixelBuffer * {
            static FlutterDesktopPixelBuffer buffer = {};

            if (glRenderer) {
                // glRenderer->render();

                buffer.buffer = glRenderer->getPixels();
                buffer.width = glRenderer->getWidth();
                buffer.height = glRenderer->getHeight();
            }
            return &buffer;
        }));

    glTextureId = registrar->RegisterTexture(gTexture.get());

    gChannel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
        flutter_controller_->engine()->messenger(), "lumen/renderer",
        &flutter::StandardMethodCodec::GetInstance());

    gChannel->SetMethodCallHandler(
        [registrar](const flutter::MethodCall<flutter::EncodableValue> &call,
                    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
            
            const auto& method = call.method_name();
            
            if (method == "getTextureId") {
                result->Success(flutter::EncodableValue(glTextureId));
            } else if (method == "requestFrame") {
                double currentTime = glfwGetTime();

                if (glRenderer) {
                    glRenderer->render();
                    
                    registrar->MarkTextureFrameAvailable(glTextureId);
                }
                result->Success(flutter::EncodableValue(currentTime));
            } else if (method == "updateShader") {
                const auto *args = std::get_if<flutter::EncodableMap>(call.arguments());
                if (args) {
                    auto it = args->find(flutter::EncodableValue("code"));
                    if (it != args->end() && std::holds_alternative<std::string>(it->second)) {

                        std::string shaderCode = std::get<std::string>(it->second);

                        if (glRenderer) {
                            glRenderer->updateShader(shaderCode);

                            glRenderer->render();

                            registrar->MarkTextureFrameAvailable(glTextureId);
                        }

                        result->Success();
                        return;
                    }
                }
                result->Error("BAD_ARGS", "Expected string argument 'code'");
            } else if (method == "loadTexture") {
                const auto *args = std::get_if<flutter::EncodableMap>(call.arguments());
                if (args) {
                    auto it = args->find(flutter::EncodableValue("path"));
                    if (it != args->end() && std::holds_alternative<std::string>(it->second)) {
                        std::string texturePath = std::get<std::string>(it->second);

                        if (glRenderer) {
                            glRenderer->loadUserTexture(texturePath);
                            glRenderer->render();

                            registrar->MarkTextureFrameAvailable(glTextureId);
                        }
                        
                        result->Success();
                        return;
                    }
                }
                result->Error("BAD_ARGS", "Expected string argument 'path'");

            } else {
                result->NotImplemented();
            }
        });

    return true;
}

void FlutterWindow::OnDestroy() {
    if (flutter_controller_) {
        flutter_controller_ = nullptr;
    }

    Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
    // Give Flutter, including plugins, an opportunity to handle window messages.
    if (flutter_controller_) {
        std::optional<LRESULT> result =
            flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                          lparam);
        if (result) {
            return *result;
        }
    }

    switch (message) {
    case WM_FONTCHANGE:
        flutter_controller_->engine()->ReloadSystemFonts();
        break;
    }

    return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
