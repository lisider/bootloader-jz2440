void nand_read(unsigned int addr, unsigned char *buf, unsigned int len);


int isBootFromNorFlash(void)
{
	volatile int *p = (volatile int *)0;
	int val;

	val = *p;
	*p = 0x12345678;
	if (*p == 0x12345678)
	{
		/* 写成功, 是nand启动 */
		*p = val;
		return 0;
	}
	else
	{
		/* NOR不能像内存一样写 */
		return 1;
	}
}

void copy_code_to_sdram(unsigned char *src, unsigned char *dest, unsigned int len)
{
	int i = 0;

	/* 如果是NOR启动 */
	if (isBootFromNorFlash())
	{
		while (i < len)
		{
			dest[i] = src[i];
			i++;
		}
	}
	else
	{
		//nand_init();
		nand_read((unsigned int)src, dest, len);
	}
}

