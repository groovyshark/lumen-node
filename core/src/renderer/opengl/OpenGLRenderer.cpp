#include "renderer/opengl/OpenGLRenderer.hpp"

#include <format>

namespace {
    const char* vertexShaderSource = R"(
        #version 330 core
        layout(location = 0) in vec2 aPos;
        out vec2 vUV;
        void main() {
            vUV = (aPos + 1.0) * 0.5;
            gl_Position = vec4(aPos, 0.0, 1.0);
        }
    )";

    const float quadVertices[] = {
        -1.0f,  1.0f,
        -1.0f, -1.0f,
         1.0f, -1.0f,
        -1.0f,  1.0f,
         1.0f, -1.0f,
         1.0f,  1.0f 
    };
}

OpenGLRenderer::OpenGLRenderer(int width, int height)
    : _width(width), _height(height)
{
    initialize(width, height);
}

OpenGLRenderer::~OpenGLRenderer() {
    glDeleteProgram(_shaderProgram);
    glDeleteFramebuffers(1, &_framebuffer);
    glDeleteTextures(1, &_texture);
    glDeleteVertexArrays(1, &_vao);
    glDeleteBuffers(1, &_vbo);
    if (_window) {
        glfwDestroyWindow(_window);
        glfwTerminate();
    }
}

bool OpenGLRenderer::initialize(int width, int height) {
    if (!glfwInit()) {
        std::cerr << "Failed to initialize GLFW" << std::endl;
        return false;
    }

    glfwWindowHint(GLFW_VISIBLE, GLFW_FALSE);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    _window = glfwCreateWindow(width, height, "OpenGL Renderer", nullptr, nullptr);
    if (!_window) {
        std::cerr << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return false;
    }
    glfwMakeContextCurrent(_window);

    glewExperimental = GL_TRUE;
    if (glewInit() != GLEW_OK) {
        std::cerr << "Failed to initialize GLEW" << std::endl;
        return false;
    }

    glGenFramebuffers(1, &_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);

    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, nullptr);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _texture, 0);

    setupQuad();
    _pixelBuffer.resize(width * height * 4); // RGBA

    return true;
}

void OpenGLRenderer::setupQuad() {
    glGenVertexArrays(1, &_vao);
    glGenBuffers(1, &_vbo);

    glBindVertexArray(_vao);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(quadVertices), &quadVertices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(float), (void*)0);
}

void OpenGLRenderer::updateShader(const std::string& fragmentShaderCode) {
    std::string fullSource = std::format(
        "#version 330 core\n"
        "out vec4 FragColor;\n"
        "in vec2 uv;\n"
        "{}\n"
        "void main() {{ mainImage(FragColor, uv); }}\n", 
        fragmentShaderCode
    );

    GLuint vs = compileShader(GL_VERTEX_SHADER, vertexShaderSource);
    GLuint fs = compileShader(GL_FRAGMENT_SHADER, fullSource);

    if (_shaderProgram) {
        glDeleteProgram(_shaderProgram);
    }

    _shaderProgram = glCreateProgram();
    glAttachShader(_shaderProgram, vs);
    glAttachShader(_shaderProgram, fs);
    glLinkProgram(_shaderProgram);
    
    glDeleteShader(vs);
    glDeleteShader(fs);
}

void OpenGLRenderer::render() {
    glfwMakeContextCurrent(_window);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glViewport(0, 0, _width, _height);

    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    glUseProgram(_shaderProgram);
    glBindVertexArray(_vao);
    glDrawArrays(GL_TRIANGLES, 0, 6);

    glReadPixels(0, 0, _width, _height, GL_RGBA, GL_UNSIGNED_BYTE, _pixelBuffer.data());
}

GLuint OpenGLRenderer::compileShader(GLenum type, const std::string& source) {
    GLuint shader = glCreateShader(type);

    const char* src = source.c_str();
    glShaderSource(shader, 1, &src, nullptr);
    glCompileShader(shader);

    GLint success;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    if (!success) {
        char infoLog[512];
        glGetShaderInfoLog(shader, 512, nullptr, infoLog);
        std::cerr << "OpenGLRenderer::compileShader: Shader compilation error: " << infoLog << std::endl;
    }

    return shader;
}