//
// Copyright 2018 Kimball Thurston
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include <CoolColor/Config.h>

#include <cmath>
#include <array>

COOLCOLOR_NAMESPACE_ENTER

// NB: this is not the worlds most exciting library nor a particularly
// generic or strongly typed one, but that is not it's purpose
using xy_f = std::pair<float, float>;
using XYZ_f = std::array<float, 3>;

XYZ_f xyToXYZ( const xy_f &xy, float Y = 1.f );

COOLCOLOR_NAMESPACE_EXIT
