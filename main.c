
extern void uart0_init(void);
extern void nand_read(unsigned int addr, unsigned char *buf, unsigned int len);
extern void puts(char *str);
extern void puthex(unsigned int val);


void setup_start_tag(void);
void setup_memory_tags(void);
void setup_commandline_tag(char *cmdline);
void setup_end_tag(void);


int main(void)
{
	void (*theKernel)(int zero, int arch, unsigned int params);
	volatile unsigned int *p = (volatile unsigned int *)0x30008000;

	/* 0. 帮内核设置串口: 内核启动的开始部分会从串口打印一些信息,但是内核一开始没有初始化串口 */
	uart0_init();

	/* 1. 从NAND FLASH里把内核读入内存 */
	puts("Copy kernel from nand\n\r");
	nand_read(0x60000+64, (unsigned char *)0x30008000, 0x200000);
	puthex(0x1234ABCD);
	puts("\n\r");
	puthex(*p);
	puts("\n\r");

	/* 2. 设置参数 */
	puts("Set boot params\n\r");
	setup_start_tag();
	setup_memory_tags();
	setup_commandline_tag("noinitrd root=/dev/mtdblock3 init=/linuxrc console=ttySAC0");
	setup_end_tag();

	/* 3. 跳转执行 */
	puts("Boot kernel\n\r");
	theKernel = (void (*)(int, int, unsigned int))0x30008000;
	theKernel(0, 362, 0x30000100);
	/*
	 *  mov r0, #0
	 *  ldr r1, =362
	 *  ldr r2, =0x30000100
	 *  mov pc, #0x30008000
	 */

	puts("Error!\n\r");
	/* 如果一切正常, 不会执行到这里 */

	return -1;
}

