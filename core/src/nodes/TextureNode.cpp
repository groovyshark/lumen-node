#include "nodes/TextureNode.hpp"

#include <format>

TextureNode::TextureNode(const std::string &nodeId) {
    id = nodeId;
    name = "Texture";

    inputs.push_back({std::format("{}_in_a", id), "a", PinType::Vec4, id});
    outputs.push_back({std::format("{}_out", id), "output", PinType::Vec4, id});

    params["path"] = std::string();
}

std::string TextureNode::emitCode(const std::map<std::string, std::shared_ptr<Node>>& allNodes) {
    std::string uvSource = "uv";

    if (!inputs[0].connectedNodeId.empty()) {
        uvSource = allNodes.at(inputs[0].connectedNodeId)->getOutputVar(inputs[0].connectedPinName);
    }

    return std::format("vec4 {} = texture(uTexture, {});", getOutputVar("output"), uvSource);
}