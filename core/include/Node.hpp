#pragma once

#include "Pin.hpp"

#include <map>
#include <memory>
#include <vector>
#include <format>

class Node {
public:
    std::string id;
    std::string name;

    std::vector<Pin> inputs;
    std::vector<Pin> outputs;

    std::map<std::string, float> params;

    virtual ~Node() = default;

    void setParam(const std::string& name, float value);

    std::string getOutputVar(const std::string& pinName = "out") const;
    
    virtual std::string emitCode(const std::map<std::string, std::shared_ptr<Node>>& allNodes) = 0;
};