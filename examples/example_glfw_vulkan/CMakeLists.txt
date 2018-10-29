project(example_glfw_vulkan
    LANGUAGES CXX)

find_package(ImGui CONFIG REQUIRED
    COMPONENTS ImplGlfw ImplVulkan)

add_executable(${PROJECT_NAME} main.cpp)

target_link_libraries(${PROJECT_NAME}
    PRIVATE ImGui::ImplGlfw ImGui::ImplVulkan)
