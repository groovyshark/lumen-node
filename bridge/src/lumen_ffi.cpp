#include "lumen_ffi.h"

#include "nodes/ColorNode.hpp"
#include "nodes/MultiplyNode.hpp"
#include "nodes/AddNode.hpp"
#include "nodes/MasterNode.hpp"
#include "Graph.hpp"

extern "C" {
    EXPORT void* createGraph() {
        return new ShaderGraph();
    }

    EXPORT void destroyGraph(void* graphPtr) {
        delete static_cast<ShaderGraph*>(graphPtr);
    }

    EXPORT void addNode(void* graphPtr, const char* nodeId, ENodeType nodeType) {
        auto graph = static_cast<ShaderGraph*>(graphPtr);

        switch(nodeType) {
            case NODE_TYPE_COLOR:
                graph->addNode(std::make_shared<ColorNode>(nodeId));
                break;
            case NODE_TYPE_MULTIPLY:
                graph->addNode(std::make_shared<MultiplyNode>(nodeId));
                break;
            case NODE_TYPE_ADD:
                graph->addNode(std::make_shared<AddNode>(nodeId));
                break;
            case NODE_TYPE_MASTER:
                graph->addNode(std::make_shared<MasterNode>(nodeId));
                break;
        }
    }

    EXPORT void setNodeParameter(
        void* graphPtr, 
        const char* nodeId, 
        const char* paramName, 
        float value)
    {
        auto graph = static_cast<ShaderGraph*>(graphPtr);
        graph->setNodeParam(nodeId, paramName, value);
    }

    EXPORT void connectNodes(void* graphPtr, 
                             const char* fromNode, const char* fromPin, 
                             const char* toNode, const char* toPin) {
        auto graph = static_cast<ShaderGraph*>(graphPtr);
        graph->connect(fromNode, fromPin, toNode, toPin);
    }

    EXPORT void disconnectNode(void* graphPtr, const char* targetNode, const char* targetPin) {
        auto graph = static_cast<ShaderGraph*>(graphPtr);
        graph->disconnect(targetNode, targetPin);
    }
    
    EXPORT const char* compile(void* graphPtr) {
        auto graph = static_cast<ShaderGraph*>(graphPtr);
        
        static std::string lastCode;
        lastCode = graph->compile();
        
        return lastCode.c_str();
    }
}