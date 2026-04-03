#pragma once

#include "Node.hpp"

class AddNode : public Node {
public:
    AddNode(std::string nodeId);

    std::string emitCode(const std::map<std::string, std::shared_ptr<Node>>& allNodes) override;
};