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
	
	@code
	stmfd	sp!, {r0, r1, fp}
	ldr r0, =string2
	ldr r1, [r1]
	bl printf
	ldmfd	sp!, {r0, r1, fp}
	
	mov r2, #1
LOOPi:
	cmp r2, r0
	beq EXIT
	stmfd	sp!, {r0, r1, r2}
	bl func
	ldmfd	sp!, {r0, r1, r2}
	add r2, r2, #1
	b LOOPi
EXIT:	
	@epilogue
	sub	sp, fp, #4
	ldmfd	sp!, {fp, lr}
	bx	lr

@func(argc, argv, i): print argv[i]
func:
	@prologue
	stmfd	sp!, {lr}

	@code
	ldr r4, [r1, r2, lsl #2]
LOOPj:
	ldrb r5, [r4], #1	
	cmp r5, #0
	beq EXITf
CAP:
	cmp r5, #'A'
	blt NONCAP
	cmp r5, #'Z'
	bgt NONCAP
	sub r5, #'A'
	add r5, #'a'
NONCAP:
	cmp r5, #'a'
	blt CONT
	cmp r5, #'z'
	bgt CONT
	b ALPHA
ALPHA:
	stmfd	sp!, {r0, r1, r2, fp}
	ldr r0, =string0
	mov r1, r5
	bl printf
	ldmfd	sp!, {r0, r1, r2, fp}
CONT:
	b LOOPj
	
EXITf:
	@epilogue
	ldmfd	sp!, {lr}
	bx	lr

@data section
string0:
	.ascii	"%c\0"
string1:
	.ascii	"%d\n\0"
string2:
	.ascii  "%s result: \0"