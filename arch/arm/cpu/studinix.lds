ENTRY(_start)
SECTIONS
{
        . = 0x80000;
        __start_kernel = .;
        .text ALIGN(4) : {
                *(.__image_copy_start)
                *(.vectors)
                CPUDIR/start.o (.start.text)
                *(.text*)
        
        }
        
	.rodata ALIGN(8) : { *(.rodata) }

	.data ALIGN(8) : { *(.data) }

	__bss_start = .;
	.bss ALIGN(8) :
	{
		*(.bss)
		*(COMMON)
	}
	__bss_end = .;

        __end_kernel = .;
        __stack_size = 0x10000;  /* 64KB */
        PROVIDE(__stack_start = __end_kernel + __stack_size);
	
	/DISCARD/ : {
		*(.note.GNU-stack)	
		*(.comment)	
		*(.ARM.attributes)
	}

} 
