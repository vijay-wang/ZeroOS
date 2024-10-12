CROSS_COMPILE	?= arm-linux-gnueabihf-
CC		= $(CROSS_COMPILE)gcc
LD		= $(CROSS_COMPILE)ld
AR		= $(CROSS_COMPILE)ar
NM		= $(CROSS_COMPILE)nm
OBJCOPY		= $(CROSS_COMPILE)objcopy
OBJDUMP		= $(CROSS_COMPILE)objdump
READELF		= $(CROSS_COMPILE)readelf
STRIP		= $(CROSS_COMPILE)strip

all:
	-rm start.o app
	$(CC) -Wall -c arch/arm/boot/start.S -o start.o
	$(CC) -Wall -c arch/arm/boot/init.c -o init.o
	$(LD) start.o init.o -Tarch/arm/kernel/zero.lds -o app




