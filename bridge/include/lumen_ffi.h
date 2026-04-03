#pragma once

#ifdef _WIN32
#define EXPORT __declspec(dllexport)
#else
#define EXPORT __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif

    EXPORT void* createGraph();
    EXPORT void destroyGraph(void* graphPtr);

    EXPORT void addColorNode(void* graphPtr, const char* nodeId);
    EXPORT void addMultiplyNode(void* graphPtr, const char* nodeId);
    EXPORT void addAddNode(void* graphPtr, const char* nodeId);

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