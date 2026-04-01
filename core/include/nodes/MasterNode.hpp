#pragma once

#include "Node.hpp"

class MasterNode : public Node {
public:
    MasterNode(const std::string& id);

    std::string emitCode(const std::map<std::string, std::shared_ptr<Node>>& allNodes) override;
};