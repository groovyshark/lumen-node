#pragma once

#include <format>

#include "Node.hpp"

class ColorNode : public Node {
public:
    ColorNode(const std::string& id);

    std::string emitCode() override;
};