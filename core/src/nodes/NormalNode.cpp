#include "nodes/NormalNode.hpp"

#include <format>

NormalNode::NormalNode(const std::string &nodeId) {
    id = nodeId;
    name = "Normal";

    outputs.push_back({std::format("{}_out", nodeId), "output", PinType::Vec4, nodeId});
}

std::string NormalNode::emitCode(const std::map<std::string, std::shared_ptr<Node>>& allNodes) {
    return std::format("vec4 {} = vec4(normalize(Normal) * 0.5 + 0.5, 1.0);", getOutputVar("output"));
}