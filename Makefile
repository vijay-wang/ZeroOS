ARCH := arm
CROSS_COMPILE	?= arm-linux-gnueabihf-
CC		= $(CROSS_COMPILE)gcc
LD		= $(CROSS_COMPILE)ld
AR		= $(CROSS_COMPILE)ar
NM		= $(CROSS_COMPILE)nm
OBJCOPY		= $(CROSS_COMPILE)objcopy
OBJDUMP		= $(CROSS_COMPILE)objdump
READELF		= $(CROSS_COMPILE)readelf
STRIP		= $(CROSS_COMPILE)strip

-include arch/$(ARCH)/config.mk
ALL-y +=

#u-boot:	$(u-boot-init) $(u-boot-main) u-boot.lds FORCE
#	$(call if_changed,u-boot__)
#ifeq ($(CONFIG_KALLSYMS),y)
#	$(call cmd,smap)
#	$(call cmd,u-boot__) common/system_map.o
#endif

zero:

# ARM relocations should all be R_ARM_RELATIVE (32-bit) or
# R_AARCH64_RELATIVE (64-bit).
checkarmreloc: zero
	@RELOC="`$(CROSS_COMPILE)readelf -r -W $< | cut -d ' ' -f 4 | \
		grep R_A | sort -u`"; \
	if test "$$RELOC" != "R_ARM_RELATIVE" -a \
		 "$$RELOC" != "R_AARCH64_RELATIVE"; then \
		echo "$< contains unexpected relocations: $$RELOC"; \
		false; \
	fi

_all: all

all: $(ALL-y)
	-rm start.o app
	$(CC) -Wall -c arch/arm/boot/start.S -o start.o
	$(CC) -Wall -c arch/arm/boot/init.c -o init.o
	$(LD) start.o init.o -Tarch/arm/kernel/zero.lds -o app
	$(STRIP)  app




