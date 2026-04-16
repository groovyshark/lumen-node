#pragma once

#include "Node.hpp"

class TextureNode : public Node {
public:
    TextureNode(const std::string& id);

    std::string emitCode(const std::map<std::string, std::shared_ptr<Node>>& allNodes) override;
};