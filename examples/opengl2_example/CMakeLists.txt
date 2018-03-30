cmake_minimum_required(VERSION 3.3)

project(opengl2_example
    VERSION 1.60
    LANGUAGES CXX)

find_package(ImGui ${PROJECT_VERSION} REQUIRED CONFIG)

add_executable(${PROJECT_NAME} main.cpp)

target_link_libraries(${PROJECT_NAME} ImGui::ImplGlfwGL2 ImGui::Demo)

include(GNUInstallDirs)
if(EMSCRIPTEN)
    set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY LINK_FLAGS "-s WASM=1")
    set_property(TARGET ${PROJECT_NAME} PROPERTY SUFFIX .html)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.html
        ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.js
        ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.wasm
        DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/${PROJECT_NAME_LOWER}/examples)
else()
    set_property(TARGET ${PROJECT_NAME} PROPERTY OUTPUT_NAME imgui_${PROJECT_NAME})
    install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
endif()
