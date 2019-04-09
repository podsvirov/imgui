if(NOT DEFINED ImGuiModule_CMAKE_INCLUDED)
    set(ImGuiModule_CMAKE_INCLUDED 1)
else()
    return()
endif()

if(CMAKE_VERSION VERSION_LESS 3.5)
    include(CMakeParseArguments)
endif()

if(EXISTS "${ImGui_SRCDIR}" AND EXISTS "${ImGui_SRCDIR}/imgui.cpp")
    set(ImGui TRUE)
else()
    include(${CMAKE_CURRENT_LIST_DIR}/ImGuiOptions.cmake)
endif()

function(imgui_option OPTION DESCRIPTION DEFAULT)
    if(ImGui)
        cmake_parse_arguments(OPTION "" "" "STRINGS" ${ARGN})
        if(DEFINED OPTION_STRINGS)
            set(ImGui_${OPTION} ${DEFAULT} CACHE STRING "${DESCRIPTION}")
            set_property(CACHE ImGui_${OPTION}
                PROPERTY STRINGS "${OPTION_STRINGS}")
        else()
            option(ImGui_${OPTION} "${DESCRIPTION}" ${DEFAULT})
        endif()
        set(ImGui_${OPTION}_DESCRIPTION "${DESCRIPTION}")
        set(ImGui_${OPTION}_DEFAULT ${DEFAULT})
        list(APPEND ImGui_OPTIONS ${OPTION})
        set(ImGui_OPTIONS "${ImGui_OPTIONS}" PARENT_SCOPE)
        set(ImGui_${OPTION}_DESCRIPTION "${DESCRIPTION}" PARENT_SCOPE)
        set(ImGui_OPTIONS_CMAKE)
        foreach(OPTION ${ImGui_OPTIONS})
            set(ImGui_OPTIONS_CMAKE "${ImGui_OPTIONS_CMAKE}# ${ImGui_${OPTION}_DESCRIPTION}\n")
            set(ImGui_OPTIONS_CMAKE "${ImGui_OPTIONS_CMAKE}set(ImGui_${OPTION} ${ImGui_${OPTION}})\n")
        endforeach()
        set(ImGui_OPTIONS_CMAKE "${ImGui_OPTIONS_CMAKE}" PARENT_SCOPE)
    endif()
endfunction()

function(imgui_export TARGET)
    if(CMAKE_VERSION VERSION_LESS 3.3)
        return()
    endif()
    export(TARGETS ${TARGET} NAMESPACE ImGui::
        FILE ImGui${TARGET}.cmake)
    install(TARGETS ${TARGET} EXPORT ${TARGET})
    install(EXPORT ${TARGET} NAMESPACE ImGui::
        FILE ImGui${TARGET}.cmake
        DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/imgui)
endfunction()

