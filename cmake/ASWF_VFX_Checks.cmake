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

macro(ASWF_DETECT_LIBC_VERSION)
  # TODO: this won't work reliably if cross compiling, don't try for now
  if(NOT CMAKE_CROSSCOMPILING)
    if(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
      find_file(
        ASWF_LIBC_PATH libc.so.6
        HINTS /lib64 /lib ENV ASWF_OVERRIDE_LIBC_PATH
        DOC "Path to the version of libc in use"
        )
      if(ASWF_LIBC_PATH-NOTFOUND)
        message(FATAL_ERROR "Unable to determine path to libc in use")
      endif()
      execute_process(
        COMMAND ${ASWF_LIBC_PATH}
        RESULT_VARIABLE _aswf_run_ok
        OUTPUT_VARIABLE _aswf_libc_out
        ERROR_QUIET
        )
      if(_aswf_libc_out MATCHES "^.*release version ([0-9]+)\\.([0-9]+)\\..*$")
        set(ASWF_LIBC_VERSION ${CMAKE_MATCH_1}.${CMAKE_MATCH_2} CACHE STRING "Detected libc version")
        mark_as_advanced(ASWF_LIBC_PATH)
        mark_as_advanced(ASWF_LIBC_VERSION)
        message(STATUS "Detected libc ${ASWF_LIBC_PATH} version: ${ASWF_LIBC_VERSION}" )
      else()
        message(FATAL_ERROR "Unable to run libc to determine version in use")
      endif()
      unset(_aswf_run_ok)
      unset(_aswf_libc_out)
    endif()
  endif()
endmacro(ASWF_DETECT_LIBC_VERSION)

# Should only be called in scenarios where gcc is expected (i.e. under
# linux when validating the VFX Platform requirements)
macro(ASWF_VFX_TEST_GCC_VERSION _req_ver)
  option(ASWF_VFXPLAT_ALLOW_CLANG "When set, allows clang to be used instead of gcc (assumes you have set appropriate --gcc-toolchain" OFF)
  option(ASWF_VFXPLAT_ALLOW_INTEL "When set, allows the intel compiler to be used instead of gcc (assumes you have set appropriate flags" OFF)
  option(ASWF_VFXPLAT_WARN_NEWER_GCC "When set, allows the GCC compiler to be newer, demoting an error to a warning" OFF)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER "${_req_ver}")
      if(ASWF_VFXPLAT_WARN_NEWER_GCC)
        message("WARNING: Newer GCC version ${CMAKE_CXX_COMPILER_VERSION}, required maximum version: ${_req_ver}")
      else()
        message(SEND_ERROR "GCC version ${CMAKE_CXX_COMPILER_VERSION} detected, required maximum version: ${_req_ver}")
      endif()
    endif()
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    if(NOT ASWF_VFXPLAT_ALLOW_CLANG)
      message(SEND_ERROR "Clang compiler enabled, but override allowing clang instead of GCC not set")
    endif()
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
    if(NOT ASWF_VFXPLAT_ALLOW_INTEL)
      message(SEND_ERROR "Intel compiler enabled, but override allowing icc instead of GCC not set")
    endif()
  else()
    message(SEND_ERROR "Incompatible / unknown CXX Compiler testing against GCC: ${CMAKE_CXX_COMPILER_ID}")
  endif()
endmacro(ASWF_VFX_TEST_GCC_VERSION)

