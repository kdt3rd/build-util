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

# Sample cmake file

# You should always require a minimal cmake version
# newer versions should be favored, if only to add new versions of MS visual studio
# support and the like
if (WIN32)
  cmake_minimum_required(VERSION 3.11 FATAL_ERROR)
else()
  cmake_minimum_required(VERSION 3.2 FATAL_ERROR)
endif()

# This auto sets various version number variables in project to
# the empty string
cmake_policy(SET CMP0048 NEW)

# Add our cmake macro / function path to the project
list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_CURRENT_LIST_DIR}/cmake")

###################
# Start the project
###################
# Set the project name and version number
# NB: this will auto-set PROJECT_VERSION, <PROJECT-NAME>_VERSION
# and all the related major/minor/patch/tweak variables
#
# NB2: If you are building multiple conceptual things within one tree that
# share a version, you may want to put a Version.cmake in the cmake folder
# and include that first, such that the version number is shared
#
# NB3: the project command is special to cmake, and if one is provided,
# even in a macro that is then called at the top level, and implicit
# project creation happens, which can subtly change the order things are
# searched for, among other issues
project(CoolColor VERSION 1.0.0 LANGUAGES C CXX)

# This is a local file you would have to replicate to be able
# to find the ASWF cmake setup...
include(EnableASWF)

# We will be providing a library, so create the generic settings for
# such a project
aswf_create_library_settings()

# This should be called at the beginning (before any add_subdirectory
# etc calls) when making a VFX platform enabled piece of software
aswf_enable_vfx_platform()

# run configure_file to generate a .h we will include in the release
configure_file(Config.h.in CoolColor/Config.h)
install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/CoolColor/Config.h
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/CoolColor
  )

add_subdirectory(src)
#add_subdirectory(tests)

# Set up the standard cmake config files for installation
# this takes a list of targets that you actually want to
# install
aswf_setup_project_config_install(CoolColor)

# This should be called at the root level.
#
# We are pulling the license file from the ASWF repo, but normally you
# would have a license file at the root, and this would work by
# default, assuming the license file has a default name
aswf_enable_package(
  VENDOR "Me"
  CONTACT "me@me.me"
  SUMMARY "A really cool color library"
  LICENSE ${CMAKE_CURRENT_SOURCE_DIR}/../../LICENSE
  )
