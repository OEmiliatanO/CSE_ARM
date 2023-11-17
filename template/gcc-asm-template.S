@this is comment

@the information that tells arm-none-eabi-as what arch. to assemble to 
	.cpu arm926ej-s
	.fpu softvfp

@this is code section
@note, we must have the main function for the simulator's linker script
	.text
	.align	2   @align 4 byte
	.global	main
main:

    @prologue
	stmfd	sp!, {fp, lr}
	add	fp, sp, #4

    @code body
	mov r0, #10
	mov r1, #11
	mov r2, #12
	mov r4, r1
	stmda sp!, {r0, r1, r2}
	ldr r1, [sp, #4]
	bl printreg
	mov r1, r4
	ldmib sp!, {r2, r0, r1}
	mov r4, r1
	mov r5, r2
	
	mov r1, r0
	bl printreg
	mov r1, r4
	bl printreg
	mov r2, r5
	mov r1, r2
	bl printreg
	mov r1, r4
	
	@epilogue
	sub	sp, fp, #4
	ldmfd	sp!, {fp, lr}
	bx	lr

@another function
printreg:
    stmfd  sp!, {fp, lr}
	ldr r0, =printint
	bl printf
	ldmfd  sp!, {fp, lr}
	bx lr

printint:
	.ascii	"%d\n\0"
    .end
    
    