# TODO:
# - add arguments
#    - default version
#    - min version
#    - max version
# - make target specific instead of global?
macro(ASWF_ENABLE_VFX_PLATFORM)
  set(ASWF_VFXPLAT_VERSION "none" CACHE STRING "Version of the VFX Platform selected at configure time")
  if(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
    if(CMAKE_CROSSCOMPILING)
      set(_aswf_comp_check_def OFF)
    else()
      set(_aswf_comp_check_def ON)
    endif()
  else()
    set(_aswf_comp_check_def OFF)
  endif()
  option(ASWF_VFXPLAT_CHECK_COMPILER "Ensure compiler and libc matches VFX Platform specification" ${_aswf_comp_check_def})
  unset(_aswf_comp_check_def)

  set(CMAKE_CXX_EXTENSIONS OFF)

  set(ASWF_VALID_VFX_PLATFORMS none VFX_2014 VFX_2015 VFX_2016 VFX_2017 VFX_2018 VFX_2019)

  # NB: the following does NOT prevent a user from saying
  #
  # cmake -DASWF_VFXPLAT_VERSION=foobar
  #
  # additional validation is required in order to ensure that the values are in
  # a particular list but this will provide a menu if they do run cmake-gui
  # we will do these checks later
  set_property(CACHE ASWF_VFXPLAT_VERSION PROPERTY STRINGS ${ASWF_VALID_VFX_PLATFORMS})

  # Now set up some variables based on the selection of the
  # VFX Platform version and validate the entry

  if(ASWF_VFXPLAT_VERSION STREQUAL "VFX_2014")
    aswf_map_set(ASWF_VFXLIB_VERSIONS gcc 4.1.2)
    aswf_map_set(ASWF_VFXLIB_VERSIONS python 2.7.3)
    aswf_map_set(ASWF_VFXLIB_VERSIONS qt 4.8.5)
    aswf_map_set(ASWF_VFXLIB_VERSIONS pyside 1.2)
    aswf_map_set(ASWF_VFXLIB_VERSIONS openexr 2.0.1)
    aswf_map_set(ASWF_VFXLIB_VERSIONS opensubdiv 2.3.3)
    aswf_map_set(ASWF_VFXLIB_VERSIONS alembic 1.5)
    aswf_map_set(ASWF_VFXLIB_VERSIONS fbx 2015)
    aswf_map_set(ASWF_VFXLIB_VERSIONS ocio 1.0.7)
    aswf_map_set(ASWF_VFXLIB_VERSIONS boost 1.53)
    aswf_map_set(ASWF_VFXLIB_VERSIONS tbb 4.1)
    aswf_map_set(ASWF_VFXLIB_VERSIONS cxx_standard 98)
    set(CMAKE_CXX_STANDARD 98)
  elseif(ASWF_VFXPLAT_VERSION STREQUAL "VFX_2015")
    aswf_map_set(ASWF_VFXLIB_VERSIONS gcc 4.8.2)
    aswf_map_set(ASWF_VFXLIB_VERSIONS glibc 2.12)
    aswf_map_set(ASWF_VFXLIB_VERSIONS python 2.7)
    aswf_map_set(ASWF_VFXLIB_VERSIONS qt 4.8)
    aswf_map_set(ASWF_VFXLIB_VERSIONS pyside 1.2)
    aswf_map_set(ASWF_VFXLIB_VERSIONS openexr 2.2)
    aswf_map_set(ASWF_VFXLIB_VERSIONS opensubdiv 2.5)
    aswf_map_set(ASWF_VFXLIB_VERSIONS openvdb 3.0)
    aswf_map_set(ASWF_VFXLIB_VERSIONS alembic 1.5)
    aswf_map_set(ASWF_VFXLIB_VERSIONS fbx 2015)
    aswf_map_set(ASWF_VFXLIB_VERSIONS ocio 1.0.9)
    aswf_map_set(ASWF_VFXLIB_VERSIONS boost 1.55)
    aswf_map_set(ASWF_VFXLIB_VERSIONS tbb 4.2)
    aswf_map_set(ASWF_VFXLIB_VERSIONS cxx_standard 98)
    set(CMAKE_CXX_STANDARD 98)
  elseif(ASWF_VFXPLAT_VERSION STREQUAL "VFX_2016")
    # impossible to check for 4.8.2 w/ bugfix?
    aswf_map_set(ASWF_VFXLIB_VERSIONS gcc 4.8.3)
    aswf_map_set(ASWF_VFXLIB_VERSIONS glibc 2.12)
    aswf_map_set(ASWF_VFXLIB_VERSIONS python 2.7.5)
    aswf_map_set(ASWF_VFXLIB_VERSIONS qt 5.6.1)
    aswf_map_set(ASWF_VFXLIB_VERSIONS pyqt 5.6)
    aswf_map_set(ASWF_VFXLIB_VERSIONS pyside 2.0)
    aswf_map_set(ASWF_VFXLIB_VERSIONS numpy 1.9.2)
    aswf_map_set(ASWF_VFXLIB_VERSIONS openexr 2.2)
    aswf_map_set(ASWF_VFXLIB_VERSIONS ptex 2.0.42)
    aswf_map_set(ASWF_VFXLIB_VERSIONS opensubdiv 3.0)
    aswf_map_set(ASWF_VFXLIB_VERSIONS openvdb 3)
    aswf_map_set(ASWF_VFXLIB_VERSIONS alembic 1.5.8)
    aswf_map_set(ASWF_VFXLIB_VERSIONS fbx 2015)
    aswf_map_set(ASWF_VFXLIB_VERSIONS ocio 1.0.9)
    aswf_map_set(ASWF_VFXLIB_VERSIONS aces 1.0)
    aswf_map_set(ASWF_VFXLIB_VERSIONS boost 1.55)
    aswf_map_set(ASWF_VFXLIB_VERSIONS tbb 4.3)
    aswf_map_set(ASWF_VFXLIB_VERSIONS mkl 11.3)
    aswf_map_set(ASWF_VFXLIB_VERSIONS cxx_standard 11)
    set(CMAKE_CXX_STANDARD 11)
  elseif(ASWF_VFXPLAT_VERSION STREQUAL "VFX_2017")
    aswf_map_set(ASWF_VFXLIB_VERSIONS gcc 4.8.3)
    aswf_map_set(ASWF_VFXLIB_VERSIONS glibc 2.12)
    aswf_map_set(ASWF_VFXLIB_VERSIONS python 2.7.5)
    aswf_map_set(ASWF_VFXLIB_VERSIONS qt 5.6.1)
    aswf_map_set(ASWF_VFXLIB_VERSIONS pyqt 5.6)
    aswf_map_set(ASWF_VFXLIB_VERSIONS pyside 2.0)
    aswf_map_set(ASWF_VFXLIB_VERSIONS numpy 1.9.2)
    aswf_map_set(ASWF_VFXLIB_VERSIONS openexr 2.2)
    aswf_map_set(ASWF_VFXLIB_VERSIONS ptex 2.1.28)
    aswf_map_set(ASWF_VFXLIB_VERSIONS opensubdiv 3.3)
    aswf_map_set(ASWF_VFXLIB_VERSIONS openvdb 4)
    aswf_map_set(ASWF_VFXLIB_VERSIONS alembic 1.6)
    aswf_map_set(ASWF_VFXLIB_VERSIONS fbx 2015)
    aswf_map_set(ASWF_VFXLIB_VERSIONS ocio 1.0.9)
    aswf_map_set(ASWF_VFXLIB_VERSIONS aces 1.0)
    aswf_map_set(ASWF_VFXLIB_VERSIONS boost 1.61)
    aswf_map_set(ASWF_VFXLIB_VERSIONS tbb 4.4)
    aswf_map_set(ASWF_VFXLIB_VERSIONS mkl 11.3)
    aswf_map_set(ASWF_VFXLIB_VERSIONS cxx_standard 11)
    set(CMAKE_CXX_STANDARD 11)
  elseif(ASWF_VFXPLAT_VERSION STREQUAL "VFX_2018")
    aswf_map_set(ASWF_VFXLIB_VERSIONS gcc 6.3.1)
    aswf_map_set(ASWF_VFXLIB_VERSIONS glibc 2.17)
    aswf_map_set(ASWF_VFXLIB_VERSIONS python 2.7.5)
    aswf_map_set(ASWF_VFXLIB_VERSIONS qt 5.6.1)
    aswf_map_set(ASWF_VFXLIB_VERSIONS pyqt 5.6)
    aswf_map_set(ASWF_VFXLIB_VERSIONS pyside 2.0)
    aswf_map_set(ASWF_VFXLIB_VERSIONS numpy 1.12.1)
    aswf_map_set(ASWF_VFXLIB_VERSIONS openexr 2.2)
    aswf_map_set(ASWF_VFXLIB_VERSIONS ptex 2.1.28)
    aswf_map_set(ASWF_VFXLIB_VERSIONS opensubdiv 3.3)
    aswf_map_set(ASWF_VFXLIB_VERSIONS openvdb 5)
    aswf_map_set(ASWF_VFXLIB_VERSIONS alembic 1.7)
    aswf_map_set(ASWF_VFXLIB_VERSIONS fbx 2018)
    aswf_map_set(ASWF_VFXLIB_VERSIONS ocio 1.0.9)
    aswf_map_set(ASWF_VFXLIB_VERSIONS aces 1.0.3)
    aswf_map_set(ASWF_VFXLIB_VERSIONS boost 1.61)
    aswf_map_set(ASWF_VFXLIB_VERSIONS tbb 2017.6)
    aswf_map_set(ASWF_VFXLIB_VERSIONS mkl 2017.2)
    aswf_map_set(ASWF_VFXLIB_VERSIONS cxx_standard 14)
    set(CMAKE_CXX_STANDARD 14)
  elseif(ASWF_VFXPLAT_VERSION STREQUAL "VFX_2019")
    aswf_map_set(ASWF_VFXLIB_VERSIONS gcc 6.3.1)
    aswf_map_set(ASWF_VFXLIB_VERSIONS glibc 2.17)
    aswf_map_set(ASWF_VFXLIB_VERSIONS python 2.7.9)
    aswf_map_set(ASWF_VFXLIB_VERSIONS qt 5.12)
    aswf_map_set(ASWF_VFXLIB_VERSIONS pyqt 5.12)
    aswf_map_set(ASWF_VFXLIB_VERSIONS pyside 5.12)
    aswf_map_set(ASWF_VFXLIB_VERSIONS numpy 1.14.1)
    aswf_map_set(ASWF_VFXLIB_VERSIONS openexr 2.3)
    aswf_map_set(ASWF_VFXLIB_VERSIONS ptex 2.1.33)
    aswf_map_set(ASWF_VFXLIB_VERSIONS opensubdiv 3.3)
    aswf_map_set(ASWF_VFXLIB_VERSIONS openvdb 6)
    aswf_map_set(ASWF_VFXLIB_VERSIONS alembic 1.7)
    aswf_map_set(ASWF_VFXLIB_VERSIONS fbx 2019)
    aswf_map_set(ASWF_VFXLIB_VERSIONS ocio 1.1.0)
    aswf_map_set(ASWF_VFXLIB_VERSIONS aces 1.1)
    aswf_map_set(ASWF_VFXLIB_VERSIONS boost 1.66)
    aswf_map_set(ASWF_VFXLIB_VERSIONS tbb 2018)
    aswf_map_set(ASWF_VFXLIB_VERSIONS mkl 2018)
    aswf_map_set(ASWF_VFXLIB_VERSIONS cxx_standard 14)
    set(CMAKE_CXX_STANDARD 14)
  elseif(ASWF_VFXPLAT_VERSION STREQUAL "none")
    # VFX Platform 2018 switches to c++14, so let's do that by default but
    # let the user configure as we are not constrained by anything VFX platform
    set(ASWF_CXX_STANDARD 14 CACHE STRING "C++ ISO Standard")
    aswf_map_set(ASWF_VFXLIB_VERSIONS cxx_standard ${ASWF_CXX_STANDARD})
    set(CMAKE_CXX_STANDARD ${ASWF_CXX_STANDARD})
  else()
    message(FATAL_ERROR "Invalid setting for ASWF_VFXPLAT_VERSION - must be [none|VFX_2014|VFX_2015|VFX_2016|VFX_2017|VFX_2018|VFX_2019]")
  endif()

  if(ASWF_VFXPLAT_CHECK_COMPILER)
    if(NOT ASWF_VFXPLAT_VERSION STREQUAL "none")
      aswf_map_get(_aswf_tmp ASWF_VFXLIB_VERSIONS gcc)
      aswf_vfx_test_gcc_version(${_aswf_tmp})

      aswf_detect_libc_version()
      aswf_map_get(_aswf_tmp ASWF_VFXLIB_VERSIONS glibc)
      # early versions didn't specify glibc
      if(_aswf_tmp)
        if(ASWF_LIBC_VERSION VERSION_GREATER "${_aswf_tmp}")
          if(ASWF_VFXPLAT_WARN_NEWER_GCC)
            message("WARNING: Newer glibc version ${ASWF_LIBC_VERSION}, required maximum version: ${_aswf_tmp}")
          else()
            message(SEND_ERROR "glibc version ${ASWF_LIBC_VERSION} detected, required maximum version: ${_aswf_tmp}")
          endif()
        endif()
      endif()
    endif()
  endif()
endmacro(ASWF_ENABLE_VFX_PLATFORM)

macro(ASWF_FIND_VFX_LIB name)
endmacro(ASWF_FIND_VFX_LIB)

macro(ASWF_SET_VFX_PLATFORM_FLAGS name)
  aswf_map_get(_aswf_std ASWF_VFXLIB_VERSIONS cxx_standard 14)
  # we want vanilla c/c++ to maximize compiler portability
  if(TARGET ${name})
    set_target_properties(${name}
      PROPERTIES
      C_EXTENSIONS OFF
      CXX_EXTENSIONS OFF
      CXX_STANDARD_REQUIRED ON
      CXX_STANDARD ${_aswf_std}
      )
    target_compile_features(${name} PUBLIC cxx_std_${_aswf_std})
  endif()
  # also set it for the static library...
  if(TARGET ${name}_static)
    set_target_properties(${name}_static
      PROPERTIES
      C_EXTENSIONS OFF
      CXX_EXTENSIONS OFF
      CXX_STANDARD_REQUIRED ON
      CXX_STANDARD ${_aswf_std}
      )
    target_compile_features(${name}_static PUBLIC cxx_std_${_aswf_std})
  endif()
endmacro(ASWF_SET_VFX_PLATFORM_FLAGS)

macro(ASWF_FIND_VFX_LIB name)
endmacro(ASWF_FIND_VFX_LIB)

macro(ASWF_USE_VFX_LIBS target)
  foreach(_curarg ${ARGN})
    aswf_find_vfx_lib(${_curarg})
  endforeach()
endmacro(ASWF_USE_VFX_LIBS)

# Adds an installed library (as opposed to one that is only
# used for compilation), and enables any flags
macro(ASWF_ADD_VFX_INSTALL_LIBRARY name)
  aswf_add_install_library(${name} ${ARGN})
  aswf_set_vfx_platform_flags(${name})
endmacro(ASWF_ADD_VFX_INSTALL_LIBRARY)
