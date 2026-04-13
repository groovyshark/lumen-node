#pragma once

#include <format>

#include "Node.hpp"

class UVNode : public Node {
public:
    UVNode(const std::string& id);

    std::string emitCode(const std::map<std::string, std::shared_ptr<Node>>& allNodes) override;
};