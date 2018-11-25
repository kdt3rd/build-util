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

#
# This file is contains a set of functions / macros
# that make writing VFX platform compliant cmake files
# easier.
#
# Additionally, it defines common options that are considered
# to be common / considerate options to provide in all projects
# this makes it easier to script the building of an entire
# suite of software by using common names for common variables

# simple functions to enable a map-like data structure these won't
# handle escape sequences / substitutions but are faster than trying
# to handle that, and we are hopefully not doing that...

# default value (if any) following key argument, otherwise variable is unset...
macro(MAP_GET _out_var _map _key)
  get_property(_aswf_tmp GLOBAL PROPERTY "${_map}.${_key}")
  if(_aswf_tmp)
    set(${_out_var} ${_aswf_tmp})
  else(_aswf_tmp)
    set(${_out_var} ${ARGN})
  endif()
endmacro(MAP_GET)

macro(MAP_SET map key)
  set_property(GLOBAL PROPERTY "${map}.${key}" "${ARGN}")
endmacro(MAP_SET)
