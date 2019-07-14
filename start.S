
#define S3C2440_MPLL_200MHZ     ((0x5c<<12)|(0x01<<4)|(0x02))
#define MEM_CTL_BASE    0x48000000

.text
.global _start
_start:
    /*当前cpu 从 flash 取指,flash 可以为nand或者nor*/

/* 1. 关看门狗 */ // 平台无关,都要做
	ldr r0, =0x53000000
	mov r1, #0
	str r1, [r0]

/* 2. 设置时钟 */ // 平台无关,都要做
	ldr r0, =0x4c000014
	mov r1, #0x03;            // FCLK:HCLK:PCLK=1:2:4, HDIVN=1,PDIVN=1
	str r1, [r0]

	/* 如果HDIVN非0，CPU的总线模式应该从“fast bus mode”变为“asynchronous bus mode” */
	mrc	p15, 0, r1, c1, c0, 0		/* 读出控制寄存器 */
	orr	r1, r1, #0xc0000000			/* 设置为“asynchronous bus mode” */
	mcr	p15, 0, r1, c1, c0, 0		/* 写入控制寄存器 */

	/* MPLLCON = S3C2440_MPLL_200MHZ */
	ldr r0, =0x4c000004
	ldr r1, =S3C2440_MPLL_200MHZ
	str r1, [r0]

/* 3. 初始化SDRAM */ // 平台无关,都要做
	ldr r0, =MEM_CTL_BASE    /*sdram配置地址*/
	adr r1, sdram_config     /*当前配置参数地址*/
	add r3, r0, #(13*4)      /*配置参数的数量*/
1:
	ldr r2, [r1], #4        /*加载当前配置参数进入寄存器*/
	str r2, [r0], #4        /*存储寄存器中的内容进入内存(sdram配置地址)*/
	cmp r0, r3
	bne 1b

/* 4. 设置sp,为调用c函数做准备 */ // 平台无关,都要做
    /* 复位后直接进入 管理模式 */
    /* 默认 IRQ FIQ 开启 , ARM 状态*/
	ldr sp, =0x34000000

/* 5. 清bss段 */ // 平台无关,都要做
	bl clear_bss

/* 6. 初始化nand,因为拷贝代码的时候可能需要 nand */
    /*如果cpu从nand启动,表示cpu已经有读取nand的ops,cpu自己支持的,硬件做的*/
    /*但是如果是代码里面要操作nand中的数据,需要代码初始化nand,并提供软件上的ops*/
	bl nand_init

/* 7. 重定位 : 把bootloader本身的代码从flash(nand 或者 nor)复制到它的链接地址(位于sdram)去 */
	mov r0, #0
	ldr r1, =_start
	ldr r2, =__bss_start
	sub r2, r2, r1
	bl copy_code_to_sdram

/* 8. 转向第二阶段loader */
	ldr lr, =halt /*下一句之前,都是从flash(nand 或者 nor)取指的*/
	ldr pc, =main /*这一句之后,代码就已经在sdram里了,cpu会从sdram取值.*/
halt:
	b halt

sdram_config:
	.long 0x22011110	 //BWSCON
	.long 0x00000700	 //BANKCON0
	.long 0x00000700	 //BANKCON1
	.long 0x00000700	 //BANKCON2
	.long 0x00000700	 //BANKCON3
	.long 0x00000700	 //BANKCON4
	.long 0x00000700	 //BANKCON5
	.long 0x00018005	 //BANKCON6
	.long 0x00018005	 //BANKCON7
	.long 0x008C04F4	 // REFRESH
	.long 0x000000B1	 //BANKSIZE
	.long 0x00000030	 //MRSRB6
	.long 0x00000030	 //MRSRB7

