################################################################################
# Project:  external projects
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
################################################################################
# Copyright (C) 2017-2019, NextGIS <info@nextgis.com>
# Copyright (C) 2017-2019 Dmitry Baryshnikov
#
# This script is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this script.  If not, see <http://www.gnu.org/licenses/>.
################################################################################

include(${CMAKE_CURRENT_LIST_DIR}/borsch/cmake/version.cmake)

function(check_version major minor rev)
    # parse the version number from gif_lib.h and include in
    # major, minor and rev parameters
    set(VERSION_FILE ${CMAKE_CURRENT_SOURCE_DIR}/gif_lib.h)

    file(READ ${VERSION_FILE} _VERSION_H_CONTENTS)

    string(REGEX MATCH "GIFLIB_MAJOR[ \t]+([0-9]+)"
      _MAJOR_VERSION ${_VERSION_H_CONTENTS})
    string (REGEX MATCH "([0-9]+)"
      _MAJOR_VERSION ${_MAJOR_VERSION})
    string(REGEX MATCH "GIFLIB_MINOR[ \t]+([0-9]+)"
      _MINOR_VERSION ${_VERSION_H_CONTENTS})
    string (REGEX MATCH "([0-9]+)"
      _MINOR_VERSION ${_MINOR_VERSION})
    string(REGEX MATCH "GIFLIB_RELEASE[ \t]+([0-9]+)"
      _PATCH_VERSION ${_VERSION_H_CONTENTS})
    string (REGEX MATCH "([0-9]+)"
      _PATCH_VERSION ${_PATCH_VERSION})

    set(${major} ${_MAJOR_VERSION} PARENT_SCOPE)
    set(${minor} ${_MINOR_VERSION} PARENT_SCOPE)
    set(${rev} ${_PATCH_VERSION} PARENT_SCOPE)

    write_version(${VERSION_FILE} ${_MAJOR_VERSION} ${_MINOR_VERSION} ${_PATCH_VERSION})
endfunction(check_version)
