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

set(CoolColor_SOURCE
  xyY.cpp
  )

set(CoolColor_PUBHEADERS
  xyY.h
  )

# This isn't really necessary for compiling but is included here for
# those who generate things such as visual studio projects and want to
# be able to browse all the source easily
set(CoolColor_PRIVHEADERS
  priv_util.h
  )

# use the vfx variant of this since we've enabled vfx platform...
# (otherwise use aswf_add_install_library)
aswf_add_vfx_install_library(CoolColor
  SOURCE
    ${CoolColor_SOURCE}
  PUBLIC
    ${CoolColor_PUBHEADERS}
  PRIVATE
    ${CoolColor_PUBHEADERS}
  )
