#pragma once

#include <string>
#include <cstdint>

class IRenderer {
public:
    virtual ~IRenderer() = default;
    
    virtual bool initialize(int width, int height) = 0;
    
    virtual void updateShader(const std::string& fragmentShaderCode) = 0;
    
    virtual void render() = 0;
    
    virtual const uint8_t* getPixels() const = 0;
};