function(imgui_core)
    set(TARGET Core)
    list(APPEND ImGui_SUPPORTED_COMPONENTS ${TARGET})
    set(ImGui_SUPPORTED_COMPONENTS "${ImGui_SUPPORTED_COMPONENTS}" PARENT_SCOPE)
    list(APPEND ImGui_AVAILABLE_COMPONENTS ${TARGET})
    set(ImGui_AVAILABLE_COMPONENTS "${ImGui_AVAILABLE_COMPONENTS}" PARENT_SCOPE)
    if(ImGui AND "${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${ImGui_SRCDIR}/examples")
        cmake_parse_arguments(TARGET "" "" "HEADERS;PRIVATE_HEADERS;SOURCES;SOURCES_GLOB" ${ARGN})
        add_library(${TARGET} INTERFACE)
        include(GNUInstallDirs)
        target_include_directories(${TARGET} INTERFACE
            $<BUILD_INTERFACE:${ImGui_SRCDIR}>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/imgui>)
        foreach(HEADER ${TARGET_HEADERS})
            target_sources(${TARGET}
                INTERFACE
                    $<BUILD_INTERFACE:${ImGui_SRCDIR}/${HEADER}>
                    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/imgui/${HEADER}>)
            install(FILES ${ImGui_SRCDIR}/${HEADER}
                DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/imgui)
        endforeach()
        foreach(PRIVATE_HEADER ${TARGET_PRIVATE_HEADERS})
            install(FILES ${ImGui_SRCDIR}/${PRIVATE_HEADER}
                DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/imgui)
        endforeach()
        foreach(GLOB ${TARGET_SOURCES_GLOB})
            file(GLOB TARGET_SOURCES_BY_GLOB
                LIST_DIRECTORIES FALSE
                RELATIVE "${ImGui_SRCDIR}"
                "${ImGui_SRCDIR}/${GLOB}")
            list(APPEND TARGET_SOURCES ${TARGET_SOURCES_BY_GLOB})
        endforeach()
        foreach(SOURCE ${TARGET_SOURCES})
            target_sources(${TARGET}
                INTERFACE
                    $<BUILD_INTERFACE:${ImGui_SRCDIR}/${SOURCE}>
                    $<INSTALL_INTERFACE:${CMAKE_INSTALL_DATAROOTDIR}/imgui/${SOURCE}>)
            install(FILES ${ImGui_SRCDIR}/${SOURCE}
                DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/imgui)
        endforeach()
        imgui_export(${TARGET})
    elseif(ImGui)
        add_library(ImGui::${TARGET} ALIAS ${TARGET})
    else()
        include(${CMAKE_CURRENT_LIST_DIR}/ImGui${TARGET}.cmake)
    endif()
endfunction()

