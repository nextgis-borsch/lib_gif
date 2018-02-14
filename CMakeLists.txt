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

if(OSX_FRAMEWORK)
  set(INSTALL_BIN_DIR "bin" CACHE INTERNAL "Installation directory for executables" FORCE)
  set(INSTALL_LIB_DIR "Library/Frameworks" CACHE INTERNAL "Installation directory for libraries" FORCE)
  set(INSTALL_INC_DIR "${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Headers" CACHE INTERNAL "Installation directory for headers" FORCE)
  set(INSTALL_CMAKECONF_DIR ${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Resources/CMake CACHE INTERNAL "Installation directory for cmake config files" FORCE)
  set(SKIP_INSTALL_HEADERS ON)
  set(SKIP_INSTALL_FILES ON)
  set(SKIP_INSTALL_EXPORT ON)
  set(CMAKE_MACOSX_RPATH ON)
  set(SKIP_INSTALL_DOCS ON)
else()
    include(GNUInstallDirs)

    set(INSTALL_BIN_DIR ${CMAKE_INSTALL_BINDIR} CACHE INTERNAL "Installation directory for executables" FORCE)
    set(INSTALL_LIB_DIR ${CMAKE_INSTALL_LIBDIR} CACHE INTERNAL "Installation directory for libraries" FORCE)
    set(INSTALL_INC_DIR ${CMAKE_INSTALL_INCLUDEDIR} CACHE INTERNAL "Installation directory for headers" FORCE)
    set(INSTALL_DOC_DIR ${CMAKE_INSTALL_DOCDIR} CACHE INTERNAL "Share directory for documents" FORCE)
    set(INSTALL_MAN_DIR ${CMAKE_INSTALL_MANDIR} CACHE INTERNAL "Share directory for manuals" FORCE)
    set(INSTALL_PKGCONFIG_DIR "${INSTALL_LIB_DIR}/pkgconfig" CACHE INTERNAL "Installation directory for pkgconfig (.pc) files" FORCE)
    set(INSTALL_CMAKECONF_DIR ${CMAKE_INSTALL_DATADIR}/${PROJECT_NAME}/CMake CACHE INTERNAL "Installation directory for cmake config files" FORCE)
    set(INSTALL_SHARE_DIR ${CMAKE_INSTALL_DATADIR} CACHE INTERNAL "Installation directory for share data" FORCE)
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

set(PACKAGE_NAME ${PROJECT_NAME})
string(TOUPPER ${PACKAGE_NAME} PACKAGE_UPPER_NAME)

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

if (NOT SKIP_INSTALL_DOCS AND NOT SKIP_INSTALL_ALL)
    install(FILES ${SHARE_FILES}
            DESTINATION ${INSTALL_SHARE_DIR}
            COMPONENT documents
        )
endif()

# Export package ===============================================================

if(REGISTER_PACKAGE)
    # Export the package for use from the build-tree
    # (this registers the build-tree with a global CMake-registry)
    export(PACKAGE ${PACKAGE_UPPER_NAME})
endif()

# Archiving ====================================================================

set(CPACK_PACKAGE_NAME "${PACKAGE_NAME}")
set(CPACK_PACKAGE_VENDOR "${PACKAGE_VENDOR}")
set(CPACK_PACKAGE_VERSION "${VERSION}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PACKAGE_NAME} Installation")
set(CPACK_PACKAGE_RELOCATABLE TRUE)
set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)
set(CPACK_GENERATOR "ZIP")
set(CPACK_MONOLITHIC_INSTALL ON)
set(CPACK_STRIP_FILES TRUE)

# Get cpack zip archive name
get_cpack_filename(${VERSION} PROJECT_CPACK_FILENAME)
set(CPACK_PACKAGE_FILE_NAME ${PROJECT_CPACK_FILENAME})

include(CPack)
