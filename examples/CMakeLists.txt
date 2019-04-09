cmake_minimum_required(VERSION 3.1)

get_filename_component(ImGui_SRCDIR "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY)

include("${CMAKE_CURRENT_LIST_DIR}/ImGuiModule.cmake")

set(ImGui_OPTIONS)

imgui_option(EXAMPLES "Dear ImGui example applications" ON)
imgui_option(BINDINGS "Dear ImGui example bindings" ON)
imgui_option(MISC     "Dear ImGui misc features" ON)
imgui_option(3RDPARTY "Dear ImGui example dependencies" ON)
imgui_option(OPENGL_LOADER
    "Dear ImGui OpenGL loader (GL3W, GLEW, GLAD or custom header)" "GL3W"
    STRINGS "GL3W" "GLEW" "GLAD")

file(GENERATE OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/ImGuiOptions.cmake"
    CONTENT "${ImGui_OPTIONS_CMAKE}")

project(imgui_examples
    LANGUAGES CXX)

include("${CMAKE_CURRENT_LIST_DIR}/ImGuiTargets.cmake")

set(ImGui_DIR "${CMAKE_CURRENT_LIST_DIR}")

imgui_example(example_null
    TARGETS Core)

imgui_example(example_glut_opengl2
    BINDINGS ImplGLUT ImplOpenGL2)

imgui_example(example_sdl_opengl2
    BINDINGS ImplSDL2 ImplOpenGL2)

imgui_example(example_sdl_opengl3
    BINDINGS ImplSDL2 ImplOpenGL3)

imgui_example(example_sdl_vulkan
    BINDINGS ImplSDL2 ImplVulkan)

imgui_example(example_glfw_opengl2
    BINDINGS ImplGlfw ImplOpenGL2)

imgui_example(example_glfw_opengl2_freetype
    BINDINGS ImplGlfw ImplOpenGL2
    MISC FreeType)

imgui_example(example_glfw_opengl3
    BINDINGS ImplGlfw ImplOpenGL3)

imgui_example(example_glfw_vulkan
    BINDINGS ImplGlfw ImplVulkan)

if(NOT "${CMAKE_CURRENT_LIST_DIR}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR}")
    foreach(FILE ImGuiConfig.cmake ImGuiModule.cmake ImGuiTargets.cmake)
        configure_file(${FILE} ${FILE} COPYONLY)
    endforeach()
endif()

install(FILES ImGuiConfig.cmake ImGuiModule.cmake ImGuiTargets.cmake
    "${CMAKE_CURRENT_BINARY_DIR}/ImGuiOptions.cmake"
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/imgui)
