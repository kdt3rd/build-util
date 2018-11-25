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

# Add the ASWF cmake macro / function path to the project
# This path can be optionally specified by -DASWF_CMAKE_REPO
# Or it will use a global search path ASWF_CMAKE_MODULE_PATH to search for it
# enabling facilities who do not have direct internet access to pre-download
# the appropriate files, or to have them in an alternate location
if(DEFINED ASWF_CMAKE_REPO)
  set(ASWF_MASTER_CMAKE_REPO ${ASWF_CMAKE_REPO} CACHE INTERNAL "Path to ASWF cmake files")
endif()
if(DEFINED ASWF_MASTER_CMAKE_REPO)
  set(ASWF_MASTER_CMAKE_REPO ${ASWF_MASTER_CMAKE_REPO} CACHE INTERNAL "Path to ASWF cmake files")
else()
  if(DEFINED ASWF_CMAKE_MODULE_PATH)
    string(REPLACE ":" ";" _tmp_path ${ASWF_CMAKE_MODULE_PATH})
    find_package(ASWF_Cmake 1.0 REQUIRED CONFIG HINTS ${_tmp_path})
    set(ASWF_MASTER_CMAKE_REPO ${ASWF_Cmake_CMAKE_DIR} CACHE INTERNAL "Path to ASWF cmake files")
    unset(_tmp_path)
  else()
    find_package(ASWF_Cmake 1.0 REQUIRED CONFIG)
    set(ASWF_MASTER_CMAKE_REPO ${ASWF_Cmake_CMAKE_DIR} CACHE INTERNAL "Path to ASWF cmake files")
  endif()
  if(NOT ASWF_Cmake_FOUND)
    message("WARNING: Unable to find the ASWF cmake package, cloning...")
    include(ExternalProject)
    ExternalProject_Add(ASWF_Cmake
      GIT_REPOSITORY    https://github.com/kdt3rd/build-util.git
      GIT_TAG           master
      GIT_SHALLOW       ON
      PREFIX            "${CMAKE_BINARY_DIR}/ASWF_Cmake"
      CONFIGURE_COMMAND ""
      BUILD_COMMAND     ""
      INSTALL_COMMAND   ""
      TEST_COMMAND      ""
      )
    set(ASWF_MASTER_CMAKE_REPO "${CMAKE_BINARY_DIR}/ASWF_Cmake/src/ASWF_Cmake/cmake" CACHE INTERNAL "Path to ASWF cmake files")
  endif()
endif()

# insert it at the front of the module path to give preference...
list(INSERT CMAKE_MODULE_PATH 0 "${ASWF_MASTER_CMAKE_REPO}")

include(ASWF)
