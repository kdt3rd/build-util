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

# common options to expose to the configure tool/script

option(ASWF_BUILD_SHARED "Build Shared Libraries" ON)
option(ASWF_BUILD_STATIC "Build Static Libraries" OFF)

option(ASWF_ENABLE_TESTS "Enable the tests" ON)

option(ASWF_NAMESPACE_VERSIONING "Use Namespace Versioning" ON)
option(ASWF_DSO_VERSIONING "Enable DSO versioning" ON)

include(ASWF_VFX_Checks)

##########

if(ASWF_NAMESPACE_VERSIONING)
  if(PROJECT_VERSION_MAJOR STREQUAL "" OR PROJECT_VERSION_MINOR STREQUAL "")
    message(FATAL_ERROR "In order to enable namespace versioning, please include ASWF.cmake file after declaring your top level project with major.minor version number")
  endif(PROJECT_VERSION_MAJOR STREQUAL "" OR PROJECT_VERSION_MINOR STREQUAL "")
  set(PROJECT_VERSION_API ${PROJECT_VERSION_MAJOR}_${PROJECT_VERSION_MINOR})
  set(${PROJECT_NAME}_VERSION_API ${PROJECT_VERSION_API})
  set(PROJECT_LIBSUFFIX "-${PROJECT_VERSION_API}")
  set(${PROJECT_NAME}_LIBSUFFIX ${PROJECT_LIBSUFFIX})
else(ASWF_NAMESPACE_VERSIONING)
  set(PROJECT_LIBSUFFIX "")
  set(${PROJECT_NAME}_LIBSUFFIX "")
endif(ASWF_NAMESPACE_VERSIONING)

if(ASWF_DSO_VERSIONING)
  if(PROJECT_VERSION_MAJOR STREQUAL "")
    message(FATAL_ERROR "In order to enable namespace versioning, please include ASWF.cmake file after declaring your top level project with major.minor version number")
  endif(PROJECT_VERSION_MAJOR STREQUAL "")
  set(PROJECT_SOVERSION ${PROJECT_VERSION_MAJOR})
  set(${PROJECT_NAME}_SOVERSION ${PROJECT_SOVERSION})
endif(ASWF_DSO_VERSIONING)

# if the testing is enabled, we turn that on
if(ASWF_ENABLE_TESTS)
  include(CTest)
  enable_testing()
endif(ASWF_ENABLE_TESTS)

# installation related settings
set(CPACK_PROJECT_NAME             ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION          ${PROJECT_VERSION})
set(CPACK_SOURCE_IGNORE_FILES      "/.git*;/.cvs*;${CPACK_SOURCE_IGNORE_FILES}")
set(CPACK_SOURCE_GENERATOR         "TGZ")
set(CPACK_SOURCE_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${PROJECT_VERSION}" )
include(CPack)

# MacOS & linux rpathing, meaning things can be run in-place,
# and are correctly re-linked upon install to pull any DSO
# from the install location, eliminating the need for any
# LD_LIBRARY_PATH shenanigans
if(APPLE)
  set(CMAKE_MACOSX_RPATH 1)
endif(APPLE)
set(BUILD_WITH_INSTALL_RPATH 1)

# Set position independent code (mostly for static builds, but not a bad idea regardless)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# set a postfix on output names to handle debug vs. opt naming
# if that is necessary
IF(WIN32)
  SET(CMAKE_DEBUG_POSTFIX "_d")
ENDIF()

include(ASWF_Utilities)
include(ASWF_AddMacros)
