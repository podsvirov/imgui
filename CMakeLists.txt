cmake_minimum_required(VERSION 3.3)

project(ImGui
    VERSION 1.60
    LANGUAGES C CXX)

option(${PROJECT_NAME}_BUILD_EXAMPLES OFF
    "Set to \"ON\" to build Dear ImGui examples")

string(TOLOWER ${PROJECT_NAME} PROJECT_NAME_LOWER)

if(NOT DEFINED CMAKE_DEBUG_POSTFIX)
    set(CMAKE_DEBUG_POSTFIX _d)
endif()

add_library(Library
    imgui_internal.h
    imgui.cpp
    imgui_draw.cpp)
set_target_properties(Library PROPERTIES
    FRAMEWORK TRUE
    VERSION ${PROJECT_VERSION}
    PUBLIC_HEADER "imgui.h;imconfig.h"
    OUTPUT_NAME ${PROJECT_NAME_LOWER})
target_include_directories(Library PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}>
    $<INSTALL_INTERFACE:include>)

add_library(Demo
    imgui_demo.cpp)
target_link_libraries(Demo PUBLIC Library)
set_target_properties(Demo PROPERTIES
    OUTPUT_NAME ${PROJECT_NAME_LOWER}_demo)

include(GNUInstallDirs)

install(TARGETS Library Demo
    EXPORT ${PROJECT_NAME}Export
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

add_subdirectory(examples)

install(EXPORT ${PROJECT_NAME}Export NAMESPACE ${PROJECT_NAME}:: FILE ${PROJECT_NAME}Config.cmake DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/${PROJECT_NAME_LOWER}/cmake)
