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

########################################

macro(ASWF_ADD_PLUGIN name)
  # don't use aswf_add_library here, it makes no sense to
  # switch on shared/static for a plugin
  message(FATAL_ERROR "Not Yet Finished")
  add_library(${name} MODULE ${ARGN})
  set_target_properties(${name} PROPERTIES PREFIX "" LIBRARY_OUTPUT_DIRECTORY ${CMAKE_PLUGIN_OUTPUT_PATH})
  set_property(GLOBAL PROPERTY "ASWF_${PROJECT_NAME}_HAS_EXPORTS" TRUE)
endmacro(ASWF_ADD_PLUGIN)

########################################

# Adds an executable and schedules it to be installed (as opposed to
# one that is only used locally for generating code or testing)
macro(ASWF_ADD_INSTALL_EXECUTABLE name)
  message(FATAL_ERROR "Not Yet Finished")
  set_property(GLOBAL PROPERTY "ASWF_${PROJECT_NAME}_HAS_EXPORTS" TRUE)
endmacro(ASWF_ADD_INSTALL_EXECUTABLE)

