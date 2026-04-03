#include "Graph.hpp"

#include <format>

#include "nodes/MasterNode.hpp"

ShaderGraph::ShaderGraph() {
    auto masterNode = std::make_shared<MasterNode>("master");
    addNode(masterNode);
}

void ShaderGraph::addNode(std::shared_ptr<Node> node) {
    _nodes[node->id] = node;
}

void ShaderGraph::connect(
    const std::string &fromNodeId,
    const std::string &fromPinId,
    const std::string &toNodeId,
    const std::string &toPinId) {
    if (_nodes.count(fromNodeId) && _nodes.count(toNodeId)) {
        for (auto &pin : _nodes[toNodeId]->inputs) {
            if (pin.name == toPinId) {
                pin.connectedNodeId = fromNodeId;
                pin.connectedPinName = fromPinId;
                break;
            }
        }
    }
}

void ShaderGraph::disconnect(
    const std::string &targetNodeId,
    const std::string &targetPinId) {
    if (_nodes.count(targetNodeId)) {
        for (auto &pin : _nodes[targetNodeId]->inputs) {
            if (pin.name == targetPinId) {
                pin.connectedNodeId.clear();
                pin.connectedPinName.clear();
                break;
            }
        }
    }
}

std::string ShaderGraph::compile() {
    if (_nodes.empty()) {
        return "// Graph is empty";
    }

    std::string resultCode = "void mainImage(out vec4 fragColor, in vec2 fragCoord) {\n";

    std::set<std::string> visited;
    std::string bodyCode;

    evaluateNode("master", visited, bodyCode);
    resultCode += bodyCode;

    std::string finalColor = "vec4(0.0, 0.0, 0.0, 1.0)";
    if (_nodes.count("master")) {
        auto masterIn = _nodes["master"]->inputs[0];
        
        if (!masterIn.connectedNodeId.empty()) {
            finalColor = _nodes[masterIn.connectedNodeId]->getOutputVar(masterIn.connectedPinName);
        } else {
            finalColor = masterIn.defaultValue;
        }
    }

    resultCode += std::format("    fragColor = {};\n", finalColor);
    resultCode += "}\n";

    return resultCode;
}

void ShaderGraph::evaluateNode(const std::string &nodeId, std::set<std::string> &visited, std::string &outCode) {
    if (visited.count(nodeId))
        return;

    auto node = _nodes[nodeId];
    for (const auto &input : node->inputs) {
        if (!input.connectedNodeId.empty()) {
            evaluateNode(input.connectedNodeId, visited, outCode);
        }
    }

    outCode += std::format("    {}\n", node->emitCode(_nodes));

    visited.insert(nodeId);
}