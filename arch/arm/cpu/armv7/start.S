        .section        .start.text
        .extern         kernel_start
        .code           32
        .global         reset

reset:

        /* disable interrupts, also set the cpu to SVC32 mode */
        mrs r0, cpsr
        bic r0, r0, #0x1f         @ clear mode bits
        orr r0, r0, #0x13         @ set SVC mode
        orr r0, r0, #0xc0         @ disable FIQ and IRQ
        msr cpsr, r0

        /* unlock SLCR registers */
        ldr r0, =0xf8000008       @ slcr_unlock register addresss
        ldr r1, =0xdf0d           @ unlock code
        str r1, [r0]

        /* set mio07 to gpio mode */
        ldr r0, =0xf800071c       @ mio07 ctrl register 
        ldr r1, =0x00000000       @ set to gpio (l3_sel = 000)
        str r1, [r0]

        /* set drirection of mio07 to output */
        ldr r0, =0xe000a204       @ register to set pin's(bank0) direction 
        ldr r1, [r0]
        orr r1, r1, #(1 << 7)     @ set direction of mio07 to output
        str r1, [r0]

        /* enable mio07 output */
        ldr r0, =0xe000a208       @ bank0 output enable address
        ldr r1, [r0]
        orr r1, r1, #(1 << 7)     @ enable mio07 output
        str r1, [r0]

        /* set mio07 to high level to light up led */
        ldr r0, =0xe000a040       @ bank0 data address
        ldr r1, [r0]
        orr r1, r1, #(1 << 7)     @ set mio07 to high level
        str r1, [r0]

        ldr sp, =__stack_start
        b kernel_start


        .section        .note.GNU-stack,"",%progbits  // Mark the stack as non-executable
