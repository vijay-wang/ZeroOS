VERSION = 2016
PATCHLEVEL = 03
SUBLEVEL =
EXTRAVERSION =
NAME =

ARCH := arm
CROSS_COMPILE	?= arm-linux-gnueabihf-

ifeq ("$(origin M)", "command line")
  KBUILD_EXTMOD := $(M)
endif

ifeq ("$(origin V)", "command line")
  KBUILD_VERBOSE = $(V)
endif
ifndef KBUILD_VERBOSE
  KBUILD_VERBOSE = 0
endif

ifeq ($(KBUILD_VERBOSE),1)
  quiet =
  Q =
else
  quiet=quiet_
  Q = @
endif

export quiet Q KBUILD_VERBOSE

ifeq ("$(origin C)", "command line")
  KBUILD_CHECKSRC = $(C)
endif
ifndef KBUILD_CHECKSRC
  KBUILD_CHECKSRC = 0
endif

export KBUILD_CHECKSRC

PHONY := _all
_all:
$(CURDIR)/Makefile Makefile: ;

dot-config     := 1

%config: scripts_basic outputmakefile FORCE
	$(Q)$(MAKE) $(build)=scripts/kconfig $@

PHONY += all
ifeq ($(KBUILD_EXTMOD),)
_all: all
else
_all: modules
endif

ifeq ($(KBUILD_SRC),)
        # building in the source tree
        srctree := .
else
        ifeq ($(KBUILD_SRC)/,$(dir $(CURDIR)))
                # building in a subdirectory of the source tree
                srctree := ..
        else
                srctree := $(KBUILD_SRC)
        endif
endif
objtree		:= .
src		:= $(srctree)
obj		:= $(objtree)

VPATH		:= $(srctree)$(if $(KBUILD_EXTMOD),:$(KBUILD_EXTMOD))

export srctree objtree VPATH

HOSTARCH := $(shell uname -m | \
	sed -e s/i.86/x86/ \
	    -e s/sun4u/sparc64/ \
	    -e s/arm.*/arm/ \
	    -e s/sa110/arm/ \
	    -e s/ppc64/powerpc/ \
	    -e s/ppc/powerpc/ \
	    -e s/macppc/powerpc/\
	    -e s/sh.*/sh/)

HOSTOS := $(shell uname -s | tr '[:upper:]' '[:lower:]' | \
	    sed -e 's/\(cygwin\).*/cygwin/')

export	HOSTARCH HOSTOS

# set default to nothing for native builds
ifeq ($(HOSTARCH),$(ARCH))
CROSS_COMPILE ?=
endif

ifeq ($(dot-config), 1)
KCONFIG_CONFIG	?= .config
-include $(KCONFIG_CONFIG)
export KCONFIG_CONFIG
endif

# SHELL used by kbuild
CONFIG_SHELL := $(shell if [ -x "$$BASH" ]; then echo $$BASH; \
	  else if [ -x /bin/bash ]; then echo /bin/bash; \
	  else echo sh; fi ; fi)

HOSTCC       = cc
HOSTCXX      = c++
HOSTCFLAGS   = -Wall -Wstrict-prototypes -O2 -fomit-frame-pointer
HOSTCXXFLAGS = -O2

# Decide whether to build built-in, modular, or both.
# Normally, just do built-in.

KBUILD_MODULES :=
KBUILD_BUILTIN := 1

export KBUILD_MODULES KBUILD_BUILTIN

# We need some generic definitions (do not try to remake the file).
scripts/Kbuild.include: ;
include scripts/Kbuild.include

# Make variables (CC, etc...)

