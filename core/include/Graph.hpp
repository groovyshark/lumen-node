#pragma once

#include <unordered_map>
#include <map>
#include <memory>

#include "Node.hpp"

class ShaderGraph {
public:
    void addNode(std::shared_ptr<Node> node);

    void connect(const std::string& fromPinId, const std::string& toPinId);

    std::string compile();

private:
    std::map<std::string, std::shared_ptr<Node>> _nodes;

    std::unordered_map<std::string, std::string> _connections;
};