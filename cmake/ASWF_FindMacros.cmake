# Copyright (c) 2018 ASWF Build Util Project and contributors
# SPDX-License-Identifier: MIT

# find_package(<package> [version] [EXACT] [QUIET]
#              [REQUIRED] [[COMPONENTS] [components...]]
#              [CONFIG|NO_MODULE]
#              [NO_POLICY_SCOPE]
#              [NAMES name1 [name2 ...]]
#              [CONFIGS config1 [config2 ...]]
#              [HINTS path1 [path2 ... ]]
#              [PATHS path1 [path2 ... ]]
#              [PATH_SUFFIXES suffix1 [suffix2 ...]]
#              [NO_DEFAULT_PATH]
#              [NO_CMAKE_ENVIRONMENT_PATH]
#              [NO_CMAKE_PATH]
#              [NO_SYSTEM_ENVIRONMENT_PATH]
#              [NO_CMAKE_PACKAGE_REGISTRY]
#              [NO_CMAKE_BUILDS_PATH]
#              [NO_CMAKE_SYSTEM_PATH]
#              [NO_CMAKE_SYSTEM_PACKAGE_REGISTRY]
#              [CMAKE_FIND_ROOT_PATH_BOTH |
#               ONLY_CMAKE_FIND_ROOT_PATH |
#               NO_CMAKE_FIND_ROOT_PATH])
#
# TODO: Add flag to control usage of NO_CMAKE_PACKAGE_REGISTRY to avoid user's compile (which might be out of date for an install, but it might be desired for smaller facilities)
#
# TODO: Add flag to control usage of NO_CMAKE_SYSTEM_PATH / NO_CMAKE_SYSTEM_PACKAGE_REGISTRY for facilities that do not want to use system libraries but force it to find in an alternate location (i.e. vfx platform install)
#

if (ASWF_OVERRIDE_FIND)
  include(${ASWF_OVERRIDE_FIND})
else(ASWF_OVERRIDE_FIND)

macro(ASWF_FIND_PACKAGE package)
endmacro(ASWF_FIND_PACKAGE)

endif(ASWF_OVERRIDE_FIND)

