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

# Simple test, no vfx platform, just with it all included by the
# top-level CMakeLists.txt to check syntax, and that it doesn't
# pollute anything

add_executable(SimpleTest EXCLUDE_FROM_ALL main.cpp)
add_test(NAME Simple COMMAND SimpleTest)
add_dependencies(check SimpleTest)
