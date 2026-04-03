#pragma once

#ifdef _WIN32
#define EXPORT __declspec(dllexport)
#else
#define EXPORT __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif
    typedef enum {
        NODE_TYPE_COLOR = 0,
        NODE_TYPE_MULTIPLY = 1,
        NODE_TYPE_ADD = 2,
        NODE_TYPE_MASTER = 100
    } ENodeType;

    EXPORT void* createGraph();
    EXPORT void destroyGraph(void* graphPtr);

    EXPORT void addNode(void* graphPtr, const char* nodeId, ENodeType nodeType);

    EXPORT void setNodeParameter(
        void* graphPtr, 
        const char* nodeId, 
        const char* paramName, 
        float value
    );
    
    EXPORT void connectNodes(
        void* graphPtr, 
        const char* fromNode,
        const char* fromPin, 
        const char* toNode, 
        const char* toPin
    );

    EXPORT void disconnectNode(
        void* graphPtr, 
        const char* targetNode, 
        const char* targetPin
    );

    EXPORT const char* compile(void* graphPtr);

#ifdef __cplusplus
}
#endif