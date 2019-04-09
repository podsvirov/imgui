cmake_minimum_required(VERSION 3.1)

project(example_glfw_opengl2_freetype
    LANGUAGES CXX)

find_package(ImGui CONFIG REQUIRED
    COMPONENTS ImplGlfw ImplOpenGL2 FreeType)

add_executable(${PROJECT_NAME} main.cpp)

target_link_libraries(${PROJECT_NAME}
    PRIVATE ImGui::ImplGlfw ImGui::ImplOpenGL2 ImGui::FreeType)
