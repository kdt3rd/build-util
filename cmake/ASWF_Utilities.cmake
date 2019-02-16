# Copyright (c) 2018 ASWF Build Util Project and contributors
# SPDX-License-Identifier: MIT

####### Misc utility functions

########################################

# retrieve a target property, with a default if the property has
# not been set
#
# This was based on a sample macro found on the Kitware wiki
macro(ASWF_GET_TARGET_PROPERTY_WITH_DEFAULT _var _target _property _def_value)
  get_target_property(${_var} ${_target} ${_property})
  if (${_var} MATCHES NOTFOUND)
    set(${_var} ${_def_value})
  endif()
endmacro(ASWF_GET_TARGET_PROPERTY_WITH_DEFAULT)

########################################

# simple functions to enable a map-like data structure these won't
# handle escape sequences / substitutions but are faster than trying
# to handle that, and we are hopefully not doing that...

# default value (if any) following key argument, otherwise variable is unset...
macro(ASWF_MAP_GET _out_var _map _key)
  get_property(_aswf_tmp GLOBAL PROPERTY "${_map}.${_key}")
  if(_aswf_tmp)
    set(${_out_var} ${_aswf_tmp})
  else(_aswf_tmp)
    set(${_out_var} ${ARGN})
  endif()
endmacro(ASWF_MAP_GET)

macro(ASWF_MAP_SET map key)
  set_property(GLOBAL PROPERTY "${map}.${key}" "${ARGN}")
endmacro(ASWF_MAP_SET)

########################################

# not really meant to be used externally (although could be promoted
# if useful)
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
