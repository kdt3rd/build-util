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

namespace COOL_COLOR_NAMESPACE
{

#if defined(__clang__)

# if __has_builtin(__builtin_expect)
#  define cool_likely(condition) __builtin_expect( (condition), 1 )
# endif

#elif defined(__GNUC__) && (__GNUC__ >= 3)

# define cool_likely(condition) __builtin_expect( (condition), 1 )

#elif defined(__INTEL_COMPILER)

# define cool_likely(condition) __builtin_expect( (condition), 1 )

#endif

#ifndef cool_likely
# define cool_likely(condition) (condition)
#endif

} // namespace COOL_COLOR_NAMESPACE
