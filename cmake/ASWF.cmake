# Copyright (c) 2018 ASWF Build Util Project and contributors
# SPDX-License-Identifier: MIT

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

# this has all the logic to construct gnu-compatible install folders
# and seems to be what modern projects are using, where the cmake config
# ends up in /usr/lib64/cmake/ProjectName/*.cmake
# rather than using the old FindProjectName.cmake mechanisms
#
# Given that these are just folder names, they are fine under windows
# etc.
include(GNUInstallDirs)

include(ASWF_Utilities)

include(ASWF_VFX_Checks)
include(ASWF_FindMacros)
include(ASWF_LibrarySupport)

# if the testing is enabled, we turn that on
option(ASWF_ENABLE_TESTS "Enable the tests" ON)
if(ASWF_ENABLE_TESTS)
  include(CTest)
  enable_testing()
  # we add a custom command "check" that will compile all the tests
  # first (if we add dependencies)
  add_custom_target(check COMMAND ${CMAKE_CTEST_COMMAND})
endif(ASWF_ENABLE_TESTS)

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

include(ASWF_AddMacros)
include(ASWF_DocMacros)
include(ASWF_InstallMacros)
