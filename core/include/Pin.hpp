#pragma once

#include <string>

enum class PinType { Float, Vec3, Vec4 };

struct Pin {
    std::string id;
    std::string name;
    PinType type;
    std::string ownerNodeId;

    std::string glslType() const {
        switch(type) {
            case PinType::Float: return "float";
            case PinType::Vec3:  return "vec3";
            case PinType::Vec4:  return "vec4";
            default: return "unknown";
        }
    }
};
