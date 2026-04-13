#include "nodes/UVNode.hpp"

#include <format>

UVNode::UVNode(const std::string &nodeId) {
    id = nodeId;
    name = "UV";

    outputs.push_back({std::format("{}_out", nodeId), "output", PinType::Vec4, nodeId});
}

std::string UVNode::emitCode(const std::map<std::string, std::shared_ptr<Node>>& allNodes) {
    return std::format("vec4 {} = vec4(fragCoord.x, fragCoord.y, 0.0, 1.0);", getOutputVar("output"));
}