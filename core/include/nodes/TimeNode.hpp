#pragma once

#include "Node.hpp"

class TimeNode : public Node {
public:
    TimeNode(const std::string& id);

    std::string emitCode(const std::map<std::string, std::shared_ptr<Node>>& allNodes) override;
};