# Search depend packages
find_package(SDL2 QUIET)
find_package(glfw3 QUIET)
find_package(OpenGL QUIET)

if((glfw3_FOUND AND OpenGL_FOUND) OR EMSCRIPTEN)
    add_library(ImplGlfwGL2 opengl2_example/imgui_impl_glfw_gl2.cpp)
    set_target_properties(ImplGlfwGL2 PROPERTIES
        FRAMEWORK TRUE
        VERSION ${PROJECT_VERSION}
        PUBLIC_HEADER opengl2_example/imgui_impl_glfw_gl2.h
        OUTPUT_NAME ${PROJECT_NAME_LOWER}_impl_glfw_gl2)
    target_include_directories(ImplGlfwGL2 PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/opengl2_example>
        $<INSTALL_INTERFACE:include>)
    target_link_libraries(ImplGlfwGL2 PUBLIC Library)
    if(EMSCRIPTEN)
        target_link_libraries(ImplGlfwGL2 PUBLIC glfw GL
            "-s LEGACY_GL_EMULATION=1" "-s GL_UNSAFE_OPTS=0" "-s USE_GLFW=3")
    else()
        target_link_libraries(ImplGlfwGL2 PUBLIC glfw OpenGL::GL)
    endif()
    install(TARGETS ImplGlfwGL2
        EXPORT ${PROJECT_NAME}Export
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
endif()

if((SDL2_FOUND AND OpenGL_FOUND))
    add_library(ImplSdlGL2 sdl_opengl2_example/imgui_impl_sdl_gl2.cpp)
    set_target_properties(ImplSdlGL2 PROPERTIES
        FRAMEWORK TRUE
        VERSION ${PROJECT_VERSION}
        PUBLIC_HEADER sdl_opengl2_example/imgui_impl_sdl_gl2.h
        OUTPUT_NAME ${PROJECT_NAME_LOWER}_impl_sdl_gl2)
    target_include_directories(ImplSdlGL2 PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/sdl_opengl2_example>
        $<INSTALL_INTERFACE:include>)
    target_link_libraries(ImplSdlGL2 PUBLIC Library SDL2::SDL2 SDL2::SDL2main OpenGL::GL)
    get_target_property(SDL2_INCLUDE_DIR SDL2::SDL2 INTERFACE_INCLUDE_DIRECTORIES)
    if(EXISTS ${SDL2_INCLUDE_DIR}/SDL2)
        target_include_directories(ImplSdlGL2 PUBLIC
            $<BUILD_INTERFACE:${SDL2_INCLUDE_DIR}/SDL2>
            $<INSTALL_INTERFACE:include/SDL2>)
    endif()
    install(TARGETS ImplSdlGL2
        EXPORT ${PROJECT_NAME}Export
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
endif()

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
  ${PROJECT_NAME}ConfigVersion.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY AnyNewerVersion)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/${PROJECT_NAME_LOWER}/cmake)
export(EXPORT ${PROJECT_NAME}Export NAMESPACE ${PROJECT_NAME}:: FILE ${PROJECT_NAME}Config.cmake)

if(${PROJECT_NAME}_BUILD_EXAMPLES)
    set(${PROJECT_NAME}_DIR ${CMAKE_CURRENT_BINARY_DIR})
    find_package(${PROJECT_NAME} QUIET CONFIG NO_DEFAULT_PATH)
    if(TARGET ImplGlfwGL2 AND ${PROJECT_NAME}_FOUND)
        add_subdirectory(opengl2_example)
        add_dependencies(opengl2_example ImplGlfwGL2 Demo)
    endif()
    if(TARGET ImplSdlGL2 AND ${PROJECT_NAME}_FOUND)
        add_subdirectory(sdl_opengl2_example)
        add_dependencies(sdl_opengl2_example ImplSdlGL2 Demo)
    endif()
endif()
