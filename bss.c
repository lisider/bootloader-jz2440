
void clear_bss(void)
{
	extern int __bss_start, __bss_end;
	int *p = &__bss_start;

	for (; p < &__bss_end; p++)
		*p = 0;
}

