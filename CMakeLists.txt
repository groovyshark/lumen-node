cmake_minimum_required(VERSION 3.10.0)
project(lumen-node VERSION 0.1.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(NOT CMAKE_TOOLCHAIN_FILE AND DEFINED ENV{VCPKG_ROOT})
    set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake" CACHE STRING "")
endif()

find_package(spdlog CONFIG REQUIRED)
find_package(glm CONFIG REQUIRED)
find_package(glfw3 CONFIG REQUIRED)
find_package(GLEW CONFIG REQUIRED)
find_package(OpenGL REQUIRED)

file(GLOB_RECURSE SOURCES 
    "core/*.cpp" "core/*.hpp" "core/*.h"
    "bridge/*.cpp" "bridge/*.hpp" "bridge/*.h"
)

add_library(${PROJECT_NAME} SHARED
    ${SOURCES}
)

target_include_directories(${PROJECT_NAME} PUBLIC 
    core/include 
    bridge/include
)

target_link_libraries(${PROJECT_NAME} PRIVATE 
    glm::glm
    glfw
    GLEW::GLEW
    OpenGL::GL
    spdlog::spdlog
)

set_target_properties(${PROJECT_NAME} PROPERTIES Windows_EXPORT_ALL_SYMBOLS ON)