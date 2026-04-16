#include "Node.hpp"

void Node::setParam(const std::string& name, const NodeParam& value) {
    params[name] = value;
}

std::string Node::getOutputVar(const std::string& pinName) const {
    return std::format("var_{}_{}", id, pinName);
}