#pragma once

#include "Node.hpp"

class ColorNode : public Node {
public:
    ColorNode(const std::string& id);

    std::string emitCode(const std::map<std::string, std::shared_ptr<Node>>& allNodes) override;
};