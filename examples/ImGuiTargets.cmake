include("${CMAKE_CURRENT_LIST_DIR}/ImGuiModule.cmake")

set(ImGui_SUPPORTED_COMPONENTS)
set(ImGui_AVAILABLE_COMPONENTS)

imgui_core(
    HEADERS
        imconfig.h
        imgui.h
        imgui_internal.h
    PRIVATE_HEADERS
        imstb_textedit.h
        imstb_truetype.h
        imstb_rectpack.h
    SOURCES_GLOB
        imgui*.cpp)

if(APPLE)
    set(_ImGui_PACKAGES GLUT)
    set(_ImGui_TARGETS GLUT::GLUT)
else()
    set(_ImGui_PACKAGES FreeGLUT)
    set(_ImGui_TARGETS FreeGLUT::freeglut)
endif()
imgui_binding(ImplGLUT
    HEADERS imgui_impl_glut.h
    SOURCES imgui_impl_glut.cpp
    PACKAGES ${_ImGui_PACKAGES}
    TARGETS ${_ImGui_TARGETS})
unset(_ImGui_PACKAGES)
unset(_ImGui_TARGETS)

if(EMSCRIPTEN)
    set(_ImGui_COMPILE_OPTIONS "SHELL:-s USE_SDL=2")
    set(_ImGui_LINK_OPTIONS ${_ImGui_COMPILE_OPTIONS})
else()
    set(_ImGui_PACKAGES SDL2)
    set(_ImGui_TARGETS SDL2::SDL2main SDL2::SDL2)
endif()
imgui_binding(ImplSDL2
    HEADERS imgui_impl_sdl.h
    SOURCES imgui_impl_sdl.cpp
    COMPILE_OPTIONS ${_ImGui_COMPILE_OPTIONS}
    LINK_OPTIONS ${_ImGui_LINK_OPTIONS}
    PACKAGES ${_ImGui_PACKAGES}
    TARGETS ${_ImGui_TARGETS})
unset(_ImGui_COMPILE_OPTIONS)
unset(_ImGui_LINK_OPTIONS)
unset(_ImGui_PACKAGES)
unset(_ImGui_TARGETS)

if(EMSCRIPTEN)
    set(_ImGui_COMPILE_OPTIONS "SHELL:-s USE_GLFW=3")
    set(_ImGui_LINK_OPTIONS ${_ImGui_COMPILE_OPTIONS})
else()
    set(_ImGui_PACKAGES glfw3)
    set(_ImGui_TARGETS glfw)
endif()
imgui_binding(ImplGlfw
    HEADERS imgui_impl_glfw.h
    SOURCES imgui_impl_glfw.cpp
    COMPILE_OPTIONS ${_ImGui_COMPILE_OPTIONS}
    LINK_OPTIONS ${_ImGui_LINK_OPTIONS}
    PACKAGES ${_ImGui_PACKAGES}
    TARGETS ${_ImGui_TARGETS})
unset(_ImGui_COMPILE_OPTIONS)
unset(_ImGui_LINK_OPTIONS)
unset(_ImGui_PACKAGES)
unset(_ImGui_TARGETS)

imgui_binding(ImplOpenGL2
    HEADERS imgui_impl_opengl2.h
    SOURCES imgui_impl_opengl2.cpp
    PACKAGES OpenGL
    TARGETS OpenGL::GL)

if("${ImGui_OPENGL_LOADER}" STREQUAL "GL3W")
    set(_ImGui_DEFINITIONS "IMGUI_IMPL_OPENGL_LOADER_GL3W=1")
    set(_ImGui_PACKAGES gl3w)
    set(_ImGui_TARGETS gl3w)
elseif("${ImGui_OPENGL_LOADER}" STREQUAL "GLEW")
    set(_ImGui_DEFINITIONS "IMGUI_IMPL_OPENGL_LOADER_GLEW=1")
    set(_ImGui_PACKAGES GLEW)
    set(_ImGui_TARGETS GLEW::GLEW)
elseif("${ImGui_OPENGL_LOADER}" STREQUAL "GLAD")
    set(_ImGui_DEFINITIONS "IMGUI_IMPL_OPENGL_LOADER_GLAD=1")
    set(_ImGui_PACKAGES glad)
    set(_ImGui_TARGETS glad::glad)
else()
    set(_ImGui_DEFINITIONS "IMGUI_IMPL_OPENGL_LOADER_CUSTOM=${ImGui_OPENGL_LOADER}")
    set(_ImGui_PACKAGES)
    set(_ImGui_TARGETS)
endif()
if(EMSCRIPTEN)
    set(_ImGui_PACKAGES)
    set(_ImGui_TARGETS)
else()
    list(APPEND _ImGui_PACKAGES OpenGL)
    list(APPEND _ImGui_TARGETS OpenGL::GL)
endif()
imgui_binding(ImplOpenGL3
    HEADERS imgui_impl_opengl3.h
    SOURCES imgui_impl_opengl3.cpp
    DEFINITIONS ${_ImGui_DEFINITIONS}
    PACKAGES ${_ImGui_PACKAGES}
    TARGETS ${_ImGui_TARGETS})
unset(_ImGui_DEFINITIONS)
unset(_ImGui_PACKAGES)
unset(_ImGui_TARGETS)

imgui_binding(ImplVulkan
    HEADERS imgui_impl_vulkan.h
    SOURCES imgui_impl_vulkan.cpp
    PACKAGES Vulkan
    TARGETS Vulkan::Vulkan)

imgui_misc(FreeType freetype
    HEADERS imgui_freetype.h
    SOURCES imgui_freetype.cpp
    PACKAGES Freetype
    TARGETS Freetype::Freetype)

imgui_misc(StdLib cpp
    HEADERS imgui_stdlib.h
    SOURCES imgui_stdlib.cpp)
