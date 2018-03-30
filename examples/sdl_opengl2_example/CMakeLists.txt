cmake_minimum_required(VERSION 3.3)

project(sdl_opengl2_example
    VERSION 1.60
    LANGUAGES CXX)

find_package(ImGui ${PROJECT_VERSION} REQUIRED CONFIG)

add_executable(${PROJECT_NAME} main.cpp)

target_link_libraries(${PROJECT_NAME} ImGui::ImplSdlGL2 ImGui::Demo)

set_property(TARGET ${PROJECT_NAME} PROPERTY OUTPUT_NAME imgui_${PROJECT_NAME})

include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
