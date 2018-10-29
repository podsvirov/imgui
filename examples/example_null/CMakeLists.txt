project(example_null
    LANGUAGES CXX)

find_package(ImGui CONFIG REQUIRED
    COMPONENTS Core)

add_executable(${PROJECT_NAME} main.cpp)

target_link_libraries(${PROJECT_NAME}
    PRIVATE ImGui::Core)
