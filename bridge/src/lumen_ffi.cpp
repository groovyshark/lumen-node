#include "lumen_ffi.h"

#include "nodes/ColorNode.hpp"
#include "Graph.hpp"

extern "C" {
    EXPORT void* createGraph() {
        return new ShaderGraph();
    }

    EXPORT void destroyGraph(void* graph) {
        delete static_cast<ShaderGraph*>(graph);
    }

    EXPORT void addColorNode(void* graphPtr, const char* nodeId) {
        auto graph = static_cast<ShaderGraph*>(graphPtr);
        graph->addNode(std::make_shared<ColorNode>(nodeId));
    }
    
    EXPORT const char* compile(void* graphPtr) {
        auto graph = static_cast<ShaderGraph*>(graphPtr);
        
        static std::string last_code; // Временный костыль для владения строкой
        last_code = graph->compile();
        
        return last_code.c_str();
    }
}