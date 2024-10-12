ENTRY(_start)
SECTIONS
{
        . = 0x80000;
        __start_kernel = .;
        .kernel.text ALIGN(4) : { *(.kernel.text) }       
        
	.rodata ALIGN(4) : { *(.rodata) }

	.data ALIGN(4) : { *(.data) }

        .note.GNU-stack : { *(.note.GNU-stack) }
	__bss_start = .;
	.bss ALIGN(4) :
	{
		*(.bss)
		*(COMMON)
	}
	__bss_end = .;

        __end_kernel = .;
        __stack_size = 0x10000; /* 64KB */
        PROVIDE(__stack_start = __end_kernel + __stack_size);

} 