function(imgui_library TARGET INFIX_PATH)
    cmake_parse_arguments(TARGET "" "" "HEADERS;SOURCES;DEFINITIONS;PACKAGES;TARGETS;COMPILE_OPTIONS;LINK_OPTIONS" ${ARGN})
    if(ImGui AND "${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${ImGui_SRCDIR}/examples")
        if(ImGui_3RDPARTY)
            set(TARGET_DEPENDENCIES TRUE)
            foreach(PACKAGE ${TARGET_PACKAGES})
                find_package(${PACKAGE} QUIET)
                if(NOT ${PACKAGE}_FOUND)
                    message(AUTHOR_WARNING "Package ${PACKAGE} not found.")
                    string(TOUPPER "${PACKAGE}" PACKAGE_UPPER)
                    if(NOT ${PACKAGE_UPPER}_FOUND)
                        set(TARGET_DEPENDENCIES FALSE)
                        break()
                    endif()
                endif()
            endforeach()
            if(TARGET_DEPENDENCIES)
                foreach(INTERFACE_TARGET ${TARGET_TARGETS})
                    if(NOT TARGET ${INTERFACE_TARGET})
                        if(INTERFACE_TARGET STREQUAL "OpenGL::GL"
                            AND CMAKE_VERSION VERSION_LESS 3.8)
                            list(REMOVE_ITEM TARGET_TARGETS "${INTERFACE_TARGET}")
                            if(IS_ABSOLUTE "${OPENGL_gl_LIBRARY}")
                                message(AUTHOR_WARNING "Replace target ${INTERFACE_TARGET} to ${OPENGL_gl_LIBRARY}.")
                                list(APPEND TARGET_LIBRARIES "${OPENGL_gl_LIBRARY}")
                            else()
                                list(APPEND TARGET_TARGETS "${OPENGL_gl_LIBRARY}")
                            endif()
                        elseif(INTERFACE_TARGET STREQUAL "Freetype::Freetype")
                            list(REMOVE_ITEM TARGET_TARGETS "${INTERFACE_TARGET}")
                            if(IS_ABSOLUTE "${FREETYPE_LIBRARIES}")
                                message(AUTHOR_WARNING "Replace target ${INTERFACE_TARGET} to ${FREETYPE_LIBRARIES}.")
                                list(APPEND TARGET_LIBRARIES "${FREETYPE_LIBRARIES}")
                            else()
                                list(APPEND TARGET_TARGETS "${FREETYPE_LIBRARIES}")
                            endif()
                            list(APPEND TARGET_INCLUDE_DIRECTORIES "${FREETYPE_INCLUDE_DIRS}")
                        else()
                            message(WARNING "Target ${INTERFACE_TARGET} not found.")
                            set(TARGET_DEPENDENCIES FALSE)
                        endif()
                    endif()
                endforeach()
            endif()
            if(NOT TARGET_DEPENDENCIES)
                message(STATUS "Skip ${TARGET} library because not all dependencies found")
                return()
            endif()
        endif()
        add_library(${TARGET} INTERFACE)
        target_link_libraries(${TARGET} INTERFACE Core)
        foreach(HEADER ${TARGET_HEADERS})
            target_sources(${TARGET}
                INTERFACE
                    $<BUILD_INTERFACE:${ImGui_SRCDIR}/${INFIX_PATH}/${HEADER}>
                    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/imgui/${HEADER}>)
            install(FILES ${ImGui_SRCDIR}/${INFIX_PATH}/${HEADER}
                DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/imgui)
        endforeach()
        foreach(SOURCE ${TARGET_SOURCES})
            target_sources(${TARGET}
                INTERFACE
                    $<BUILD_INTERFACE:${ImGui_SRCDIR}/${INFIX_PATH}/${SOURCE}>
                    $<INSTALL_INTERFACE:${CMAKE_INSTALL_DATAROOTDIR}/imgui/${SOURCE}>)
            install(FILES ${ImGui_SRCDIR}/${INFIX_PATH}/${SOURCE}
                DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/imgui)
        endforeach()
        foreach(DEFINITION ${TARGET_DEFINITIONS})
            target_compile_definitions(${TARGET} INTERFACE ${DEFINITION})
        endforeach()
        target_include_directories(${TARGET} INTERFACE
            $<BUILD_INTERFACE:${ImGui_SRCDIR}/${INFIX_PATH}>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/imgui>)
        if(NOT ImGui_3RDPARTY)
            imgui_export(${TARGET})
            return()
        endif()
        if(";${TARGET_TARGETS};" MATCHES ";SDL2::SDL2;")
            get_target_property(SDL2_INCLUDE_DIR SDL2::SDL2 INTERFACE_INCLUDE_DIRECTORIES)
            if(EXISTS ${SDL2_INCLUDE_DIR}/SDL2)
                target_include_directories(${TARGET} INTERFACE
                    $<BUILD_INTERFACE:${SDL2_INCLUDE_DIR}/SDL2>
                    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/SDL2>)
            endif()
        endif()
        foreach(INTERFACE_TARGET ${TARGET_TARGETS})
            target_link_libraries(${TARGET}
                INTERFACE ${INTERFACE_TARGET})
        endforeach()
        foreach(INTERFACE_LIBRARY ${TARGET_LIBRARIES})
            target_link_libraries(${TARGET}
                INTERFACE $<BUILD_INTERFACE:${INTERFACE_LIBRARY}>)
        endforeach()
        foreach(INTERFACE_INCLUDE_DIRECTORIES ${TARGET_INCLUDE_DIRECTORIES})
            target_include_directories(${TARGET}
                INTERFACE $<BUILD_INTERFACE:${INTERFACE_INCLUDE_DIRECTORIES}>)
        endforeach()
        foreach(INTERFACE_COMPILE_OPTION ${TARGET_COMPILE_OPTIONS})
            target_compile_options(${TARGET}
                INTERFACE ${INTERFACE_COMPILE_OPTION})
        endforeach()
        foreach(INTERFACE_LINK_OPTION ${TARGET_LINK_OPTIONS})
            target_link_options(${TARGET}
                INTERFACE ${INTERFACE_LINK_OPTION})
        endforeach()
        imgui_export(${TARGET})
    elseif(ImGui)
        if(TARGET ${TARGET})
            list(APPEND ImGui_AVAILABLE_COMPONENTS ${TARGET})
            set(ImGui_AVAILABLE_COMPONENTS "${ImGui_AVAILABLE_COMPONENTS}" PARENT_SCOPE)
            if(";${ImGui_FIND_COMPONENTS};" MATCHES ";${TARGET};"
                AND NOT TARGET ImGui::${TARGET})
                add_library(ImGui::${TARGET} ALIAS ${TARGET})
            endif()
        endif()
    else()
        if(EXISTS ${CMAKE_CURRENT_LIST_DIR}/ImGui${TARGET}.cmake)
            list(APPEND ImGui_AVAILABLE_COMPONENTS ${TARGET})
            set(ImGui_AVAILABLE_COMPONENTS "${ImGui_AVAILABLE_COMPONENTS}" PARENT_SCOPE)
        endif()
        if(";${ImGui_FIND_COMPONENTS};" MATCHES ";${TARGET};")
            include(${CMAKE_CURRENT_LIST_DIR}/ImGui${TARGET}.cmake)
            if(ImGui_3RDPARTY)
                include(CMakeFindDependencyMacro)
                foreach(PACKAGE ${TARGET_PACKAGES})
                    find_dependency(${PACKAGE} REQUIRED)
                endforeach()
            else()
                message(STATUS "Please manualy link 3-rd party dependencies for ${TARGET} library")
            endif()
        endif()
    endif()
