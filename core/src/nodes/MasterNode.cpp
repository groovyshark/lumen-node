#include "nodes/MasterNode.hpp"

MasterNode::MasterNode(const std::string& nodeId) {
    id = nodeId;
    name = "Fragment Output";

    Pin inColor = {id + "_in_color", "color", PinType::Vec4, id};
    inColor.defaultValue = "vec4(1.0, 0.0, 0.0, 1.0)";
    inputs.push_back(inColor);
}

std::string MasterNode::emitCode(const std::map<std::string, std::shared_ptr<Node>>& allNodes) {
    return "";
}