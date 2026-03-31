#include "nodes/ColorNode.hpp"

ColorNode::ColorNode(const std::string& id) {
    this->id = id;
    this->name = "Color Constant";
    
    outputs.push_back({std::format("{}_out", id), "RGBA", PinType::Vec4, id});
}

std::string ColorNode::emitCode() {
    return "vec4 var_" + id + "_out = vec4(1.0, 0.5, 0.2, 1.0);";
}