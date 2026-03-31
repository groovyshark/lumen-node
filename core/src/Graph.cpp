#include "Graph.hpp"

#include <format>

void ShaderGraph::addNode(std::shared_ptr<Node> node) {
    _nodes[node->id] = node;
}

void ShaderGraph::connect(const std::string& fromPinId, const std::string& toPinId) {
    _connections[fromPinId] = toPinId;
}

std::string ShaderGraph::compile() {
    std::string code = "void mainImage(out vec4 fragColor, in vec2 fragCoord) {\n";

    for (const auto& [id, node] : _nodes) {
        code += std::format("    {}\n", node->emitCode());
    }

    code += std::format("    fragColor = var_{}_out;\n", _nodes.rbegin()->first);
    code += "}\n";
    
    return code;
}
