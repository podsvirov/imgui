include("${CMAKE_CURRENT_LIST_DIR}/ImGuiModule.cmake")

set(ImGui_SUPPORTED_COMPONENTS)
set(ImGui_AVAILABLE_COMPONENTS)

imgui_core(
    HEADERS
        imconfig.h
        imgui.h
        imgui_internal.h
    PRIVATE_HEADERS
        stb_textedit.h
        stb_truetype.h
        stb_rect_pack.h
    SOURCES
        imgui.cpp
        imgui_draw.cpp
        imgui_demo.cpp)

imgui_binding(ImplFreeGLUT
    HEADERS imgui_impl_freeglut.h
    SOURCES imgui_impl_freeglut.cpp
    PACKAGES FreeGLUT
    TARGETS FreeGLUT::freeglut)

imgui_binding(ImplSDL2
    HEADERS imgui_impl_sdl.h
    SOURCES imgui_impl_sdl.cpp
    PACKAGES SDL2
    TARGETS SDL2::SDL2main SDL2::SDL2)

imgui_binding(ImplGlfw
    HEADERS imgui_impl_glfw.h
    SOURCES imgui_impl_glfw.cpp
    PACKAGES glfw3
    TARGETS glfw)

imgui_binding(ImplOpenGL2
    HEADERS imgui_impl_opengl2.h
    SOURCES imgui_impl_opengl2.cpp
    PACKAGES OpenGL
    TARGETS OpenGL::GL)

imgui_binding(ImplOpenGL3
    HEADERS imgui_impl_opengl3.h
    SOURCES imgui_impl_opengl3.cpp
    PACKAGES OpenGL gl3w
    TARGETS OpenGL::GL gl3w)

imgui_binding(ImplVulkan
    HEADERS imgui_impl_vulkan.h
    SOURCES imgui_impl_vulkan.cpp
    PACKAGES Vulkan
    TARGETS Vulkan::Vulkan)

imgui_misc(FreeType
    HEADERS imgui_freetype.h
    SOURCES imgui_freetype.cpp
    PACKAGES Freetype
    TARGETS Freetype::Freetype)

imgui_misc(STL
    HEADERS imgui_stl.h
    SOURCES imgui_stl.cpp)
