#include "nodes/TimeNode.hpp"

#include <format>

TimeNode::TimeNode(const std::string &nodeId) {
    id = nodeId;
    name = "Time";

    outputs.push_back({std::format("{}_out", nodeId), "output", PinType::Vec4, nodeId});
}

std::string TimeNode::emitCode(const std::map<std::string, std::shared_ptr<Node>>& allNodes) {
    return std::format("vec4 {} = vec4(sin(uTime) * 0.5 + 0.5, cos(uTime) * 0.5 + 0.5, 0.5, 1.0);", getOutputVar("output"));
}