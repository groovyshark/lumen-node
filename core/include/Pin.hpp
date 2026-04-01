#pragma once

#include <string>

enum class PinType { Float, Vec2, Vec3, Vec4 };

struct Pin {
    std::string id;
    std::string name;

    PinType type;
    
    std::string ownerNodeId;

    std::string connectedNodeId;
    std::string connectedPinName; 
    std::string defaultValue = "vec4(1.0)";

    std::string glslType() const {
        switch(type) {
            case PinType::Float: return "float";
            case PinType::Vec2:  return "vec2";
            case PinType::Vec3:  return "vec3";
            case PinType::Vec4:  return "vec4";
            default: return "unknown";
        }
    }
};
