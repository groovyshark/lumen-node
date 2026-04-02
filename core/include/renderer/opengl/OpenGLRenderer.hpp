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
    
    void render() override;
    
    const uint8_t* getPixels() const override { return _pixelBuffer.data(); }

    int getWidth() const { return _width; }
    int getHeight() const { return _height; }

private:
    void setupQuad();
    GLuint compileShader(GLenum type, const std::string& source);

private:
    GLFWwindow* _window;

    GLuint _shaderProgram;
    GLuint _framebuffer;
    GLuint _texture;
    GLuint _vao;
    GLuint _vbo;

    int _width;
    int _height;

    std::vector<uint8_t> _pixelBuffer;
};

