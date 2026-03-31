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
    EXPORT void destroyGraph(void* graph);

    EXPORT void addColorNode(void* graph, const char* nodeId);
    
    EXPORT const char* compile(void* graph);

#ifdef __cplusplus
}
#endif