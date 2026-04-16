#pragma once

#include "Pin.hpp"

#include <map>
#include <memory>
#include <vector>
#include <format>
#include <variant>

using NodeParam = std::variant<
    float, 
    std::string
>;

class Node {
public:
    std::string id;
    std::string name;

    std::vector<Pin> inputs;
    std::vector<Pin> outputs;

    std::map<std::string, NodeParam> params;

    virtual ~Node() = default;

    void setParam(const std::string& name, const NodeParam& value);

    std::string getOutputVar(const std::string& pinName = "out") const;
    
    virtual std::string emitCode(const std::map<std::string, std::shared_ptr<Node>>& allNodes) = 0;
};