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

cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)

project(gif)

# Some init settings
set(CMAKE_COLOR_MAKEFILE ON)
# Set path to additional CMake modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

if(OSX_FRAMEWORK AND (BUILD_SHARED_LIBS OR BUILD_STATIC_LIBS))
  message(FATAL_ERROR "Only OSX_FRAMEWORK key or any or both BUILD_SHARED_LIBS
                       and BUILD_STATIC_LIBS keys are permitted")
endif()

if(OSX_FRAMEWORK)
  set(INSTALL_BIN_DIR "${CMAKE_INSTALL_PREFIX}/bin" CACHE INTERNAL "Installation directory for executables" FORCE)
  set(INSTALL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/Library/Frameworks" CACHE INTERNAL "Installation directory for libraries" FORCE)
  set(INSTALL_INC_DIR "${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Headers" CACHE INTERNAL "Installation directory for headers" FORCE)
  set(SKIP_INSTALL_HEADERS ON)
  set(SKIP_INSTALL_FILES ON)
  set(SKIP_INSTALL_EXPORT ON)
  set(CMAKE_MACOSX_RPATH ON)
  set(SKIP_INSTALL_DOCS ON)
else()
    include(GNUInstallDirs)

    set(INSTALL_BIN_DIR ${CMAKE_INSTALL_FULL_BINDIR} CACHE INTERNAL "Installation directory for executables" FORCE)
    set(INSTALL_LIB_DIR ${CMAKE_INSTALL_FULL_LIBDIR} CACHE INTERNAL "Installation directory for libraries" FORCE)
    set(INSTALL_INC_DIR ${CMAKE_INSTALL_FULL_INCLUDEDIR} CACHE INTERNAL "Installation directory for headers" FORCE)
    set(INSTALL_DOC_DIR ${CMAKE_INSTALL_FULL_DOCDIR} CACHE INTERNAL "Share directory for documents" FORCE)
    set(INSTALL_MAN_DIR ${CMAKE_INSTALL_FULL_MANDIR} CACHE INTERNAL "Share directory for manuals" FORCE)
endif()

if(CMAKE_GENERATOR_TOOLSET MATCHES "v([0-9]+)_xp")
    add_definitions(-D_WIN32_WINNT=0x0501)
endif()

include(util)
check_version(VERSION_MAJOR VERSION_MINOR VERSION_PATCH)
set(VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH})
set(PROJECT_VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH})
set(SO_VERSION "3.0")

if(OSX_FRAMEWORK)
    set(FRAMEWORK_VERSION "${VERSION_MAJOR}")
endif()
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

add_subdirectory(lib)
add_subdirectory(util)
enable_testing()
add_subdirectory(tests)
add_subdirectory(doc)

set(SHARE_FILES
    AUTHORS
    COPYING
    NEWS
)

if (REGISTER_PACKAGE)
    export(TARGETS ${PROJECT_NAME} FILE ${PROJECT_NAME}-exports.cmake)

    set(EXPORT_PACKAGE_NAME GIF)
    string(TOUPPER ${EXPORT_PACKAGE_NAME} EXPORT_PACKAGE_NAME_UPPER)
    set(EXPORT_PACKAGE_LIB_NAME ${PROJECT_NAME})

    export(PACKAGE ${EXPORT_PACKAGE_NAME})

    include(CMakePackageConfigHelpers)
    configure_package_config_file(
        ${CMAKE_SOURCE_DIR}/cmake/PackageConfig.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/${EXPORT_PACKAGE_NAME}Config.cmake
        INSTALL_DESTINATION ${CMAKE_CURRENT_BINARY_DIR} )
    write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/${EXPORT_PACKAGE_NAME}ConfigVersion.cmake
        VERSION ${VERSION}
        COMPATIBILITY AnyNewerVersion )
else()
    export(TARGETS ${PROJECT_NAME} FILE ${PROJECT_NAME}-exports.cmake EXPORT_LINK_INTERFACE_LIBRARIES)
endif()

if (NOT SKIP_INSTALL_DOCS AND NOT SKIP_INSTALL_ALL)
    install(FILES ${SHARE_FILES}
            DESTINATION ${INSTALL_SHARE_DIR}
            COMPONENT documents
        )
endif()
