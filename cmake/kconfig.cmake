# SPDX-License-Identifier: MIT

# MIT License
# 
# Copyright (c) 2023 devjoa
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


set(KCONFIG_PREFIX "" CACHE STRING "Kconfig prefix value")
set(KCONFIG_ROOT "${CMAKE_SOURCE_DIR}/Kconfig" CACHE FILEPATH "Kconfig root configuration")
set(KCONFIG_CONFIG "${CMAKE_BINARY_DIR}/.config")
set(KCONFIG_HEADER "config.h" CACHE STRING "Kconfig include filename")


if (NOT EXISTS ${KCONFIG_CONFIG})
    if (DEFINED CONFIG_DEF)
        execute_process(
            COMMAND
                ${CMAKE_COMMAND} -E env
                    "KCONFIG_CONFIG=${KCONFIG_CONFIG}"
                    "CONFIG_=${KCONFIG_PREFIX}"
                    defconfig
                        --kconfig ${KCONFIG_ROOT}
                        "${CONFIG_DEF}"
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
    else()
        execute_process(
            COMMAND
                ${CMAKE_COMMAND} -E env
                    "KCONFIG_CONFIG=${KCONFIG_CONFIG}"
                    "CONFIG_=${KCONFIG_PREFIX}"
                    setconfig
                        --kconfig ${KCONFIG_ROOT}
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
    endif()
endif()
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${KCONFIG_CONFIG}")
file(
    STRINGS 
    "${KCONFIG_CONFIG}"
    ConfigContents 
    REGEX "^[A-Z]"
    ENCODING "UTF-8"
)
    
foreach(NameAndValue ${ConfigContents})
  # Create value
  string(REGEX MATCH "^[^=]+" Name "${NameAndValue}")
  # Find the value
  string(REPLACE "${Name}=" "" Value "${NameAndValue}")
  # Strip string "..." (if string)
  string(REGEX REPLACE "^\"(.*)\"$" "\\1" Value "${Value}")
  # Set the variable
  if(NOT DEFINED ${Name})
      set(${Name} "${Value}")
  endif()
endforeach()

unset(ConfigContents)
unset(NameAndValue)

execute_process(
    COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/.config_deps/include"
    COMMAND
        ${CMAKE_COMMAND} -E env
            "KCONFIG_CONFIG=${KCONFIG_CONFIG}"
            "CONFIG_=${KCONFIG_PREFIX}"
            genconfig
                --header-path "${CMAKE_BINARY_DIR}/.config_deps/include/${KCONFIG_HEADER}"
                "${KCONFIG_ROOT}"
            )
include_directories(SYSTEM "${CMAKE_BINARY_DIR}/.config_deps/include")

add_custom_target(
    menuconfig
    COMMAND
        ${CMAKE_COMMAND} -E env
            "KCONFIG_CONFIG=${KCONFIG_CONFIG}"
            "CONFIG_=${KCONFIG_PREFIX}"
            "MENUCONFIG_STYLE=aquatic"
            menuconfig
                "${CONFIG_DEF}"
    USES_TERMINAL
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})

add_custom_target(
    guiconfig
    COMMAND
        ${CMAKE_COMMAND} -E env
            "KCONFIG_CONFIG=${KCONFIG_CONFIG}"
            "CONFIG_=${KCONFIG_PREFIX}"
            guiconfig
                "${CONFIG_DEF}"
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})

add_custom_target(
    xconfig
    COMMAND
        ${CMAKE_COMMAND} -E env
            "KCONFIG_CONFIG=${KCONFIG_CONFIG}"
            "CONFIG_=${KCONFIG_PREFIX}"
            guiconfig
                "${CONFIG_DEF}"
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})

