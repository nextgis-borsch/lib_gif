################################################################################
# Project:  Lib GIF
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, dmitry.baryshnikov@nexgis.com
################################################################################
# Copyright (C) 2017, NextGIS <info@nextgis.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
################################################################################

cmake_minimum_required(VERSION 3.16.3 FATAL_ERROR)

project(gif)

if(NOT DEFINED PACKAGE_VENDOR)
    set(PACKAGE_VENDOR NextGIS)
endif()

if(NOT DEFINED PACKAGE_BUGREPORT)
    set(PACKAGE_BUGREPORT info@nextgis.com)
endif()

# Some init settings
set(CMAKE_COLOR_MAKEFILE ON)
# Set path to additional CMake modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

if(OSX_FRAMEWORK AND (BUILD_SHARED_LIBS OR BUILD_STATIC_LIBS))
  message(FATAL_ERROR "Only OSX_FRAMEWORK key or any or both BUILD_SHARED_LIBS
                       and BUILD_STATIC_LIBS keys are permitted")
endif()

if(CMAKE_GENERATOR_TOOLSET MATCHES "v([0-9]+)_xp")
    add_definitions(-D_WIN32_WINNT=0x0501)
endif()

include(${CMAKE_CURRENT_LIST_DIR}/cmake/util.cmake)
check_version(VERSION_MAJOR VERSION_MINOR VERSION_PATCH)
set(VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH})
set(PROJECT_VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH})
set(SO_VERSION "3.0")

if(OSX_FRAMEWORK)
    set(FRAMEWORK_VERSION "${VERSION_MAJOR}")
endif()

include(${CMAKE_CURRENT_LIST_DIR}/cmake/borsch/cmake/version.cmake)
report_version(${PROJECT_NAME} ${VERSION})

include (CheckIncludeFile)
check_include_file("limits.h" HAVE_LIMITS_H)
if(NOT HAVE_LIMITS_H)
    message(FATAL_ERROR "giflib needs limits.h to compile")
endif()
check_include_file("fcntl.h" HAVE_FCNTL_H)
if(NOT HAVE_FCNTL_H)
    message(FATAL_ERROR "giflib needs fcntl.h to compile")
endif()
check_include_file("stdint.h" HAVE_STDINT_H)
if(NOT HAVE_STDINT_H)
    message(FATAL_ERROR "giflib needs stdint.h to compile")
endif()
check_include_file("stdarg.h" HAVE_STDARG_H)
if(NOT HAVE_STDARG_H)
    message(FATAL_ERROR "giflib needs stdarg.h to compile")
endif()

if(WIN32)
    add_definitions( -D_USRDLL -D_WINDOWS )
endif()

set(PACKAGE_NAME ${PROJECT_NAME})

include(CheckFunctionExists)
check_function_exists(reallocarray HAVE_REALLOCARRAY)

set(SRCS
    dgif_lib.c
    egif_lib.c
    gif_err.c
    gif_font.c
    gif_hash.c
    gifalloc.c
    quantize.c
)

if(NOT HAVE_REALLOCARRAY)
    set(SRCS ${SRCS} openbsd-reallocarray.c)
    set(RA_FUN_NAME openbsd_reallocarray)
endif()

set(PUBLIC_HEADERS
    gif_hash.h
    gif_lib.h
)

set(HEADERS
    gif_lib_private.h
)

if(WIN32)
    configure_file(lib.def.in ${PROJECT_BINARY_DIR}/lib.def @ONLY)
    set(SRCS ${SRCS} ${PROJECT_BINARY_DIR}/lib.def)
    configure_file(${PROJECT_SOURCE_DIR}/cmake/unistd.h.in ${CMAKE_CURRENT_BINARY_DIR}/unistd.h COPYONLY)
    configure_file(${PROJECT_SOURCE_DIR}/cmake/getopt.h.in ${CMAKE_CURRENT_BINARY_DIR}/getopt.h COPYONLY)
endif()

set(LIB_NAME ${PROJECT_NAME})
if(BUILD_SHARED_LIBS)
    add_library(${LIB_NAME} SHARED ${SRCS} ${PUBLIC_HEADERS} ${HEADERS})
    set_target_properties (${LIB_NAME} PROPERTIES
        VERSION ${VERSION}
        SOVERSION ${SO_VERSION})
elseif(OSX_FRAMEWORK)
    add_library(${LIB_NAME} SHARED ${SRCS} ${PUBLIC_HEADERS} ${HEADERS})
    set_target_properties(${LIB_NAME} PROPERTIES
      FRAMEWORK TRUE
      FRAMEWORK_VERSION ${FRAMEWORK_VERSION}
      MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${VERSION}
      MACOSX_FRAMEWORK_BUNDLE_VERSION ${VERSION}
      MACOSX_FRAMEWORK_IDENTIFIER org.libgif.libgif
      XCODE_ATTRIBUTE_INSTALL_PATH "@rpath"
      PUBLIC_HEADER "${PUBLIC_HEADERS}"
      VERSION ${VERSION}
      SOVERSION ${SO_VERSION}
      )
else()
    add_library(${LIB_NAME} STATIC ${SRCS} ${PUBLIC_HEADERS} ${HEADERS})
endif()

# Add path to includes to build-tree export
target_include_directories(${LIB_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
)

# Applications installation ====================================================
set(noinst_PROGRAMS gifbg gifcolor giffilter gifhisto gifsponge gifwedge)
set(bin_PROGRAMS
	gif2rgb
	gifbuild
	gifecho
	giffix
	gifinto
	giftext
    giftool
    gifclrmp
)

option(GIF_BUILD_APPS "Build console applications" ON)
if(GIF_BUILD_APPS)
    macro(ADD_EXE target)
        add_executable(${target} ${target}.c getarg.c getarg.h qprintf.c)
        target_link_libraries(${target} ${PROJECT_NAME})
        if(OSX_FRAMEWORK)
            set_target_properties(${target} PROPERTIES INSTALL_RPATH "@executable_path/../../Library/Frameworks")
        endif()
    endmacro()

    foreach(target ${noinst_PROGRAMS} ${bin_PROGRAMS})
        add_exe(${target})
    endforeach()

    if(NOT SKIP_INSTALL_EXECUTABLES AND NOT SKIP_INSTALL_ALL )
        install(TARGETS ${bin_PROGRAMS}
        #    EXPORT ${INSTALL_TARGETS}
            RUNTIME DESTINATION ${INSTALL_BIN_DIR} COMPONENT applications
            ARCHIVE DESTINATION ${INSTALL_LIB_DIR} COMPONENT applications
            LIBRARY DESTINATION ${INSTALL_LIB_DIR} COMPONENT applications
            FRAMEWORK DESTINATION ${INSTALL_BIN_DIR}
        )
    endif()
endif()


# Testing ======================================================================
add_subdirectory(tests)

# Installing and packaging =====================================================
include(${CMAKE_CURRENT_LIST_DIR}/cmake/borsch/cmake/packaging.cmake)
create_borsch_package(${PACKAGE_NAME} 
    VENDOR ${PACKAGE_VENDOR}
    VERSION ${VERSION}
    TARGETS ${LIB_NAME}
    HEADERS ${PUBLIC_HEADERS}
)
