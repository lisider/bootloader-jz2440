
CC      = arm-linux-gcc
LD      = arm-linux-ld
AR      = arm-linux-ar
OBJCOPY = arm-linux-objcopy
OBJDUMP = arm-linux-objdump

CFLAGS 		:= -Wall -O2
CPPFLAGS   	:= -nostdinc -nostdlib -fno-builtin

objs := start.o relocate.o main.o serial.o bss.o nand.o str.o set_tag.o

boot.bin: $(objs)
	@echo LINKING ...
	${LD} -Tboot.lds -o boot.elf $^
	@echo GEN BIN ...
	${OBJCOPY} -O binary -S boot.elf $@
	@echo DISASSEMBLING ...
	${OBJDUMP} -D -m arm boot.elf > boot.dis

%.o:%.c
	${CC} $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

%.o:%.S
	${CC} $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o *.bin *.elf *.dis