AS		= $(CROSS_COMPILE)as
# Always use GNU ld
ifneq ($(shell $(CROSS_COMPILE)ld.bfd -v 2> /dev/null),)
LD		= $(CROSS_COMPILE)ld.bfd
else
LD		= $(CROSS_COMPILE)ld
endif
CC		= $(CROSS_COMPILE)gcc
CPP		= $(CC) -E
AR		= $(CROSS_COMPILE)ar
NM		= $(CROSS_COMPILE)nm
LDR		= $(CROSS_COMPILE)ldr
STRIP		= $(CROSS_COMPILE)strip
OBJCOPY		= $(CROSS_COMPILE)objcopy
OBJDUMP		= $(CROSS_COMPILE)objdump
AWK		= awk
PERL		= perl
PYTHON		= python
DTC		= dtc
CHECK		= sparse

CHECKFLAGS     := -D__linux__ -Dlinux -D__STDC__ -Dunix -D__unix__ \
		  -Wbitwise -Wno-return-void -D__CHECK_ENDIAN__ $(CF)

KBUILD_CPPFLAGS := -D__KERNEL__ -D__STUDINIX__

KBUILD_CFLAGS   := -Wall -Wstrict-prototypes \
		   -Wno-format-security \
		   -fno-builtin -ffreestanding
KBUILD_AFLAGS   := -D__ASSEMBLY__

STUDINIXINCLUDE    := \
		-Iinclude

NOSTDINC_FLAGS += -nostdinc -isystem $(shell $(CC) -print-file-name=include)
CHECKFLAGS     += $(NOSTDINC_FLAGS)

cpp_flags := $(KBUILD_CPPFLAGS) $(PLATFORM_CPPFLAGS) $(STUDINIXINCLUDE) \
							$(NOSTDINC_FLAGS)
c_flags := $(KBUILD_CFLAGS) $(cpp_flags)


# Read STUDINIXRELEASE from include/config/studinix.release (if it exists)
STUDINIXRELEASE = $(shell cat include/config/studinix.release 2> /dev/null)
STUDINIXVERSION = $(VERSION)$(if $(PATCHLEVEL),.$(PATCHLEVEL)$(if $(SUBLEVEL),.$(SUBLEVEL)))$(EXTRAVERSION)

export VERSION PATCHLEVEL SUBLEVEL STUDINIXRELEASE STUDINIXVERSION
export ARCH CPU BOARD VENDOR SOC CPUDIR BOARDDIR
export CONFIG_SHELL HOSTCC HOSTCFLAGS HOSTLDFLAGS CROSS_COMPILE AS LD CC
export CPP AR NM LDR STRIP OBJCOPY OBJDUMP
export MAKE AWK PERL PYTHON
export HOSTCXX HOSTCXXFLAGS DTC CHECK CHECKFLAGS

export KBUILD_CPPFLAGS NOSTDINC_FLAGS STUDINIXINCLUDE OBJCOPYFLAGS LDFLAGS
export KBUILD_CFLAGS KBUILD_AFLAGS

export RCS_FIND_IGNORE := \( -name SCCS -o -name BitKeeper -o -name .svn -o    \
			  -name CVS -o -name .pc -o -name .hg -o -name .git \) \
			  -prune -o
export RCS_TAR_IGNORE := --exclude SCCS --exclude BitKeeper --exclude .svn \
			 --exclude CVS --exclude .pc --exclude .hg --exclude .git

include config.mk
include arch/$(ARCH)/config.mk
include arch/$(ARCH)/Makefile

# Basic helpers built in scripts/
PHONY += scripts_basic
scripts_basic:
	$(Q)$(MAKE) $(build)=scripts/basic
	$(Q)rm -f .tmp_quiet_recordmcount
head-y +=
libs-y +=

studinix-dirs	  := $(patsubst %/,%,$(filter %/, $(libs-y)))
studinix-alldirs  := $(sort $(studinix-dirs) $(patsubst %/,%,$(filter %/, $(libs-))))

libs-y := $(sort $(libs-y))
libs-y		:= $(patsubst %/, %/built-in.o, $(libs-y))

studinix-init := $(head-y)
studinix-main := $(libs-y)

