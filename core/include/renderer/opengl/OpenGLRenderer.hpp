#pragma once

#include <string>
#include <vector>
#include <iostream>

#include <GL/glew.h>
#include <GLFW/glfw3.h>

#include "renderer/Renderer.hpp"

class OpenGLRenderer : public IRenderer {
public:
    OpenGLRenderer(int width, int height);
    ~OpenGLRenderer() override;

    bool initialize(int width, int height) override;

    void updateShader(const std::string& fragmentShaderCode) override;

    bool loadUserTexture(const std::string& filepath);
    
    void render() override;
    
    const uint8_t* getPixels() const override { return _pixelBuffer.data(); }

    int getWidth() const { return _width; }
    int getHeight() const { return _height; }

private:
    void setupQuad();
    void setupSphere();

    GLuint compileShader(GLenum type, const std::string& source);

private:
    GLFWwindow* _window{nullptr};

    GLuint _shaderProgram{0};
    GLuint _framebuffer{0};
    GLuint _texture{0};
    GLuint _vao{0};
    GLuint _vbo{0};
    GLuint _rbo{0};

    int _width{0};
    int _height{0};

    std::vector<uint8_t> _pixelBuffer;

    GLuint sphereVAO{0};
    GLuint sphereVBO{0};
    GLuint sphereEBO{0};
    int sphereIndexCount{0};

    GLuint _userTexture{0};
};

