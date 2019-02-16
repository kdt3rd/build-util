# Copyright (c) 2018 ASWF Build Util Project and contributors
# SPDX-License-Identifier: MIT

# aswf_setup_project_config_install(
#   [target1 target2 ...]
#   [VERSION_DISPOSITION version_disposition]
# )
#
# version_disposition should be the allowed version disposition for the find_package
# module version system (usually either SameMajorVersion or AnyNewerVersion)
macro(ASWF_SETUP_PROJECT_CONFIG_INSTALL _ver_disp)
  set(_aswf_ver_disp SameMajorVersion)
  unset(_aswf_extract_next)
  set(_aswf_targs)
  foreach(_curarg ${ARGN})
    if(_curarg STREQUAL "VERSION_DISPOSITION")
      set(_aswf_extract_next _aswf_ver_disp)
    else()
      if(_aswf_extract_next)
        set(${_aswf_extract_next} "${_curarg}" FORCE)
      else()
        #list(APPEND _aswf_targs "${_curarg}")
      endif()
    endif()
  endforeach()
  unset(_aswf_extract_next)
  
  set(_aswf_proj ${PROJECT_NAME})
  set(${_aswf_proj}_INSTALL_CONFIGDIR ${CMAKE_INSTALL_LIBDIR}/cmake/${_aswf_proj})
  # This is invalid until cmake 3.13 if things are in
  # separate folders. Although it's probably best to know
  # about headers, etc. as in the add_install macro
  #
  #install(TARGETS ${_aswf_targs}
  #  EXPORT ${_aswf_lowproj}-targets
  #  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  #  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  #  )
  if(_aswf_targs)
    set_target_properties(${_aswf_targs} PROPERTIES EXPORT_NAME ${_aswf_proj})
  endif()
  if(ASWF_HAS_EXTERNAL_TARGETS)
    install(EXPORT ${_aswf_proj}-targets
      FILE
        ${_aswf_proj}Targets.cmake
      NAMESPACE
        ${_aswf_proj}::
      DESTINATION
        ${${_aswf_proj}_INSTALL_CONFIGDIR}
      )
  endif()

  include(CMakePackageConfigHelpers)
  write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/${_aswf_proj}ConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY ${_aswf_ver_disp}
    )

  configure_package_config_file(${CMAKE_CURRENT_LIST_DIR}/cmake/${_aswf_proj}Config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/${_aswf_proj}Config.cmake
    INSTALL_DESTINATION ${${_aswf_proj}_INSTALL_CONFIGDIR}
    )

  if(DEFINED ASWF_VFXPLAT_DEPENDENCIES)
    message(FATAL_ERROR "TODO: add utility file for finding dependencies to install")
  endif()
  install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/${_aswf_proj}Config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/${_aswf_proj}ConfigVersion.cmake
    DESTINATION ${${_aswf_proj}_INSTALL_CONFIGDIR}
    )

  # export to user's local registry
  # TODO: add logic to remove <Project>Config.cmake from build tree
  # on install to invalidate user registry??? probably want a flag
  # to control that behavior so windows users aren't sad
  get_property(_aswf_exports GLOBAL PROPERTY "ASWF_${_aswf_proj}_HAS_EXPORTS" SET)
  if(_aswf_exports)
    export(EXPORT ${_aswf_proj}-targets FILE ${CMAKE_CURRENT_BINARY_DIR}/${_aswf_proj}Targets.cmake NAMESPACE ${_aswf_proj}::)
    install(
      EXPORT ${_aswf_proj}-targets
      FILE ${_aswf_proj}Targets.cmake
      NAMESPACE ${_aswf_proj}::
      DESTINATION ${${_aswf_proj}_INSTALL_CONFIGDIR}
      )
  endif()
  export(PACKAGE ${_aswf_proj})

  unset(_aswf_proj)
  unset(_aswf_targs)
  unset(_aswf_ver_disp)
endmacro()