# Add GCC lib
ifeq ($(CONFIG_USE_PRIVATE_LIBGCC),y)
PLATFORM_LIBGCC = arch/$(ARCH)/lib/lib.a
else
PLATFORM_LIBGCC := -L $(shell dirname `$(CC) $(c_flags) -print-libgcc-file-name`) -lgcc
endif
PLATFORM_LIBS += $(PLATFORM_LIBGCC)
export PLATFORM_LIBS
export PLATFORM_LIBGCC

ALL-y +=

all: $(ALL-y)
	$(Q)echo =====================finished=======================

quiet_cmd_studinix__ ?= LD      $@
      cmd_studinix__ ?= $(LD) $(LDFLAGS) $(LDFLAGS_studinix) -o $@ \
      -T studinix.lds $(studinix-init)                             \
      --start-group $(studinix-main) --end-group                 \
      $(PLATFORM_LIBS) -Map studinix.map

studinix: $(studinix-init) $(studinix-main) studinix.lds FORCE
	$(call if_changed,studinix__)

$(sort $(studinix-init) $(studinix-main)): $(studinix-dirs) ;

PHONY += $(studinix-dirs)
$(studinix-dirs): prepare scripts
	$(Q)$(MAKE) $(build)=$@

# Listed in dependency order
PHONY += prepare archprepare prepare0 prepare1 prepare2

# prepare2 creates a makefile if using a separate output directory
prepare2: outputmakefile

prepare1: prepare2 $(version_h) $(timestamp_h)
                   
#ifeq ($(CONFIG_HAVE_GENERIC_BOARD),)
#ifeq ($(CONFIG_SYS_GENERIC_BOARD),y)
#	@echo >&2 "  Your architecture does not support generic board."
#	@echo >&2 "  Please undefine CONFIG_SYS_GENERIC_BOARD in your board config file."
#	@/bin/false
#endif
#endif
#ifeq ($(wildcard $(LDSCRIPT)),)
#	@echo >&2 "  Could not find linker script."
#	@/bin/false
#endif

archprepare: prepare1 scripts_basic

prepare0: archprepare FORCE
	$(Q)$(MAKE) $(build)=.

# All the preparing..
prepare: prepare0

# ARM relocations should all be R_ARM_RELATIVE (32-bit) or
# R_AARCH64_RELATIVE (64-bit).
checkarmreloc: studinix
	@RELOC="`$(CROSS_COMPILE)readelf -r -W $< | cut -d ' ' -f 4 | \
		grep R_A | sort -u`"; \
	if test "$$RELOC" != "R_ARM_RELATIVE" -a \
		 "$$RELOC" != "R_AARCH64_RELATIVE"; then \
		echo "$< contains unexpected relocations: $$RELOC"; \
		false; \
	fi

LDPPFLAGS += \
	-include $(srctree)/include/studinix/studinix.lds.h \
	-DCPUDIR=$(CPUDIR) \
	$(shell $(LD) --version | \
	  sed -ne 's/GNU ld version \([0-9][0-9]*\)\.\([0-9][0-9]*\).*/-DLD_MAJOR=\1 -DLD_MINOR=\2/p')

quiet_cmd_cpp_lds = LDS     $@
cmd_cpp_lds = $(CPP) -Wp,-MD,$(depfile) $(cpp_flags) $(LDPPFLAGS) -ansi \
		-D__ASSEMBLY__ -x assembler-with-cpp -P -o $@ $<

LDSCRIPT := $(srctree)/arch/$(ARCH)/cpu/studinix.lds
studinix.lds: $(LDSCRIPT) prepare FORCE
	$(call if_changed_dep,cpp_lds)

PHONY += $(LDSCRIPT)

PHONY += outputmakefile
outputmakefile:
ifneq ($(KBUILD_SRC),)
	$(Q)ln -fsn $(srctree) source
	$(Q)$(CONFIG_SHELL) $(srctree)/scripts/mkmakefile \
	    $(srctree) $(objtree) $(VERSION) $(PATCHLEVEL)
endif

#########################################################################

