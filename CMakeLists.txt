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

# NB: This is not a canonical cmake file to use as a template to set
# up your project. Instead, this is the cmake file used to actually
# install this project (or create a package to be able to do so)
#
# If you are looking for a sample project file with comments, please
# see the samples folder
cmake_minimum_required(VERSION 3.3 FATAL_ERROR)
cmake_policy(SET CMP0048 NEW)

list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_CURRENT_LIST_DIR}/cmake)

project(ASWF_Cmake VERSION 1.0.0)

include(ASWF)

aswf_setup_project_config_install(VERSION_DISPOSITION AnyNewerVersion)

# we do this configure_file stuff to make it such that local user
# repos that are "made" and exported will function correctly without
# having to have special checks in the ASWF_CmakeConfig.cmake
macro(DUP_FILES_TO_BINARY_AND_INSTALL)
  set(_filelist)
  foreach(_curarg ${ARGN})
    get_filename_component(_curfile "${_curarg}" NAME)
    configure_file(${_curarg} ${CMAKE_CURRENT_BINARY_DIR}/${_curfile} COPYONLY)
    list(APPEND _filelist ${CMAKE_CURRENT_BINARY_DIR}/${_curarg})
  endforeach()
  install(
    FILES ${_filelist}
    DESTINATION ${${PROJECT_NAME}_INSTALL_CONFIGDIR}
    )
endmacro(DUP_FILES_TO_BINARY_AND_INSTALL)

dup_files_to_binary_and_install(
  cmake/ASWF.cmake
  cmake/ASWF_AddMacros.cmake
  cmake/ASWF_DocMacros.cmake
  cmake/ASWF_InstallMacros.cmake
  cmake/ASWF_Utilities.cmake
  cmake/ASWF_VarMap.cmake
  cmake/ASWF_VFX_Checks.cmake
  )

if(ASWF_ENABLE_TESTS)
  add_subdirectory(tests)
endif()

aswf_enable_package(VENDOR "Me" CONTACT "me@me.me" SUMMARY "cmake utility macros for ASWF / VFX Platform or any other package")
