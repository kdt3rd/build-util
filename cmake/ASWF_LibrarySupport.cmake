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

# setup / initialize the various options that should be used when
# making a project that creates and installs a library as one of it's
# deliverables
macro(ASWF_CREATE_LIBRARY_SETTINGS)

  # NB: We explicitly don't use the BUILD_SHARED_LIBS other than as the default
  # as we support building both shared and static at the same time
  # nb: generator expressions don't seem to work for options reliably?
  if(BUILD_SHARED_LIBS)
    set(_aswf_share_def ON)
    set(_aswf_stat_def OFF)
  else(BUILD_SHARED_LIBS)
    set(_aswf_share_def OFF)
    set(_aswf_stat_def ON)
  endif(BUILD_SHARED_LIBS)
  option(ASWF_BUILD_SHARED "Build Shared Libraries" ${_aswf_share_def})
  option(ASWF_BUILD_STATIC "Build Static Libraries" ${_aswf_stat_def})
  unset(_aswf_share_def)
  unset(_aswf_stat_def)

  # NB: This is not the same as CMAKE_STATIC_LIBRARY_SUFFIX: that is a
  # setting for the extension, where this is added to the name of the
  # static library itself (i.e. has to be in the -l command such as -lfoo_s)
  set(ASWF_STATIC_SUFFIX _s CACHE STRING "String to append to static library name (NOT extension)")

  if(NOT (ASWF_BUILD_SHARED OR ASWF_BUILD_STATIC))
    message(FATAL_ERROR "At least one of shared / static library must be enabled: shared ${ASWF_BUILD_SHARED} static ${ASWF_BUILD_STATIC}")
  endif()

  if(NOT PROJECT_NAME)
    message(FATAL_ERROR "Please start a top-level project before calling aswf_start_library")
  endif(NOT PROJECT_NAME)

  if(PROJECT_VERSION_MAJOR STREQUAL "" OR PROJECT_VERSION_MINOR STREQUAL "")
    message(FATAL_ERROR "Please declare a version number when you start your top-level project declaration")
  endif(PROJECT_VERSION_MAJOR STREQUAL "" OR PROJECT_VERSION_MINOR STREQUAL "")

  # TODO: add check whether cxx is enabled or do we care? most vfx projects use c++
  # if(CXX LIST_IN ENABLED_LANGUAGES)
  option(ASWF_NAMESPACE_VERSIONING "Use Namespace Versioning" ON)
  option(ASWF_DSO_VERSIONING "Enable DSO versioning" ON)
  set(ASWF_NAMESPACE ${PROJECT_NAME} CACHE STRING "Namespace name to use")

  if(ASWF_NAMESPACE_VERSIONING)
    set(PROJECT_VERSION_API ${PROJECT_VERSION_MAJOR}_${PROJECT_VERSION_MINOR})
    set(${PROJECT_NAME}_VERSION_API ${PROJECT_VERSION_API})
    set(PROJECT_LIBSUFFIX "-${PROJECT_VERSION_API}")
    set(${PROJECT_NAME}_LIBSUFFIX ${PROJECT_LIBSUFFIX})
  else(ASWF_NAMESPACE_VERSIONING)
    set(PROJECT_LIBSUFFIX "")
    set(${PROJECT_NAME}_LIBSUFFIX "")
  endif(ASWF_NAMESPACE_VERSIONING)

  string(TOUPPER ${PROJECT_NAME} _aswf_tmp)
  set(${_aswf_tmp}_NAMESPACE ${ASWF_NAMESPACE})
  set(${_aswf_tmp}_USE_NAMESPACE_VERSIONING ${ASWF_NAMESPACE_VERSIONING})
  # endif(CXX LIST_IN ENABLED_LANGUAGES)

  if(ASWF_DSO_VERSIONING)
    set(PROJECT_SOVERSION ${PROJECT_VERSION_MAJOR})
    set(${PROJECT_NAME}_SOVERSION ${PROJECT_SOVERSION})
  endif(ASWF_DSO_VERSIONING)
endmacro(ASWF_CREATE_LIBRARY_SETTINGS)

########################################

