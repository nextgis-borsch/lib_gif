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

option(BUILD_TESTING "Build unit tests" OFF)
if(BUILD_TESTING)

    include(CTest)

    file(GLOB GIFS "${PROJECT_SOURCE_DIR}/pic/*.gif")
    file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/regress)

    # Test decompression and rendering by unpacking images,
    # converting them to RGB, and comparing that result to a check file.
    # render-regress
    foreach(test ${GIFS})
        get_filename_component(stem ${test} NAME_WE)
        add_test(NAME ${stem}-gif2rgb-regress1 COMMAND $<TARGET_FILE:gif2rgb> -1 -o ${CMAKE_CURRENT_BINARY_DIR}/regress/${stem}.rgb ${test})
        add_test(NAME ${stem}-gif2rgb-regress2 COMMAND ${CMAKE_COMMAND} -E compare_files
            ${CMAKE_CURRENT_BINARY_DIR}/regress/${stem}.rgb
            ${PROJECT_SOURCE_DIR}/tests/${stem}.rgb)
    endforeach()

    add_test(NAME gifbuild-regress2 COMMAND sh -c "$<TARGET_FILE:gifbuild> -d < ${PROJECT_SOURCE_DIR}/pic/gifgrid.gif > ${CMAKE_CURRENT_BINARY_DIR}/regress/gifgrid.ico")
    # add_test(NAME gifbuild-regress3 COMMAND ${CMAKE_COMMAND} -E compare_files ${CMAKE_CURRENT_BINARY_DIR}/regress/gifgrid.ico
    #     ${PROJECT_SOURCE_DIR}/tests/gifgrid.ico)

    add_test(NAME gifbuild-regress4 COMMAND sh -c "$<TARGET_FILE:gifbuild> -d < ${PROJECT_SOURCE_DIR}/pic/treescap.gif > ${CMAKE_CURRENT_BINARY_DIR}/regress/treescap.ico")
    add_test(NAME gifbuild-regress5 COMMAND ${CMAKE_COMMAND} -E compare_files ${CMAKE_CURRENT_BINARY_DIR}/regress/treescap.ico
            ${PROJECT_SOURCE_DIR}/tests/treescap.ico)

    add_test(NAME gifbuild-regress6 COMMAND sh -c "$<TARGET_FILE:gifbuild> < ${PROJECT_SOURCE_DIR}/pic/sample.ico | $<TARGET_FILE:gifbuild> -d > ${CMAKE_CURRENT_BINARY_DIR}/regress/sample-1.ico")
    add_test(NAME gifbuild-regress7 COMMAND sh -c "$<TARGET_FILE:gifbuild> < ${CMAKE_CURRENT_BINARY_DIR}/regress/sample-1.ico | $<TARGET_FILE:gifbuild> -d > ${CMAKE_CURRENT_BINARY_DIR}/regress/sample-2.ico")
    add_test(NAME gifbuild-regress8 COMMAND ${CMAKE_COMMAND} -E compare_files ${CMAKE_CURRENT_BINARY_DIR}/regress/sample-1.ico
    ${CMAKE_CURRENT_BINARY_DIR}/regress/sample-2.ico)

    add_test(NAME gifbuild-regress9 COMMAND sh -c "$<TARGET_FILE:gifbuild> -d < ${PROJECT_SOURCE_DIR}/pic/fire.gif > ${CMAKE_CURRENT_BINARY_DIR}/regress/fire1.ico")
    add_test(NAME gifbuild-regress10 COMMAND sh -c "$<TARGET_FILE:gifbuild> < ${CMAKE_CURRENT_BINARY_DIR}/regress/fire1.ico > ${CMAKE_CURRENT_BINARY_DIR}/regress/fire2.gif")
    add_test(NAME gifbuild-regress11 COMMAND sh -c "$<TARGET_FILE:gifbuild> -d < ${CMAKE_CURRENT_BINARY_DIR}/regress/fire2.gif > ${CMAKE_CURRENT_BINARY_DIR}/regress/fire2.ico")
    add_test(NAME gifbuild-regress12 COMMAND ${CMAKE_COMMAND} -E compare_files ${CMAKE_CURRENT_BINARY_DIR}/regress/fire1.ico
    ${CMAKE_CURRENT_BINARY_DIR}/regress/fire2.ico)

    foreach(test ${GIFS})
        get_filename_component(stem ${test} NAME_WE)
        add_test(NAME ${stem}-gifclrmp-regress1 COMMAND sh -c "$<TARGET_FILE:gifclrmp> < ${test} > ${CMAKE_CURRENT_BINARY_DIR}/regress/${stem}.map")
        add_test(NAME ${stem}-gifclrmp-regress2 COMMAND ${CMAKE_COMMAND} -E compare_files
            ${CMAKE_CURRENT_BINARY_DIR}/regress/${stem}.map
        ${PROJECT_SOURCE_DIR}/tests/${stem}.map)
    endforeach()

    add_test(NAME gifecho-regress1 COMMAND sh -c "$<TARGET_FILE:gifecho> -t \"foobar\" | $<TARGET_FILE:gifbuild> -d > ${CMAKE_CURRENT_BINARY_DIR}/regress/foobar.ico")
    add_test(NAME gifecho-regress2 COMMAND ${CMAKE_COMMAND} -E compare_files ${CMAKE_CURRENT_BINARY_DIR}/regress/foobar.ico
    ${PROJECT_SOURCE_DIR}/tests/foobar.ico)

    foreach(test ${GIFS})
        get_filename_component(stem ${test} NAME_WE)
        add_test(NAME ${stem}-giffilter-regress1 COMMAND sh -c "$<TARGET_FILE:giffilter> < ${test} | $<TARGET_FILE:gif2rgb> > ${CMAKE_CURRENT_BINARY_DIR}/regress/${stem}.rgb")
        add_test(NAME ${stem}-giffilter-regress2 COMMAND ${CMAKE_COMMAND} -E compare_files
            ${CMAKE_CURRENT_BINARY_DIR}/regress/${stem}.rgb
        ${PROJECT_SOURCE_DIR}/tests/${stem}.rgb)
    endforeach()

    add_test(NAME giffix-regress1 COMMAND sh -c "head -c 387 <${PROJECT_SOURCE_DIR}/pic/treescap.gif | $<TARGET_FILE:giffix> 2>/dev/null | $<TARGET_FILE:gifbuild> -d > ${CMAKE_CURRENT_BINARY_DIR}/regress/giffixed.ico")
    add_test(NAME giffix-regress2 COMMAND ${CMAKE_COMMAND} -E compare_files ${CMAKE_CURRENT_BINARY_DIR}/regress/giffixed.ico
    ${PROJECT_SOURCE_DIR}/tests/giffixed.ico)

    add_test(NAME gifinto-regress1 COMMAND sh -c "$<TARGET_FILE:gifinto> <${PROJECT_SOURCE_DIR}/pic/porsche.gif ${CMAKE_CURRENT_BINARY_DIR}/regress/giflib1.tmp")
    add_test(NAME gifinto-regress2 COMMAND sh -c "echo \"0123456789\" | $<TARGET_FILE:gifinto> ${CMAKE_CURRENT_BINARY_DIR}/regress/giflib2.tmp 2>/dev/null")

    foreach(test ${GIFS})
        get_filename_component(stem ${test} NAME_WE)
        add_test(NAME ${stem}-gifsponge-regress1 COMMAND sh -c "$<TARGET_FILE:gifsponge> < ${test} | $<TARGET_FILE:gif2rgb> >${CMAKE_CURRENT_BINARY_DIR}/regress/${stem}.rgb")
        add_test(NAME ${stem}-gifsponge-regress2 COMMAND ${CMAKE_COMMAND} -E compare_files
            ${CMAKE_CURRENT_BINARY_DIR}/regress/${stem}.rgb
        ${PROJECT_SOURCE_DIR}/tests/${stem}.rgb)
    endforeach()

    foreach(test ${GIFS})
        get_filename_component(stem ${test} NAME_WE)
        add_test(NAME ${stem}-giftext-regress1 COMMAND sh -c "$<TARGET_FILE:giftext> < ${test} >${CMAKE_CURRENT_BINARY_DIR}/regress/${stem}.dmp")
        add_test(NAME ${stem}-giftext-regress2 COMMAND ${CMAKE_COMMAND} -E compare_files
            ${CMAKE_CURRENT_BINARY_DIR}/regress/${stem}.dmp
        ${PROJECT_SOURCE_DIR}/tests/${stem}.dmp)
    endforeach()

    add_test(NAME giftool-regress1 COMMAND sh -c "$<TARGET_FILE:giftool> <${PROJECT_SOURCE_DIR}/pic/gifgrid.gif | $<TARGET_FILE:gif2rgb> >${CMAKE_CURRENT_BINARY_DIR}/regress/gifgrid.rgb")
    add_test(NAME giftool-regress2 COMMAND ${CMAKE_COMMAND} -E compare_files
        ${CMAKE_CURRENT_BINARY_DIR}/regress/gifgrid.rgb
    ${PROJECT_SOURCE_DIR}/tests/gifgrid.rgb)
    add_test(NAME giftool-regress3 COMMAND sh -c "$<TARGET_FILE:giftool> -i on <${PROJECT_SOURCE_DIR}/pic/treescap-interlaced.gif | $<TARGET_FILE:gif2rgb> >${CMAKE_CURRENT_BINARY_DIR}/regress/treescap.rgb")
    add_test(NAME giftool-regress4 COMMAND ${CMAKE_COMMAND} -E compare_files
        ${CMAKE_CURRENT_BINARY_DIR}/regress/treescap.rgb
    ${PROJECT_SOURCE_DIR}/tests/treescap.rgb)
    add_test(NAME giftool-regress5 COMMAND sh -c "$<TARGET_FILE:giftool> -i off <${PROJECT_SOURCE_DIR}/pic/treescap.gif | $<TARGET_FILE:gif2rgb> >${CMAKE_CURRENT_BINARY_DIR}/regress/treescap-interlaced.rgb")
    add_test(NAME giftool-regress6 COMMAND ${CMAKE_COMMAND} -E compare_files
        ${CMAKE_CURRENT_BINARY_DIR}/regress/treescap-interlaced.rgb
    ${PROJECT_SOURCE_DIR}/tests/treescap-interlaced.rgb)

    add_test(NAME gifwedge-regress1 COMMAND sh -c "$<TARGET_FILE:gifwedge> >${CMAKE_CURRENT_BINARY_DIR}/regress/wedge.gif")
    add_test(NAME gifwedge-regress2 COMMAND ${CMAKE_COMMAND} -E compare_files
        ${CMAKE_CURRENT_BINARY_DIR}/regress/wedge.gif
    ${PROJECT_SOURCE_DIR}/tests/wedge.gif)
endif()
