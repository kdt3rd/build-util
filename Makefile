#
# This serves as a sample top-level make file that people
# can call under systems with a make program to "just build".
#

.PHONY: default debug release clean install
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
MKDIR:=mkdir
CD:=cd
RM:=rm

# allows one to type make foo.o and have that transparently pass through
# without having all those rules in this top-level makefile
TARGETS:=$(filter-out default debug release clean install,$(MAKECMDGOALS))
override MAKECMDGOALS:=#
override MAKEFLAGS:=--no-print-directory

.PHONY: $(TARGETS) .FORCE
.FORCE:

default: release

clean:
	@$(RM) -rf $(REL_ROOT) $(DBG_ROOT)

install: .FORCE release
ifneq (,$(INST_COMPONENTS))
	@$(CD) $(REL_ROOT) && ($(CMAKE) -DCOMPONENT=$(INST_COMPONENT) -P cmake_install.cmake || exit 1)
else
	@$(CD) $(REL_ROOT) && ($(CMAKE) -P cmake_install.cmake || exit 1)
endif

release: $(REL_ROOT)/$(GEN_FILE)
	@$(DISPATCHER) -C $(REL_ROOT) $(TARGETS)

$(REL_ROOT)/$(GEN_FILE):
	@$(MKDIR) -p $(REL_ROOT)
	@$(CD) $(REL_ROOT) && ($(CMAKE) -DCMAKE_BUILD_TYPE=$(REL_TARG) -G $(GENERATOR) $(PWD) || exit 1)

debug: $(DBG_ROOT)/$(GEN_FILE)
	@$(DISPATCHER) -C $(DBG_ROOT) $(TARGETS)

$(DBG_ROOT)/$(GEN_FILE):
	@$(MKDIR) -p $(DBG_ROOT)
	@$(CD) $(DBG_ROOT) && ($(CMAKE) -DCMAKE_BUILD_TYPE=$(DBG_TARG) -G $(GENERATOR) $(PWD) || exit 1)