# Adds a library and schedules it to be installed (as opposed to one
# that is only used for compilation of local executables)
macro(ASWF_ADD_INSTALL_LIBRARY name)
  # TODO: do we have other flags to process in here?
  _intern_aswf_extract_source_headers(_src _pub_headers _priv_headers _defines ${ARGN})
  set(_targs)

  set(${name}_LIBSUFFIX "${PROJECT_LIBSUFFIX}")

  # TODO: this does not properly generate a framework under Apple - need
  #       to set the FRAMEWORK property if that is what is desired
  if(ASWF_BUILD_SHARED)
    set(_targs ${name})

    add_library(${name} SHARED ${_src})
    add_library(${PROJECT_NAME}::${name} ALIAS ${name})

    if(_defines)
      target_compile_definitions(${name} PRIVATE ${_defines})
    endif()
    if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
      target_compile_definitions(${name} PRIVATE $<UPPER_CASE:${name}>_DLL)
    endif()
    if(ASWF_DSO_VERSIONING)
      set_target_properties(${name}
        PROPERTIES
        POSITION_INDEPENDENT_CODE ON
        VERSION ${PROJECT_VERSION}
        SOVERSION ${PROJECT_SOVERSION}
        OUTPUT_NAME "${name}${${name}_LIBSUFFIX}"
        )
    else()
      set_target_properties(${name}
        PROPERTIES
        POSITION_INDEPENDENT_CODE ON
        VERSION ${PROJECT_VERSION}
        OUTPUT_NAME "${name}${${name}_LIBSUFFIX}"
        )
    endif()
    target_include_directories(${name}
      PUBLIC
        $<INSTALL_INTERFACE:include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
        $<BUILD_INTERFACE:${${PROJECT_NAME}_BINARY_DIR}/include>
        $<BUILD_INTERFACE:${${PROJECT_NAME}_BINARY_DIR}>
      PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
      )
  endif(ASWF_BUILD_SHARED)

  if(ASWF_BUILD_STATIC)
    if(DEFINED _targs)
      list(APPEND _targs ${name}_static)
    else(DEFINED _targs)
      set(_targs ${name}_static)
    endif(DEFINED _targs)

    add_library(${name}_static STATIC ${_src})
    add_library(${PROJECT_NAME}::${name}_static ALIAS ${name}_static)
    # if we aren't building shared, add aliases so the static lib name
    # will be used by default...
    if(NOT ASWF_BUILD_SHARED)
      add_library(${PROJECT_NAME}::${name} ALIAS ${name}_static)
    endif(NOT ASWF_BUILD_SHARED)

    set_target_properties(${name}_static
      PROPERTIES
      POSITION_INDEPENDENT_CODE ON
      VERSION ${PROJECT_VERSION}
      OUTPUT_NAME "${name}${${name}_LIBSUFFIX}${ASWF_STATIC_SUFFIX}"
      )
    target_include_directories(${name}_static
      PUBLIC
        $<INSTALL_INTERFACE:include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
        $<BUILD_INTERFACE:${${PROJECT_NAME}_BINARY_DIR}/include>
        $<BUILD_INTERFACE:${${PROJECT_NAME}_BINARY_DIR}>
      PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
      )
  endif(ASWF_BUILD_STATIC)

  # TODO: Eventually, this should move into the install related
  # elements, but until 3.13 of cmake it is an error to ask for an
  # install not in the same directory as the location where this macro
  # is called from, and that would normally be done at a top level
  if(DEFINED _targs)
    install(TARGETS ${_targs}
      EXPORT ${PROJECT_NAME}-targets
      ARCHIVE
        DESTINATION ${CMAKE_INSTALL_LIBDIR}
        COMPONENT ${PROJECT_NAME}
      LIBRARY
        DESTINATION ${CMAKE_INSTALL_LIBDIR}
        COMPONENT ${PROJECT_NAME}
        NAMELINK_COMPONENT Development
      )
    set_property(GLOBAL PROPERTY "ASWF_${PROJECT_NAME}_HAS_EXPORTS" TRUE)
  endif(DEFINED _targs)

  # rather than use the built-in install capabilities with PUBLIC_HEADER
  # properties, specify the public headers manually such that we
  # can set a different DESTINATION folder
  if(_pub_headers)
    install(FILES ${_pub_headers} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${name} COMPONENT Development)
  endif(_pub_headers)

  # This defines a source group to appear in visual studio and similar
  # generators generated files...
  if (_src)
    source_group("${PROJECT_NAME}\\${name}\\Source Files" FILES ${_src})
  endif(_src)
  if (_pub_headers)
    source_group("${PROJECT_NAME}\\${name}\\Public Headers" FILES ${_pub_headers})
  endif(_pub_headers)
  if (_priv_headers)
    source_group("${PROJECT_NAME}\\${name}\\Private Headers" FILES ${_priv_headers})
  endif(_priv_headers)

  unset(_targs)
  unset(_src)
  unset(_pub_headers)
  unset(_priv_headers)
endmacro(ASWF_ADD_INSTALL_LIBRARY)

# This is for libraries that are only used internally
# such as a library that contains source for unit tests
# This currently only builds a static library
macro(ASWF_ADD_INTERNAL_LIBRARY name)
  # TODO: do we have other flags to process in here?
  _intern_aswf_extract_source_headers(_src _pub_headers _priv_headers _defines ${ARGN})

  add_library(${name}_static STATIC ${_src})
  add_library(${PROJECT_NAME}::${name}_static ALIAS ${name}_static)
  add_library(${PROJECT_NAME}::${name} ALIAS ${name}_static)
  set_target_properties(${name}_static
    PROPERTIES
    POSITION_INDEPENDENT_CODE ON
    VERSION ${PROJECT_VERSION}
    OUTPUT_NAME "${name}${${name}_LIBSUFFIX}${ASWF_STATIC_SUFFIX}"
    )
  target_include_directories(${name}_static
    PUBLIC
      $<INSTALL_INTERFACE:include>
      $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
      $<BUILD_INTERFACE:${${PROJECT_NAME}_BINARY_DIR}/include>
      $<BUILD_INTERFACE:${${PROJECT_NAME}_BINARY_DIR}>
    PRIVATE
      ${CMAKE_CURRENT_SOURCE_DIR}
    )
  if (_src)
    source_group("${PROJECT_NAME}\\${name}\\Source Files" FILES ${_src})
  endif(_src)
  if (_pub_headers)
    source_group("${PROJECT_NAME}\\${name}\\Public Headers" FILES ${_pub_headers})
  endif(_pub_headers)
  if (_priv_headers)
    source_group("${PROJECT_NAME}\\${name}\\Private Headers" FILES ${_priv_headers})
  endif(_priv_headers)