# enables "package" target
#
# aswf_enable_package(
#   [TARGETS targ1 ...]
#   [VENDOR vendorstring]
#   [CONTACT email]
#   [WEBPAGE url]
#   [SUMMARY text]
#   [DESCRIPTION desc_file]
#   [ICON icon_file]
#   [LICENSE license_file]
# )
macro(ASWF_ENABLE_PACKAGE)
  find_file(_aswf_pack_license
    NAMES LICENSE LICENSE.txt LICENSE.md COPYING COPYING.txt
    PATHS ${CMAKE_CURRENT_SOURCE_DIR}
    NO_DEFAULT_PATH
    )
  unset(_aswf_extract_next)
  set(_asfw_pack_targs)
  set(_asfw_pack_vendor)
  set(_asfw_pack_contact)
  set(_asfw_pack_webpage)
  set(_asfw_pack_description)
  set(_asfw_pack_icon)
  set(_asfw_pack_license)
  set(_asfw_pack_summary)
  foreach(_curarg ${ARGN})
    if(_curarg STREQUAL "TARGETS")
      unset(_aswf_extract_next)
    elseif(_curarg STREQUAL "VENDOR")
      set(_aswf_extract_next _aswf_pack_vendor)
    elseif(_curarg STREQUAL "CONTACT")
      set(_aswf_extract_next _aswf_pack_contact)
    elseif(_curarg STREQUAL "WEBPAGE")
      set(_aswf_extract_next _aswf_pack_webpage)
    elseif(_curarg STREQUAL "DESCRIPTION")
      set(_aswf_extract_next _aswf_pack_description)
    elseif(_curarg STREQUAL "SUMMARY")
      set(_aswf_extract_next _aswf_pack_summary)
    elseif(_curarg STREQUAL "ICON")
      set(_aswf_extract_next _aswf_pack_icon)
    elseif(_curarg STREQUAL "LICENSE")
      set(_aswf_extract_next _aswf_pack_license)
    else()
      if(_aswf_extract_next)
        set(${_aswf_extract_next} "${_curarg}")
      else()
        list(APPEND _aswf_pack_targs "${_curarg}")
      endif()
    endif()
  endforeach()
  unset(_aswf_extract_next)

  # installation related settings
  set(CPACK_PROJECT_NAME                ${PROJECT_NAME})
  set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${_aswf_pack_summary}")
  set(CPACK_PROJECT_VERSION             "${PROJECT_VERSION}")
  set(CPACK_PROJECT_VERSION_MAJOR       "${PROJECT_VERSION_MAJOR}")
  set(CPACK_PROJECT_VERSION_MINOR       "${PROJECT_VERSION_MINOR}")
  set(CPACK_PROJECT_VERSION_PATCH       "${PROJECT_VERSION_PATCH}")
  set(CPACK_PACKAGE_VENDOR              ${_aswf_pack_vendor})
  set(CPACK_PACKAGE_CONTACT             ${_aswf_pack_contact})
  set(CPACK_PACKAGE_CONTACT             ${_aswf_pack_contact})
  set(CPACK_PACKAGE_DESCRIPTION_FILE    ${_aswf_pack_description})
  set(CPACK_RESOURCE_FILE_LICENSE       ${_aswf_pack_license})
  set(CPACK_SOURCE_IGNORE_FILES         "/\.git*;/\.cvs*;/release*;/build*;\.swp$;.*~;${CPACK_SOURCE_IGNORE_FILES}")
  set(CPACK_PACKAGE_ICON                ${_aswf_pack_icon})
  set(CPACK_SOURCE_GENERATOR            "STGZ;TBZ2;TZ;ZIP")
  set(CPACK_STRIP_FILES                 TRUE)
  set(CPACK_SOURCE_PACKAGE_FILE_NAME    "${CPACK_PROJECT_NAME}-${CPACK_PROJECT_VERSION}-src" )
  set(CPACK_SYSTEM_NAME                 "${CMAKE_SYSTEM_NAME}" )
  set(CPACK_PACKAGE_FILE_NAME           "${CPACK_PROJECT_NAME}-${CPACK_PROJECT_VERSION}-${CPACK_SYSTEM_NAME}" )
  if(WIN32 AND NOT UNIX)
    #set(CPACK_SOURCE_GENERATOR "ZIP")
    #set(CPACK_GENERATOR "NSIS")
    message(FATAL_ERROR "NYI: Need to set variables for win32 nsis installer")
  elseif(MACOSX)
    #set(CPACK_SOURCE_GENERATOR "TBZ2")
    #set(CPACK_GENERATOR "BUNDLE")
    message(FATAL_ERROR "NYI: Need to set scripts and variables for os/x installer")
  else()
    #set(CPACK_SOURCE_GENERATOR "TZ")
    #set(CPACK_GENERATOR "DEB")
  endif()
  include(CPack)
  unset(_asfw_pack_targs)
  unset(_asfw_pack_vendor)
  unset(_asfw_pack_contact)
  unset(_asfw_pack_webpage)
  unset(_asfw_pack_description)
  unset(_asfw_pack_icon)
  unset(_asfw_pack_license)
  unset(_asfw_pack_summary)
endmacro(ASWF_ENABLE_PACKAGE)
