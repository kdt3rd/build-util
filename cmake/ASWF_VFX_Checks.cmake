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

# TODO:
# - add arguments
#    - default version
#    - min version
#    - max version
# - make target specific instead of global?
macro(ASWF_ENABLE_VFX_PLATFORM)
  set(ASWF_VFXPLAT_VERSION "none" CACHE STRING "Version of the VFX Platform selected at configure time")
  # NB: the following does NOT prevent a user from saying
  #
  # cmake -DASWF_VFXPLAT_VERSION=foobar
  #
  # additional validation is required in order to ensure that the values are in
  # a particular list but this will provide a menu if they do run cmake-gui
  # we will do these checks later
  set_property(CACHE ASWF_VFXPLAT_VERSION PROPERTY STRINGS none VFX_2014 VFX_2015 VFX_2016 VFX_2017 VFX_2018 VFX_2019)

  # Now set up some variables based on the selection of the
  # VFX Platform version and validate the entry

  if(ASWF_VFXPLAT_VERSION STREQUAL "VFX_2014")
    set(ASWF_VFXLIB_VERSIONS gcc 4.1.2 python 2.7.3 qt 4.8.5 pyside 1.2 openexr 2.0.1 opensubdiv 2.3.3 alembic 1.5 fbx 2015 ocio 1.0.7 boost 1.53 tbb 4.1)
    set(CMAKE_CXX_STANDARD 98)
  elseif(ASWF_VFXPLAT_VERSION STREQUAL "VFX_2015")
    set(ASWF_VFXLIB_VERSIONS gcc 4.8.2 glibc 2.12 python 2.7 qt 4.8 pyside 1.2 openexr 2.2 opensubdiv 2.5 openvdb 3.0 alembic 1.5 fbx 2015 ocio 1.0.9 boost 1.55 tbb 4.2)
    set(CMAKE_CXX_STANDARD 98)
  elseif(ASWF_VFXPLAT_VERSION STREQUAL "VFX_2016")
    set(ASWF_VFXLIB_VERSIONS gcc 4.8.3 glibc 2.12 python 2.7.5 qt 5.6.1 pyqt 5.6 pyside 2.0 numpy 1.9.2 openexr 2.2 ptex 2.0.42 opensubdiv 3.0 openvdb 3 alembic 1.5.8 fbx 2015 ocio 1.0.9 aces 1.0 boost 1.55 tbb 4.3 mkl 11.3)
    set(CMAKE_CXX_STANDARD 11)
  elseif(ASWF_VFXPLAT_VERSION STREQUAL "VFX_2017")
    set(ASWF_VFXLIB_VERSIONS gcc 4.8.3 glibc 2.12 python 2.7.5 qt 5.6.1 pyqt 5.6 pyside 2.0 numpy 1.9.2 openexr 2.2 ptex 2.1.28 opensubdiv 3.1 openvdb 4 alembic 1.6 fbx 2015 ocio 1.0.9 aces 1.0 boost 1.61 tbb 4.4 mkl 11.3)
    set(CMAKE_CXX_STANDARD 11)
  elseif(ASWF_VFXPLAT_VERSION STREQUAL "VFX_2018")
    set(ASWF_VFXLIB_VERSIONS gcc 6.3.1 glibc 2.17 python 2.7.5 qt 5.6.1 pyqt 5.6 pyside 2.0 numpy 1.12.1 openexr 2.2 ptex 2.1.28 opensubdiv 3.3 openvdb 5 alembic 1.7 fbx 2018 ocio 1.0.9 aces 1.0.3 boost 1.61 tbb 2017.6 mkl 2017.2)
    set(CMAKE_CXX_STANDARD 14)
  elseif(ASWF_VFXPLAT_VERSION STREQUAL "VFX_2019")
    set(ASWF_VFXLIB_VERSIONS gcc 6.3.1 glibc 2.17 python 2.7.9 qt 5.12 pyqt 5.12 pyside 5.12 numpy 1.14.1 openexr 2.3 ptex 2.1.33 opensubdiv 3.3 openvdb 6 alembic 1.7 fbx 2019 ocio 1.1.0 aces 1.1 boost 1.66 tbb 2018 mkl 2018)
    set(CMAKE_CXX_STANDARD 14)
  elseif(ASWF_VFXPLAT_VERSION STREQUAL "none")
    # VFX Platform 2018 switches to c++14, so let's do that by default but
    # let the user configure as we are not constrained by anything VFX platform
    set(ASWF_CXX_STANDARD 14 CACHE STRING "C++ ISO Standard")
    # but switch gnu++14 or other extensions off for portability
    set(CMAKE_CXX_STANDARD ${ASWF_CXX_STANDARD})
  else()
    message(FATAL_ERROR "Invalid setting for ASWF_VFXPLAT_VERSION - must be [none|VFX_2014|VFX_2015|VFX_2016|VFX_2017|VFX_2018|VFX_2019]")
  endif()
endmacro(ASWF_ENABLE_VFX_PLATFORM)

macro(ASWF_FIND_VFX_LIB name)
endmacro(ASWF_FIND_VFX_LIB)

macro(ASWF_USE_VFX_LIBS)
  foreach(_curarg ${ARGN})
    aswf_find_vfx_lib(${_curarg})
  endforeach()
endmacro(ASWF_USE_VFX_LIBS)
