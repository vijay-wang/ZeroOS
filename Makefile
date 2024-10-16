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

PHONY := _all
_all:
$(CURDIR)/Makefile Makefile: ;



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

KCONFIG_CONFIG	?= .config
export KCONFIG_CONFIG

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

KBUILD_CPPFLAGS := -D__KERNEL__ -D__UBOOT__

KBUILD_CFLAGS   := -Wall -Wstrict-prototypes \
		   -Wno-format-security \
		   -fno-builtin -ffreestanding
KBUILD_AFLAGS   := -D__ASSEMBLY__

# Read STUDINIXRELEASE from include/config/uboot.release (if it exists)
STUDINIXRELEASE = $(shell cat include/config/studinix.release 2> /dev/null)
STUDINIXVERSION = $(VERSION)$(if $(PATCHLEVEL),.$(PATCHLEVEL)$(if $(SUBLEVEL),.$(SUBLEVEL)))$(EXTRAVERSION)

export VERSION PATCHLEVEL SUBLEVEL STUDINIXRELEASE STUDINIXVERSION
export ARCH CPU BOARD VENDOR SOC CPUDIR BOARDDIR
export CONFIG_SHELL HOSTCC HOSTCFLAGS HOSTLDFLAGS CROSS_COMPILE AS LD CC
export CPP AR NM LDR STRIP OBJCOPY OBJDUMP
export MAKE AWK PERL PYTHON
export HOSTCXX HOSTCXXFLAGS DTC CHECK CHECKFLAGS

export KBUILD_CPPFLAGS NOSTDINC_FLAGS UBOOTINCLUDE OBJCOPYFLAGS LDFLAGS
export KBUILD_CFLAGS KBUILD_AFLAGS

export RCS_FIND_IGNORE := \( -name SCCS -o -name BitKeeper -o -name .svn -o    \
			  -name CVS -o -name .pc -o -name .hg -o -name .git \) \
			  -prune -o
export RCS_TAR_IGNORE := --exclude SCCS --exclude BitKeeper --exclude .svn \
			 --exclude CVS --exclude .pc --exclude .hg --exclude .git

-include arch/$(ARCH)/config.mk

head-y +=
libs-y +=

studinix-dirs	:= $(patsubst %/,%,$(filter %/, $(libs-y))) tools examples

studinix-init := $(head-y)
studinix-main := $(libs-y)

ALL-y +=

all: $(ALL-y)
	-rm start.o app
	$(CC) -Wall -c arch/arm/boot/start.S -o start.o
	$(CC) -Wall -c arch/arm/boot/init.c -o init.o
	$(LD) start.o init.o -Tarch/arm/kernel/zero.lds -o app
	$(STRIP)  app

studinix: $(studinix-init) $(studinix-main) studinix.lds FORCE
	$(call if_changed,studinix__)
ifeq ($(CONFIG_KALLSYMS),y)
	$(call cmd,smap)
	$(call cmd,studinix__) common/system_map.o
endif

$(sort $(studinix-init) $(studinix-main)): $(studinix-dirs) ;

PHONY += $(studinix-dirs)
$(studinix-dirs): prepare scripts
	$(Q)$(MAKE) $(build)=$@

# Store (new) UBOOTRELEASE string in include/config/uboot.release
include/config/uboot.release: include/config/auto.conf FORCE
	@echo "=============================$@========================"
	$(call filechk,uboot.release)

# Listed in dependency order
PHONY += prepare archprepare prepare0 prepare1 prepare2 prepare3

# prepare3 is used to check if we are building in a separate output directory,
# and if so do:
# 1) Check that make has not been executed in the kernel src $(srctree)
prepare3: include/config/uboot.release
	@echo "=============================$@========================"
ifneq ($(KBUILD_SRC),)
	@$(kecho) '  Using $(srctree) as source for U-Boot'
	$(Q)if [ -f $(srctree)/.config -o -d $(srctree)/include/config ]; then \
		echo >&2 "  $(srctree) is not clean, please run 'make mrproper'"; \
		echo >&2 "  in the '$(srctree)' directory.";\
		/bin/false; \
	fi;
endif

# prepare2 creates a makefile if using a separate output directory
prepare2: prepare3 outputmakefile

prepare1: prepare2 $(version_h) $(timestamp_h) \
                   include/config/auto.conf
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

PHONY += FORCE
FORCE:

.PHONY: $(PHONY)
