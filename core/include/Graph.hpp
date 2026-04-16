#pragma once

#include <unordered_map>
#include <map>
#include <memory>
#include <set>

#include "Node.hpp"

class ShaderGraph {
public:
    ShaderGraph();
    ~ShaderGraph() = default;

    void addNode(std::shared_ptr<Node> node);

    void connect(
        const std::string& fromNodeId, 
        const std::string& fromPinId, 
        const std::string& toNodeId, 
        const std::string& toPinId
    );
    void disconnect(
        const std::string& targetNodeId,
        const std::string& targetPinId
    );

    void setNodeParam(const std::string& nodeId, const std::string& paramName, const NodeParam& value);

    std::string compile();

private:
    void evaluateNode(const std::string& nodeId, std::set<std::string>& visited, std::string& outCode);

private:
    std::map<std::string, std::shared_ptr<Node>> _nodes;

    std::unordered_map<std::string, std::string> _connections;
};