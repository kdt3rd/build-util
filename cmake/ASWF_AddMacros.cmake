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
  set(_parse_src TRUE)
  set(_parse_pub FALSE)
  set(_parse_priv FALSE)
  set(_parse_defs FALSE)
  foreach(_curarg ${ARGN})
    if(_curarg STREQUAL "PUBLIC")
      set(_parse_src FALSE)
      set(_parse_pub TRUE)
      set(_parse_priv FALSE)
      set(_parse_defs FALSE)
    elseif(_curarg STREQUAL "PRIVATE")
      set(_parse_src FALSE)
      set(_parse_pub FALSE)
      set(_parse_priv TRUE)
      set(_parse_defs FALSE)
    elseif(_curarg STREQUAL "SOURCE")
      set(_parse_src TRUE)
      set(_parse_pub FALSE)
      set(_parse_priv FALSE)
      set(_parse_defs FALSE)
    elseif(_curarg STREQUAL "DEFINES")
      set(_parse_src FALSE)
      set(_parse_pub FALSE)
      set(_parse_priv FALSE)
      set(_parse_defs TRUE)
    else()
      if(_parse_src)
        get_filename_component(_tmpfn ${_curarg} ABSOLUTE)
        list(APPEND ${_outsrc} ${_tmpfn})
      elseif(_parse_pub)
        get_filename_component(_tmpfn ${_curarg} ABSOLUTE)
        list(APPEND ${_outpub} ${_tmpfn})
      elseif(_parse_priv)
        get_filename_component(_tmpfn ${_curarg} ABSOLUTE)
        list(APPEND ${_outpriv} ${_tmpfn})
      elseif(_parse_defs)
        list(APPEND ${_outdefs} ${_curarg})
      endif()
    endif()
  endforeach()
  unset(_parse_src)
  unset(_parse_pub)
  unset(_parse_priv)
  unset(_parse_defs)
  unset(_tmpfn)
  unset(_curarg)
endmacro(_INTERN_ASWF_EXTRACT_SOURCE_HEADERS)

# Adds an installed library (as opposed to one that is only
# used for compilation)
macro(ASWF_ADD_INSTALL_LIBRARY name)
  # TODO: do we have other flags to process in here?
  _intern_aswf_extract_source_headers(_src _pub_headers _priv_headers _defines ${ARGN})
  set(_targs)

  # rather than use the built-in install capabilities with PUBLIC_HEADER
  # properties, specify the public headers manually such that we
  # can set a different DESTINATION folder
  if(_pub_headers)
    install(FILES ${_pub_headers} DESTINATION include/${name})
  endif(_pub_headers)

  # TODO: this does not properly generate a framework under Apple - need
  #       to set the FRAMEWORK property if that is what is desired
  if(ASWF_BUILD_SHARED)
    set(_targs ${name})

    add_library(${name} SHARED ${_src})

    if(_defines)
      target_compile_definitions(${name} PRIVATE ${_defines})
    endif()
    if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
      target_compile_definitions(${name} PUBLIC $<UPPER_CASE:${name}>_DLL)
    endif()
    if(ASWF_DSO_VERSIONING)
      set_target_properties(${name}
        PROPERTIES
        VERSION ${PROJECT_VERSION}
        SOVERSION ${PROJECT_SOVERSION}
        OUTPUT_NAME "${name}${PROJECT_LIBSUFFIX}"
        )
    else()
      set_target_properties(${name}
        PROPERTIES
        VERSION ${PROJECT_VERSION}
        OUTPUT_NAME "${name}${PROJECT_LIBSUFFIX}"
        )
    endif()
  endif(ASWF_BUILD_SHARED)

  if(ASWF_BUILD_STATIC)
    if(DEFINED _targs)
      list(APPEND _targs ${name}_static)
    else(DEFINED _targs)
      set(_targs ${name}_static)
    endif(DEFINED _targs)

    add_library(${name}_static STATIC ${_src})

    set_target_properties(${name}_static
      PROPERTIES
      VERSION ${PROJECT_VERSION}
      OUTPUT_NAME "${name}${PROJECT_LIBSUFFIX}_s"
      )
  endif(ASWF_BUILD_STATIC)

  if(DEFINED _targs)
    install(TARGETS ${_targs}
      ARCHIVE
        DESTINATION lib
        COMPONENT ${PROJECT_NAME}
        NAMELINK_COMPONENT Development
      LIBRARY
        DESTINATION lib
        COMPONENT ${PROJECT_NAME}
      RUNTIME DESTINATION ${RUNTIME_DIR}
      PUBLIC_HEADER
        DESTINATION include
        COMPONENT Development
      )
  endif(DEFINED _targs)

  # This defines a source group to appear in visual studio
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
  add_library(${name} MODULE ${ARGN})
  set_target_properties(${name} PROPERTIES PREFIX "" LIBRARY_OUTPUT_DIRECTORY ${CMAKE_PLUGIN_OUTPUT_PATH})
endmacro(ASWF_ADD_PLUGIN)
