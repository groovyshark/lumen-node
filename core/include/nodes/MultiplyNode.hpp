#pragma once

#include "Node.hpp"

class MultiplyNode : public Node {
public:
    MultiplyNode(std::string nodeId);

    std::string emitCode(const std::map<std::string, std::shared_ptr<Node>>& allNodes) override;
};