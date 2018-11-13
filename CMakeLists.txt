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
list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_CURRENT_LIST_DIR}/cmake)

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
project(MyProject VERSION 1.0.0 LANGUAGES C CXX)

# include common settings and macros from ASWF to make the rest of this easier
include(ASWF)
# if the defaults don't work for you...
#aswf_set_api_version(MyProject ${PROJECT_VERSION_MAJOR} ${PROJECT_VERSION_MINOR})
#aswf_set_so_version(MyProject 1)

# now that we have started the project, include the various configuration
# settings this project offers
include(Settings)

# Download any dependencies
# NB: this is NOT currently recommended, as facilities subject
# to MPAA security rules may have strict firewall rules
# preventing general outside access
#
#file(DOWNLOAD https://github.com/AcademySoftwareFoundation/build-utils/find/FindFoo.cmake ${CMAKE_CURRENT_BINARY_DIR}/FindFoo.cmake)

add_subdirectory(tests)
