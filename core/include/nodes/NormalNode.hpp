#pragma once

#include "Node.hpp"

class NormalNode : public Node {
public:
    NormalNode(const std::string& id);

    std::string emitCode(const std::map<std::string, std::shared_ptr<Node>>& allNodes) override;
};