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

macro(_INTERN_ASWF_EXTRACT_SOURCE_HEADERS _outsrc _outpub _outpriv _outdefs)
  set(${_outsrc})
  set(${_outpub})
  set(${_outpriv})
  set(${_outdefs})
  set(_parse_list ${_outsrc})
  set(_is_file TRUE)
  foreach(_curarg ${ARGN})
    if(_curarg STREQUAL "PUBLIC")
      set(_parse_list ${_outpub})
      set(_is_file TRUE)
    elseif(_curarg STREQUAL "PRIVATE")
      set(_parse_list ${_outpriv})
      set(_is_file TRUE)
    elseif(_curarg STREQUAL "SOURCE")
      set(_parse_list ${_outsrc})
      set(_is_file TRUE)
    elseif(_curarg STREQUAL "DEFINES")
      set(_parse_list ${_outdefs})
      set(_is_file FALSE)
    else()
      if(_is_file)
        get_filename_component(_tmpfn "${_curarg}" ABSOLUTE)
        list(APPEND ${_parse_list} "${_tmpfn}")
      else()
        list(APPEND ${_parse_list} "${_curarg}")
      endif()
    endif()
  endforeach()
  unset(_is_file)
  unset(_parse_list)
  unset(_tmpfn)
  unset(_curarg)
endmacro(_INTERN_ASWF_EXTRACT_SOURCE_HEADERS)

# Adds a library and schedules it to be installed (as opposed to one
# that is only used for compilation of local executables)
macro(ASWF_ADD_INSTALL_LIBRARY name)
  # TODO: do we have other flags to process in here?
  _intern_aswf_extract_source_headers(_src _pub_headers _priv_headers _defines ${ARGN})
  set(_targs)

  # TODO: this does not properly generate a framework under Apple - need
  #       to set the FRAMEWORK property if that is what is desired
  if(ASWF_BUILD_SHARED)
    set(_targs ${name})

    add_library(${name} SHARED ${_src})
    add_library(${PROJECT_NAME}::${name} ALIAS ${name})

    if(_defines)
      target_compile_definitions(${name} PRIVATE ${_defines})
    endif()
    if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
      target_compile_definitions(${name} PUBLIC $<UPPER_CASE:${name}>_DLL)
    endif()
    if(ASWF_DSO_VERSIONING)
      set_target_properties(${name}
        PROPERTIES
        POSITION_INDEPENDENT_CODE ON
        VERSION ${PROJECT_VERSION}
        SOVERSION ${PROJECT_SOVERSION}
        OUTPUT_NAME "${name}${PROJECT_LIBSUFFIX}"
        )
    else()
      set_target_properties(${name}
        PROPERTIES
        POSITION_INDEPENDENT_CODE ON
        VERSION ${PROJECT_VERSION}
        OUTPUT_NAME "${name}${PROJECT_LIBSUFFIX}"
        )
    endif()
    target_include_directories(${name}
      PUBLIC
        $<INSTALL_INTERFACE:include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
        $<BUILD_INTERFACE:${${PROJECT_NAME}_BINARY_DIR}/include>
        $<BUILD_INTERFACE:${${PROJECT_NAME}_BINARY_DIR}>
      PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
      )
  endif(ASWF_BUILD_SHARED)

  if(ASWF_BUILD_STATIC)
    if(DEFINED _targs)
      list(APPEND _targs ${name}_static)
    else(DEFINED _targs)
      set(_targs ${name}_static)
    endif(DEFINED _targs)

    add_library(${name}_static STATIC ${_src})
    add_library(${PROJECT_NAME}::${name}_static ALIAS ${name}_static)

    set_target_properties(${name}_static
      PROPERTIES
      POSITION_INDEPENDENT_CODE ON
      VERSION ${PROJECT_VERSION}
      OUTPUT_NAME "${name}${PROJECT_LIBSUFFIX}_s"
      )
    target_include_directories(${name}_static
      PUBLIC
        $<INSTALL_INTERFACE:include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
        $<BUILD_INTERFACE:${${PROJECT_NAME}_BINARY_DIR}/include>
        $<BUILD_INTERFACE:${${PROJECT_NAME}_BINARY_DIR}>
      PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
      )
  endif(ASWF_BUILD_STATIC)

  # TODO: Eventually, this should move into the install related
  # elements, but until 3.13 of cmake it is an error to ask for an
  # install not in the same directory as the location where this macro
  # is called from, and that would normally be done at a top level
  if(DEFINED _targs)
    install(TARGETS ${_targs}
      EXPORT ${PROJECT_NAME}-targets
      ARCHIVE
        DESTINATION ${CMAKE_INSTALL_LIBDIR}
        COMPONENT ${PROJECT_NAME}
      LIBRARY
        DESTINATION ${CMAKE_INSTALL_LIBDIR}
        COMPONENT ${PROJECT_NAME}
        NAMELINK_COMPONENT Development
      )
    set_property(GLOBAL PROPERTY "ASWF_${PROJECT_NAME}_HAS_EXPORTS" TRUE)
  endif(DEFINED _targs)

  # rather than use the built-in install capabilities with PUBLIC_HEADER
  # properties, specify the public headers manually such that we
  # can set a different DESTINATION folder
  if(_pub_headers)
    install(FILES ${_pub_headers} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${name} COMPONENT Development)
  endif(_pub_headers)

  # This defines a source group to appear in visual studio and similar
  # generators generated files...
  if (_src)
    source_group("${PROJECT_NAME}\\Source Files" FILES ${_src})
  endif(_src)
  if (_pub_headers)
    source_group("${PROJECT_NAME}\\Public Headers" FILES ${_pub_headers})
  endif(_pub_headers)
  if (_priv_headers)
    source_group("${PROJECT_NAME}\\Private Headers" FILES ${_priv_headers})
  endif(_priv_headers)

  unset(_targs)
  unset(_src)
  unset(_pub_headers)
  unset(_priv_headers)
endmacro(ASWF_ADD_INSTALL_LIBRARY)

macro(ASWF_ADD_PLUGIN name)
  # don't use aswf_add_library here, it makes no sense to
  # switch on shared/static for a plugin
  message(FATAL_ERROR "Not Yet Finished")
  add_library(${name} MODULE ${ARGN})
  set_target_properties(${name} PROPERTIES PREFIX "" LIBRARY_OUTPUT_DIRECTORY ${CMAKE_PLUGIN_OUTPUT_PATH})
  set_property(GLOBAL PROPERTY "ASWF_${PROJECT_NAME}_HAS_EXPORTS" TRUE)
endmacro(ASWF_ADD_PLUGIN)

# Adds an executable and schedules it to be installed (as opposed to
# one that is only used locally for generating code or testing)
macro(ASWF_ADD_INSTALL_EXECUTABLE name)
  message(FATAL_ERROR "Not Yet Finished")
  set_property(GLOBAL PROPERTY "ASWF_${PROJECT_NAME}_HAS_EXPORTS" TRUE)
endmacro(ASWF_ADD_INSTALL_EXECUTABLE)

