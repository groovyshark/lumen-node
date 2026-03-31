#pragma once

#include "Pin.hpp"

#include <vector>

class Node {
public:
    std::string id;
    std::string name;

    std::vector<Pin> inputs;
    std::vector<Pin> outputs;

    virtual ~Node() = default;
    
    virtual std::string emitCode() = 0;
};