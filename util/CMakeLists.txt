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

include_directories (${PROJECT_SOURCE_DIR}/lib)

if(UNIX)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}  -fno-builtin -g -W -Wreturn-type -Wcomment")
endif()

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

set(bin_PROGRAMS2
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
