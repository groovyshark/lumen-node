cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "Runner.rc"
  "runner.exe.manifest"
  "../../../core/src/renderer/opengl/OpenGLRenderer.cpp"
  "../../../core/stb_image_impl.cc"
)

list(APPEND CMAKE_PREFIX_PATH "C:/development/lumen-node/build/vcpkg_installed/x64-windows")

find_package(GLEW REQUIRED)
find_package(glfw3 CONFIG REQUIRED)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the build version.
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"${FLUTTER_VERSION}\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}")

# Disable Windows macros that collide with C++ standard library functions.
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")

# Add dependency libraries and include directories. Add any application-specific
# dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app flutter_wrapper_plugin opengl32 GLEW::GLEW glfw )
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib")
target_include_directories(${BINARY_NAME} PRIVATE 
    "${CMAKE_SOURCE_DIR}" 
    "../../../core/include"
    "../../../third_party/stb_image"
)

# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)

add_custom_command(TARGET ${BINARY_NAME} POST_BUILD
    # 1. Копируем твою библиотеку ядра (проверь правильность пути к твоей сборке)
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    "C:/development/lumen-node/build/Debug/lumen-node.dll"
    "$<TARGET_FILE_DIR:${BINARY_NAME}>/"

    # 2. Копируем GLEW (с суффиксом 'd' для Debug)
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    "C:/development/lumen-node/build/vcpkg_installed/x64-windows/debug/bin/glew32d.dll"
    "$<TARGET_FILE_DIR:${BINARY_NAME}>/"

    # 3. Копируем GLFW
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    "C:/development/lumen-node/build/vcpkg_installed/x64-windows/debug/bin/glfw3.dll"
    "$<TARGET_FILE_DIR:${BINARY_NAME}>/"
)