###
# Cleaning is done on three levels.
# make clean     Delete most generated files
#                Leave enough to build external modules
# make mrproper  Delete the current configuration, and all generated files
# make distclean Remove editor backup files, patch leftover files and the like

# Directories & files removed with 'make clean'
CLEAN_DIRS  += $(MODVERDIR) \
	       $(foreach d, spl tpl, $(patsubst %,$d/%, \
			$(filter-out include, $(shell ls -1 $d 2>/dev/null))))

CLEAN_FILES += include/bmp_logo.h include/bmp_logo_data.h \
	       boot* u-boot* MLO* SPL System.map

# Directories & files removed with 'make mrproper'
MRPROPER_DIRS  += include/config include/generated spl tpl \
		  .tmp_objdiff
MRPROPER_FILES += .config .config.old include/autoconf.mk* include/config.h \
		  ctags etags TAGS cscope* GPATH GTAGS GRTAGS GSYMS

# clean - Delete most, but leave enough to build external modules
#
CLEAN_FILES += studinix*
clean: rm-dirs  := $(CLEAN_DIRS)
clean: rm-files := $(CLEAN_FILES)

clean-dirs	:= $(foreach f,$(studinix-alldirs),$(if $(wildcard $(srctree)/$f/Makefile),$f))

clean-dirs      := $(addprefix _clean_, $(clean-dirs))

PHONY += $(clean-dirs) clean archclean
$(clean-dirs):
	$(Q)$(MAKE) $(clean)=$(patsubst _clean_%,%,$@)

# TODO: Do not use *.cfgtmp
clean: $(clean-dirs)
	$(call cmd,rmdirs)
	$(call cmd,rmfiles)
	@find $(if $(KBUILD_EXTMOD), $(KBUILD_EXTMOD), .) $(RCS_FIND_IGNORE) \
		\( -name '*.[oas]' -o -name '*.ko' -o -name '.*.cmd' \
		-o -name '*.ko.*' -o -name '*.su' -o -name '*.cfgtmp' \
		-o -name '.*.d' -o -name '.*.tmp' -o -name '*.mod.c' \
		-o -name '*.symtypes' -o -name 'modules.order' \
		-o -name modules.builtin -o -name '.tmp_*.o.*' \
		-o -name '*.gcno' \) -type f -print | xargs rm -f

# mrproper - Delete all generated files, including .config
#
mrproper: rm-dirs  := $(wildcard $(MRPROPER_DIRS))
mrproper: rm-files := $(wildcard $(MRPROPER_FILES))
mrproper-dirs      := $(addprefix _mrproper_,scripts)

PHONY += $(mrproper-dirs) mrproper archmrproper
$(mrproper-dirs):
	$(Q)$(MAKE) $(clean)=$(patsubst _mrproper_%,%,$@)

mrproper: clean $(mrproper-dirs)
	$(call cmd,rmdirs)
	$(call cmd,rmfiles)
	@rm -f arch/*/include/asm/arch

# distclean
#
PHONY += distclean

distclean: mrproper
	@find $(srctree) $(RCS_FIND_IGNORE) \
		\( -name '*.orig' -o -name '*.rej' -o -name '*~' \
		-o -name '*.bak' -o -name '#*#' -o -name '.*.orig' \
		-o -name '.*.rej' -o -name '*%' -o -name 'core' \
		-o -name '*.pyc' \) \
		-type f -print | xargs rm -f
	@rm -f boards.cfg

# clean - Delete most, but leave enough to build external modules
#
quiet_cmd_rmdirs = $(if $(wildcard $(rm-dirs)),CLEAN   $(wildcard $(rm-dirs)))
      cmd_rmdirs = rm -rf $(rm-dirs)

quiet_cmd_rmfiles = $(if $(wildcard $(rm-files)),CLEAN   $(wildcard $(rm-files)))
      cmd_rmfiles = rm -f $(rm-files)

PHONY += FORCE
FORCE:

.PHONY: $(PHONY)
