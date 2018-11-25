#
#  Copyright 2018 Kimball Thurston
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

# aswf_enable_doxygen(
#   config_file
#   [ALWAYS]
#   )
#
macro(ASWF_ENABLE_DOXYGEN)
  option(ASWF_BUILD_DOXYGEN "Create and install the HTML API documentation (requires Doxygen)" FALSE)
  if(ASWF_BUILD_DOXYGEN)
    find_package(Doxygen)
    if(NOT DOXYGEN_FOUND)
      message(FATAL_ERROR "Unable to locate doxygen")
    endif()

    set(_aswf_always)
    set(_aswf_doxyin)
    set(_aswf_store _aswf_doxyin)
    foreach(_curarg ${ARGN})
      if(_curarg STREQUAL "ALWAYS")
        set(_aswf_always ALL)
      else()
        set(_aswf_doxyin "${_curarg}")
      endif()
    endforeach()
    if(NOT _aswf_doxyin)
      message(FATAL_ERROR "Missing doxygen configuration file")
    endif()

    get_filename_component(_aswf_doxydir "${_aswf_doxyin}" DIRECTORY)
    set(_aswf_doxyfile ${CMAKE_CURRENT_BINARY_DIR}/doxyfile)
    configure_file(${_aswf_doxyin} ${_aswf_doxyfile} @ONLY)
    add_custom_target(doc ${_aswf_always}
      COMMAND ${DOXYGEN_EXECUTABLE} ${_aswf_doxyfile}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${_aswf_doxydir}
      COMMENT "Generating API documentation with Doxygen"
      VERBATIM
      )
    install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/html DESTINATION ${CMAKE_INSTALL_DOCDIR})
  endif()
endmacro()
