#include "nodes/AddNode.hpp"

#include <format>

AddNode::AddNode(std::string nodeId) {
    id = nodeId;
    name = "Add";

    Pin inA = {std::format("{}_in_a", id), "a", PinType::Vec4, id};
    inA.defaultValue = "vec4(1.0)";

    Pin inB = {std::format("{}_in_b", id), "b", PinType::Vec4, id};
    inB.defaultValue = "vec4(1.0)";

    inputs.push_back(inA);
    inputs.push_back(inB);

    outputs.push_back({std::format("{}_out", id), "output", PinType::Vec4, id});
}

std::string AddNode::emitCode(const std::map<std::string, std::shared_ptr<Node>>& allNodes) {
    std::string valA = inputs[0].defaultValue;
    std::string valB = inputs[1].defaultValue;

    if (!inputs[0].connectedNodeId.empty()) {
        valA = allNodes.at(inputs[0].connectedNodeId)->getOutputVar(inputs[0].connectedPinName);
    }

    if (!inputs[1].connectedNodeId.empty()) {
        valB = allNodes.at(inputs[1].connectedNodeId)->getOutputVar(inputs[1].connectedPinName);
    }

    return std::format("vec4 {} = {} + {};", getOutputVar("output"), valA, valB);
}