endfunction()

function(imgui_binding TARGET)
    list(APPEND ImGui_SUPPORTED_COMPONENTS ${TARGET})
    set(ImGui_SUPPORTED_COMPONENTS "${ImGui_SUPPORTED_COMPONENTS}" PARENT_SCOPE)
    if(NOT ImGui_BINDINGS)
        return()
    endif()
    imgui_library(${TARGET} examples ${ARGN})
    set(ImGui_AVAILABLE_COMPONENTS "${ImGui_AVAILABLE_COMPONENTS}" PARENT_SCOPE)
endfunction()

function(imgui_misc TARGET MISC_PATH)
    list(APPEND ImGui_SUPPORTED_COMPONENTS ${TARGET})
    set(ImGui_SUPPORTED_COMPONENTS "${ImGui_SUPPORTED_COMPONENTS}" PARENT_SCOPE)
    if(NOT ImGui_MISC)
        return()
    endif()
    set(INFIX_PATH "misc/${MISC_PATH}")
    imgui_library(${TARGET} ${INFIX_PATH} ${ARGN})
    set(ImGui_AVAILABLE_COMPONENTS "${ImGui_AVAILABLE_COMPONENTS}" PARENT_SCOPE)
endfunction()

function(imgui_example SUBDIRECTORY)
    if(NOT ImGui_EXAMPLES OR NOT ImGui_3RDPARTY)
        return()
    endif()
    cmake_parse_arguments(EXAMPLE "" "" "TARGETS;BINDINGS;MISC" ${ARGN})
    if(EXAMPLE_BINDINGS AND NOT ImGui_BINDINGS)
        return()
    endif()
    if(EXAMPLE_MISC AND NOT ImGui_MISC)
        return()
    endif()
    set(EXAMPLE_DEPENDENCIES TRUE)
    foreach(TARGET ${EXAMPLE_TARGETS} ${EXAMPLE_BINDINGS} ${EXAMPLE_MISC})
        if(NOT TARGET ${TARGET})
            set(EXAMPLE_DEPENDENCIES FALSE)
        endif()
    endforeach()
    if(EXAMPLE_DEPENDENCIES)
        add_subdirectory(${SUBDIRECTORY})
    else()
        message(STATUS "Skip ${SUBDIRECTORY} because not all dependencies found")
    endif()
endfunction()