endmacro(ASWF_ADD_INTERNAL_LIBRARY)

########################################

# Used to set the api version used in namespace versioning
macro(ASWF_SET_API_VERSION _proj _ver_maj _ver_min)
  set(${_proj}_VERSION_API ${_ver_maj}_${_ver_min})
  set(${_proj}_LIBSUFFIX "-${${_proj}_VERSION_API}")
endmacro(ASWF_SET_API_VERSION)

# Used to set the dso version used in producing shared libraries
macro(ASWF_SET_SO_VERSION _proj _ver)
  set(${_proj}_SOVERSION ${_ver})
endmacro(ASWF_SET_SO_VERSION)

# This was based on a sample macro found on the Kitware wiki but
# has added support for the libsuffix, etc.
macro(ASWF_CREATE_LIBTOOL_FILE _target _install_DIR)
  #set(_target_location $<TARGET_FILE:${_target}>)

  aswf_get_target_property_with_default(_target_static_lib ${_target} STATIC_LIB "")
  aswf_get_target_property_with_default(_target_dependency_libs ${_target} LT_DEPENDENCY_LIBS "")
  aswf_get_target_property_with_default(_target_current ${_target} LT_VERSION_CURRENT 0)
  aswf_get_target_property_with_default(_target_age ${_target} LT_VERSION_AGE 0)
  aswf_get_target_property_with_default(_target_revision ${_target} LT_VERSION_REVISION 0)
  aswf_get_target_property_with_default(_target_installed ${_target} LT_INSTALLED yes)
  aswf_get_target_property_with_default(_target_shouldnotlink ${_target} LT_SHOULDNOTLINK yes)
  aswf_get_target_property_with_default(_target_dlopen ${_target} LT_DLOPEN "")
  aswf_get_target_property_with_default(_target_dlpreopen ${_target} LT_DLPREOPEN "")
  set(_laname ${_target}${${_target}_LIBSUFFIX})
  set(_soname ${_laname})
  set(_laname ${PROJECT_BINARY_DIR}/${_laname}.la)

  file(WRITE ${_laname} "# ${_laname} - a libtool library file\n")
  file(APPEND ${_laname} "# Generated by CMake ${CMAKE_VERSION} (like GNU libtool)\n")
  file(APPEND ${_laname} "\n# Please DO NOT delete this file!\n# It is necessary for linking the library with libtool.\n\n" )
  file(APPEND ${_laname} "# The name that we can dlopen(3).\n")
  file(APPEND ${_laname} "dlname='${_soname}'\n\n")
  file(APPEND ${_laname} "# Names of this library.\n")
  file(APPEND ${_laname} "library_names='${_soname}.${_target_current}.${_target_age}.${_target_revision} ${_soname}.${_target_current} ${_soname}'\n\n")
  file(APPEND ${_laname} "# The name of the static archive.\n")
  file(APPEND ${_laname} "old_library='${_target_static_lib}'\n\n")
  file(APPEND ${_laname} "# Libraries that this one depends upon.\n")
  file(APPEND ${_laname} "dependency_libs='${_target_dependency_libs}'\n\n")
  file(APPEND ${_laname} "# Names of additional weak libraries provided by this library\n")
  file(APPEND ${_laname} "weak_library_names=\n\n")
  file(APPEND ${_laname} "# Version information for ${_laname}.\n")
  file(APPEND ${_laname} "current=${_target_current}\n")
  file(APPEND ${_laname} "age=${_target_age}\n")
  file(APPEND ${_laname} "revision=${_target_revision}\n\n")
  file(APPEND ${_laname} "# Is this an already installed library?\n")
  file(APPEND ${_laname} "installed=${_target_installed}\n\n")
  file(APPEND ${_laname} "# Should we warn about portability when linking against -modules?\n")
  file(APPEND ${_laname} "shouldnotlink=${_target_shouldnotlink}\n\n")
  file(APPEND ${_laname} "# Files to dlopen/dlpreopen\n")
  file(APPEND ${_laname} "dlopen='${_target_dlopen}'\n")
  file(APPEND ${_laname} "dlpreopen='${_target_dlpreopen}'\n\n")
  file(APPEND ${_laname} "# Directory that this library needs to be installed in:\n")
  file(APPEND ${_laname} "libdir='${CMAKE_INSTALL_PREFIX}${_install_DIR}'\n")
  install( FILES ${_laname} DESTINATION ${CMAKE_INSTALL_PREFIX}${_install_DIR})

  unset(_soname)
  unset(_laname)
endmacro(ASWF_CREATE_LIBTOOL_FILE)
