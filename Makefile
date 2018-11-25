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

#
# This serves as a sample top-level make file that people
# can call under systems with a make program to "just build".
#

.PHONY: default debug release clean install package
.DEFAULT: default

# Variables to control the output folder used for the out-of-source root
# in building.
#
# These are a pair, one (the TARG) is the cmake target name, the second
# is the root of where to put that build target
#
# TODO: this could be built out of double variable derefs and turn the
# rules below into generated and auto-expanded names, enabling more
# flexibility
REL_TARG:=Release
REL_ROOT:=release
DBG_TARG:=Debug
DBG_ROOT:=debug

# This enables using a subset of build-rules to be targeted
# for installation using the cmake component system.
INST_COMPONENT:=#

PWD:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# The ninja builder is significantly more efficient than make,
# use that if available
DISPATCHER:=$(MAKE)
GENERATOR:= "Unix Makefiles"
GEN_FILE:=Makefile
ifneq (,$(shell which ninja))
DISPATCHER:=ninja
GENERATOR:="Ninja"
GENFILE:=build.ninja
endif
CMAKE:=cmake
CPACK:=cpack
MKDIR:=mkdir
CD:=cd
RM:=rm

# allows one to type make foo.o and have that transparently pass through
# without having all those rules in this top-level makefile
TARGETS:=$(filter-out default debug release clean package install,$(MAKECMDGOALS))
TARG_CONFIG:=$(filter debug release,$(MAKECMDGOALS))
override MAKECMDGOALS:=#
override MAKEFLAGS:=--no-print-directory

default: release

.PHONY: .FORCE
.FORCE:

ifneq (,$(TARGETS))
ifeq (debug,$(TARG_CONFIG))
TARG_ROOT:=$(DBG_ROOT)
else
ifeq (release,$(TARG_CONFIG))
TARG_ROOT:=$(REL_ROOT)
else
ifeq (,$(TARG_CONFIG))
TARG_ROOT:=$(REL_ROOT)
else
$(error Unrecognized configuration '$(TARG_CONFIG)' when specifying target)
endif
endif
endif

.PHONY: $(TARGETS)
$(TARGETS): $(TARG_ROOT)/$(GEN_FILE)
	@$(DISPATCHER) -C $(TARG_ROOT) $(TARGETS)

endif

clean:
	@$(RM) -rf $(REL_ROOT) $(DBG_ROOT)

install: .FORCE release
ifneq (,$(INST_COMPONENTS))
	@$(CD) $(REL_ROOT) && ($(CMAKE) -DCOMPONENT=$(INST_COMPONENT) -P cmake_install.cmake || exit 1)
else
ifneq (,$(prefix))
	@$(CD) $(REL_ROOT) && ($(CMAKE) -DCMAKE_INSTALL_PREFIX=$(prefix) -P cmake_install.cmake || exit 1)
else
	@$(CD) $(REL_ROOT) && ($(CMAKE) -P cmake_install.cmake || exit 1)
endif
endif

package: .FORCE release
	@$(CMAKE) -E cmake_echo_color --switch=$(COLOR) --green "Making source packages..."
	@$(CD) $(REL_ROOT) && ($(CPACK) --config ./CPackSourceConfig.cmake || exit 1)
	@$(CMAKE) -E cmake_echo_color --switch=$(COLOR) --green "Making binary packages..."
	@$(CD) $(REL_ROOT) && ($(CPACK) --config ./CPackConfig.cmake || exit 1)

release: $(REL_ROOT)/$(GEN_FILE)
	@$(DISPATCHER) -C $(REL_ROOT) $(TARGETS)

$(REL_ROOT)/$(GEN_FILE):
	@$(MKDIR) -p $(REL_ROOT)
ifneq (,$(prefix))
	@$(CD) $(REL_ROOT) && ($(CMAKE) -DCMAKE_INSTALL_PREFIX=$(prefix) -DCMAKE_BUILD_TYPE=$(REL_TARG) -G $(GENERATOR) $(PWD) || exit 1)
else
	@$(CD) $(REL_ROOT) && ($(CMAKE) -DCMAKE_BUILD_TYPE=$(REL_TARG) -G $(GENERATOR) $(PWD) || exit 1)
endif

debug: $(DBG_ROOT)/$(GEN_FILE)
	@$(DISPATCHER) -C $(DBG_ROOT) $(TARGETS)

$(DBG_ROOT)/$(GEN_FILE):
	@$(MKDIR) -p $(DBG_ROOT)
	@$(CD) $(DBG_ROOT) && ($(CMAKE) -DCMAKE_BUILD_TYPE=$(DBG_TARG) -G $(GENERATOR) $(PWD) || exit 1)
