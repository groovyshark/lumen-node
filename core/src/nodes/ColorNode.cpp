#include "nodes/ColorNode.hpp"

#include <format>

ColorNode::ColorNode(const std::string &nodeId) {
    id = nodeId;
    name = "Color";

    outputs.push_back({std::format("{}_out", nodeId), "output", PinType::Vec4, nodeId});

    params["r"] = 1.0f;
    params["g"] = 1.0f;
    params["b"] = 1.0f;
    params["a"] = 1.0f;
}

std::string ColorNode::emitCode(const std::map<std::string, std::shared_ptr<Node>>& allNodes) {
    return std::format("vec4 {} = vec4({:.2f}, {:.2f}, {:.2f}, {:.2f});",
                       getOutputVar("output"),
                       params["r"], params["g"], params["b"], params["a"]);
}