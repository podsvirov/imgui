cmake_minimum_required(VERSION 3.11)

project(example_freeglut_opengl2
    LANGUAGES CXX)

find_package(ImGui CONFIG REQUIRED
    COMPONENTS ImplFreeGLUT ImplOpenGL2)

add_executable(${PROJECT_NAME} main.cpp)

target_link_libraries(${PROJECT_NAME}
    PRIVATE ImGui::ImplFreeGLUT ImGui::ImplOpenGL2)
