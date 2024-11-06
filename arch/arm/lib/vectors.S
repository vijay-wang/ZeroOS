.globl _start
	.section ".vectors", "ax"

_start:
	b	reset
	ldr	pc, _undefined_instruction
	ldr	pc, _software_interrupt
	ldr	pc, _prefetch_abort
	ldr	pc, _data_abort
	ldr	pc, _not_used
	ldr	pc, _irq
	ldr	pc, _fiq

/*
 *************************************************************************
 *
 * Indirect vectors table
 *
 * Symbols referenced here must be defined somewhere else
 *
 *************************************************************************
 */
	.globl	_undefined_instruction
	.globl	_software_interrupt
	.globl	_prefetch_abort
	.globl	_data_abort
	.globl	_not_used
	.globl	_irq
	.globl	_fiq

_undefined_instruction:	.word undefined_instruction
_software_interrupt:	.word software_interrupt
_prefetch_abort:	.word prefetch_abort
_data_abort:		.word data_abort
_not_used:		.word not_used
_irq:			.word irq
_fiq:			.word fiq

	.balignl 16,0xdeadbeef


	.align  5
undefined_instruction:
        b       .

	.align	5
software_interrupt:
        b       .

	.align	5

prefetch_abort:
        b       .

	.align	5
data_abort:
        b       .

	.align	5
not_used:
        b       .

	.align	5

#ifdef CONFIG_USE_IRQ
irq:
        b       .

	.align	5
fiq:
        b       .


#else

	.align	5
irq:
        b       .




	.align	5
fiq:
        b       .




#endif /* CONFIG_USE_IRQ */

        .section        .note.GNU-stack,"",%progbits
