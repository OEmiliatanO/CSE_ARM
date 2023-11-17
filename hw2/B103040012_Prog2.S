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
	bl disassemble
	.include "test.S"
	.space 4
	
EXIT:
	@epilogue
	sub	sp, fp, #4
	ldmfd	sp!, {fp, lr}
	bx	lr

disassemble:
	@prologue
	stmfd	sp!, {lr}

	@code
	@r0 = PC
	@r1 = instruction
	@r2 = copy of PC
	mov r0, lr
	mov r2, r0
LOOP:
	@pc
	ldr r1, [r0], #4
	cmp r1, #0
	addeq r0, r0, #4
	beq EXIT_disassemble
	stmfd	sp!, {r0, r1, r2, r3, fp, lr}
	sub r1, r0, #4
	sub r1, r1, r2
	ldr r0, =string_hex
	bl printf
	ldmfd	sp!, {r0, r1, r2, r3, fp, lr}
	
	@cond
	stmfd	sp!, {r0, r1, r2, r3, fp, lr}
	@bfi r2, r1, #28, #4
	and r2, r1, #0xf0000000
	mov r2, r2, lsr #28
	ldr r3, =cond_table
	mov r4, #3
	mla r1, r4, r2, r3
	ldr r0, =print_string
	bl printf
	ldmfd	sp!, {r0, r1, r2, r3, fp, lr}
	
	@opcode
	
	@blx/bx rm	
	stmfd	sp!, {r0, r1, r2}
	mov r0, r1
	bl BXBLX_TYPE
	mov r4, r0
	ldmfd	sp!, {r0, r1, r2}
	cmp r4, #1
	beq PRINT_BREAK
	
	@blx label
	stmfd	sp!, {r0, r1, r2}
	mov r3, r1
	sub r1, r0, #4
	sub r1, r1, r2
	mov r0, r3
	bl BLXLABEL_TYPE
	mov r4, r0
	ldmfd	sp!, {r0, r1, r2}
	cmp r4, #1
	beq PRINT_BREAK
	
	@b/bl
	stmfd	sp!, {r0, r1, r2}
	mov r3, r1
	sub r1, r0, #4
	sub r1, r1, r2
	mov r0, r3
	bl BBL_TYPE
	mov r4, r0
	ldmfd	sp!, {r0, r1, r2}
	cmp r4, #1
	beq PRINT_BREAK
	
	@clz
	stmfd   sp!, {r0, r1, r2}
	mov r0, r1
	bl CLZ_TYPE
	mov r4, r0
	ldmfd   sp!, {r0, r1, r2}
	cmp r4, #1
	beq PRINT_BREAK
	
	@swp
	stmfd   sp!, {r0, r1, r2}
	mov r0, r1
	bl SWP_TYPE
	mov r4, r0
	ldmfd   sp!, {r0, r1, r2}
	cmp r4, #1
	beq PRINT_BREAK
	
	@msr
	stmfd   sp!, {r0, r1, r2}
	mov r0, r1
	bl MSR_TYPE
	mov r4, r0
	ldmfd   sp!, {r0, r1, r2}
	cmp r4, #1
	beq PRINT_BREAK
	
	@mrs
	stmfd   sp!, {r0, r1, r2}
	mov r0, r1
	bl MRS_TYPE
	mov r4, r0
	ldmfd   sp!, {r0, r1, r2}
	cmp r4, #1
	beq PRINT_BREAK
	
	@mul
	stmfd	sp!, {r0, r1, r2}
	mov r0, r1
	bl MUL_TYPE
	mov r4, r0
	ldmfd	sp!, {r0, r1, r2}
	cmp r4, #1
	beq PRINT_BREAK
	
	@ldrh/strh/ldrsh/strsh/ldrsb/strsb
	stmfd	sp!, {r0, r1, r2}
	mov r0, r1
	bl LDRH_SERIALS_TYPE
	mov r4, r0
	ldmfd	sp!, {r0, r1, r2}
	cmp r4, #1
	beq PRINT_BREAK

	@ldr/str/ldrb/strb
	stmfd	sp!, {r0, r1, r2}
	mov r0, r1
	bl LDR_SERIALS_TYPE
	mov r4, r0
	ldmfd	sp!, {r0, r1, r2}
	cmp r4, #1
	beq PRINT_BREAK
	
	@ldm/stm
	stmfd	sp!, {r0, r1, r2}
	mov r0, r1
	bl LDM_TYPE
	mov r4, r0
	ldmfd	sp!, {r0, r1, r2}
	cmp r4, #1
	beq PRINT_BREAK
	
	@data processing
	stmfd   sp!, {r0, r1, r2}
	mov r0, r1
	bl DATA_PROCESSING_TYPE
	mov r4, r0
	ldmfd   sp!, {r0, r1, r2}
	cmp r4, #1
	beq PRINT_BREAK

	@undefined
	stmfd	sp!, {r0, r1, r2, r3, fp, lr}
	ldr r0, =string_UND
	bl printf
	ldmfd	sp!, {r0, r1, r2, r3, fp, lr}
	
PRINT_BREAK:
	stmfd	sp!, {r0, r1, r2, r3, fp, lr}
	ldr r0, =print_break
	bl printf
	ldmfd	sp!, {r0, r1, r2, r3, fp, lr}
	b LOOP
	
	@epilogue
EXIT_disassemble:
	ldmfd sp!, {lr}
	bx	r0

@r0 = instruction
DATA_PROCESSING_TYPE:
	@bfi r1, r0, #26, #2
	and r1, r0, #0xc000000
	mov r1, r1, lsr #26
	cmp r1, #0
	movne r0, #0
	bxne lr
	@bfi r1, r0, #21, #4
	and r1, r0, #0x1e00000
	mov r1, r1, lsr #21
	stmfd	sp!, {r0, r1, r2, r3, fp, lr}
	mov r2, #4
	ldr r3, =data_processing_table
	mla r1, r2, r1, r3
	ldr r0, =print_string
	bl printf
	ldmfd	sp!, {r0, r1, r2, r3, fp, lr}
	
	mov r0, #1
	bx lr

@r0 = instruction
BXBLX_TYPE:
	@bfi r1, r0, #6, #22
	ldr r2, =0xfffffc0
	and r1, r0, r2
	mov r1, r1, lsr #6
	ldr r2, =0x4BFFC
	cmp r1, r2
	movne r0, #0
	bxne lr
	@bfi r1, r0, #4, #1
	and r1, r0, #0x10
	mov r1, r1, lsr #6
	cmp r1, #0
	movne r0, #0
	bxne lr
	@bfi r1, r0, #5, #1
	and r1, r0, #0x20
	mov r1, r1, lsr #5
	cmp r1, #0
	stmfd	sp!, {r0, r1, r2, r3, fp, lr}
	ldreq r1, =branch_table+5
	ldrne r1, =branch_table+8
	ldr r0, =print_string
	bl printf
	ldmfd	sp!, {r0, r1, r2, r3, fp, lr}
	
	mov r0, #1
	bx lr

@r0 = instruction
@r1 = PC
BLXLABEL_TYPE:
	@bfi r2, r0, #28, #4
	and r2, r0, #0xf0000000
	mov r2, r2, lsr #28
	cmp r2, #0xF
	movne r0, #0
	bxne lr
	@bfi r2, r0, #25, #3
	and r2, r0, #0xe000000
	mov r2, r2, lsr #25
	cmp r2, #0x5
	movne r0, #0
	bxne lr
	@type
	stmfd	sp!, {r0, r1, r2, r3, fp, lr}
	ldr r1, =branch_table+8
	ldr r0, =print_string
	bl printf
	ldmfd	sp!, {r0, r1, r2, r3, fp, lr}
	@branch target
	stmfd	sp!, {r0, r1, r2, r3, fp, lr}
	@bfi r2, r0, #0, #24
	and r2, r0, #0xffffff
	mov r2, r2, lsl #2
	@bfi r3, r2, #25, #1
	and r3, r2, #0x2000000
	mov r3, r3, lsr #25
	cmp r3, #1
	orreq r2, r2, #0xfc000000
	add r1, r1, r2
	add r1, r1, #8
	ldr r0, =string_hex
	bl printf
	ldmfd	sp!, {r0, r1, r2, r3, fp, lr}
	
	mov r0, #1
	bx lr

@r0 = instruction
@r1 = PC
BBL_TYPE:
	@bfi r2, r0, #25, #3
	and r2, r0, #0xe000000
	mov r2, r2, lsr #25
	cmp r2, #5
	movne r0, #0
	bxne lr
	@bfi r2, r0, #24, #1
	and r2, r0, #0x1000000
	mov r2, r2, lsr #24
	cmp r2, #0
	@type
	stmfd	sp!, {r0, r1, r2, r3, fp, lr}
	ldreq r1, =branch_table
	ldrne r1, =branch_table+2
	ldr r0, =print_string
	bl printf
	ldmfd	sp!, {r0, r1, r2, r3, fp, lr}
	@branch target
	stmfd	sp!, {r0, r1, r2, r3, fp, lr}
	@bfi r2, r0, #0, #24
	and r2, r0, #0xffffff
	mov r2, r2, lsl #2
	@bfi r3, r2, #25, #1
	and r3, r2, #0x2000000
	mov r3, r3, lsr #25
	cmp r3, #1
	orreq r2, r2, #0xfc000000
	add r1, r1, r2
	add r1, r1, #8
	ldr r0, =string_hex
	bl printf
	ldr r0, =print_spaces
	bl printf
	ldmfd	sp!, {r0, r1, r2, r3, fp, lr}
	
	mov r0, #1
	bx lr

@r0 = instruction
LDRH_SERIALS_TYPE:
	@bfi r1, r0, #25, #3
	and r1, r0, #0xe000000
	mov r1, r1, lsr #25
	cmp r1, #0
	movne r0, #0
	bxne lr
	@bfi r1, r0, #7, #1
	and r1, r0, #0x80
	mov r1, r1, lsr #7
	cmp r1, #1
	movne r0, #0
	bxne lr
	@bfi r1, r0, #4, #1
	and r1, r0, #0x10
	mov r1, r1, lsr #4
	cmp r1, #1
	movne r0, #0
	bxne lr
	@H
	@bfi r1, r0, #5, #1
	and r1, r0, #0x20
	mov r1, r1, lsr #5
	@S
	@bfi r2, r0, #6, #1
	and r2, r0, #0x40
	mov r2, r2, lsr #6
	@L
	@bfi r3, r0, #20, #1
	and r3, r0, #0x100000
	mov r3, r3, lsr #20
	stmfd	sp!, {r0, r1, r2, r3, fp, lr}
	cmp r1, #1
	ldreq r1, =data_transfer_table2
	ldrne r1, =data_transfer_table2+24
	cmp r2, #1
	addeq r1, r1, #12
	cmp r3, #1
	addeq r1, r1, #6
	ldr r0, =print_string
	bl printf
	ldmfd	sp!, {r0, r1, r2, r3, fp, lr}
	
	mov r0, #1
	bx lr

@r0 = instruction
LDR_SERIALS_TYPE:
	@bfi r1, r0, #26, #2
	and r1, r0, #0xc000000
	mov r1, r1, lsr #26
	cmp r1, #1
	movne r0, #0
	bxne lr
	@bfi r2, r0, #20, #1 @L
	and r2, r0, #0x100000
	mov r2, r2, lsr #20
	@bfi r1, r0, #22, #1 @B
	and r1, r0, #0x400000
	mov r1, r1, lsr #22
	stmfd	sp!, {r0, r1, r2, r3, fp, lr}
	cmp r1, #1
	ldrne r1, =data_transfer_table+10
	ldreq r1, =data_transfer_table
	cmp r2, #1
	addeq r1, r1, #5
	ldr r0, =print_string
	bl printf
	ldmfd	sp!, {r0, r1, r2, r3, fp, lr}
	
	mov r0, #1
	bx lr

@r0 = instruction
LDM_TYPE:
	@bfi r1, r0, #25, #3
	and r1, r0, #0xe000000
	mov r1, r1, lsr #25
	cmp r1, #4
	movne r0, #0
	bxne lr
	@bfi r1, r0, #20, #1
	and r1, r0, #0x100000
	mov r1, r1, lsr #20
	cmp r1, #0
	stmfd	sp!, {r0, r1, r2, r3, fp, lr}
	ldreq r1, =multi_data_transfer_table
	ldrne r1, =multi_data_transfer_table+4
	ldr r0, =print_string
	bl printf
	ldmfd	sp!, {r0, r1, r2, r3, fp, lr}
	
	mov r0, #1
	bx lr

@r0 = instruction
MUL_TYPE:
	@bfi r1, r0, #24, #4
	and r1, r0, #0xf000000
	mov r1, r1, lsr #24
	cmp r1, #0
	movne r0, #0
	bxne lr
	@bfi r1, r0, #4, #4
	and r1, r0, #0xf0
	mov r1, r1, lsr #4
	cmp r1, #9
	movne r0, #0
	bxne lr
	stmfd	sp!, {r0, r1, r2, r3, fp, lr}
	@bfi r2, r0, #21, #3
	and r2, r0, #0xe00000
	mov r2, r2, lsr #21
	mov r3, #6
	ldr r1, =mul_table
	mla r1, r3, r2, r1
	ldr r0, =print_string
	bl printf
	ldmfd	sp!, {r0, r1, r2, r3, fp, lr}
	
	mov r0, #1
	bx lr

@r0 = instruction
CLZ_TYPE:
	@bfi r1, r0, #16, #12
	ldr r2, =0xfff0000
	and r1, r0, r2
	mov r1, r1, lsr #16
	ldr r2, =0x16F
	cmp r1, r2
	movne r0, #0
	bxne lr
	@bfi r1, r0, #4, #8
	and r1, r0, #0xff0
	mov r1, r1, lsr #4
	cmp r1, #0xF1
	movne r0, #0
	bxne lr
	stmfd	sp!, {r0, r1, r2, r3, fp, lr}
	ldr r0, =print_string
	ldr r1, =clz_table
	bl printf
	ldmfd	sp!, {r0, r1, r2, r3, fp, lr}
	
	mov r0, #1
	bx lr

@r0 = instruction
SWP_TYPE:
	@bfi r1, r0, #23, #5
	and r1, r0, #0xf800000
	mov r1, r1, lsr #23
	cmp r1, #2
	movne r0, #0
	bxne lr
	@bfi r1, r0, #20, #2
	and r1, r0, #0x300000
	mov r1, r1, lsr #20
	cmp r1, #0
	movne r0, #0
	bxne lr
	@bfi r1, r0, #4, 8
	and r1, r0, #0xff0
	mov r1, r1, lsr #4
	cmp r1, #9
	movne r0, #0
	bxne lr
	stmfd	sp!, {r0, r1, r2, r3, fp, lr}
	@bfi r1, r0, #22, #1
	and r1, r0, #0x400000
	mov r1, r1, lsr #22
	cmp r1, #1
	ldr r0, =print_string
	ldreq r1, =swp_table+4
	ldrne r1, =swp_table
	bl printf
	ldmfd	sp!, {r0, r1, r2, r3, fp, lr}
	
	mov r0, #1
	bx lr

@r0 = instruction
MRS_TYPE:
	@bfi r1, r0, #23, #5
	and r1, r0, #0xf800000
	mov r1, r1, lsr #23
	cmp r1, #2
	movne r0, #0
	bxne lr
	@bfi r1, r0, #16, #6
	and r1, r0, #0x3f0000
	mov r1, r1, lsr #16
	cmp r1, #15
	movne r0, #0
	bxne lr
	@bfi r1, r0, #0, #12
	ldr r2, =0xfff
	and r1, r0, r2
	cmp r1, #0
	movne r0, #0
	bxne lr
	stmfd	sp!, {r0, r1, r2, r3, fp, lr}
	ldr r0, =print_string
	ldr r1, =mrs_table
	bl printf
	ldmfd	sp!, {r0, r1, r2, r3, fp, lr}
	
	mov r0, #1
	bx lr

@r0 = instruction
MSR_TYPE:
	@bfi r1, r0, #26, #2
	and r1, r0, #0xc000000
	mov r1, r1, lsr #26
	cmp r1, #0
	movne r0, #0
	bxne lr
	@bfi r1, r0, #23, #2
	and r1, r0, #0x1800000
	mov r1, r1, lsr #23
	cmp r1, #2
	movne r0, #0
	bxne lr
	@bfi r1, r0, #20, #2
	and r1, r0, #0x300000
	mov r1, r1, lsr #20
	cmp r1, #2
	movne r0, #0
	bxne lr
	@bfi r1, r0, #12, #4
	and r1, r0, #0xf000
	mov r1, r1, lsr #12
	cmp r1, #15
	movne r0, #0
	bxne lr
	stmfd	sp!, {r0, r1, r2, r3, fp, lr}
	ldr r0, =print_string
	ldr r1, =msr_table
	bl printf
	ldmfd	sp!, {r0, r1, r2, r3, fp, lr}
	
	mov r0, #1
	bx lr

@data section
string_hex:
	.asciz "0x%X \t"
string_UND:
	.asciz "UND"

cond_table:
	.asciz "EQ" "NE" "CS" "CC" "MI" "PL" "VS" "VC" "HI" "LS" "GE" "LT" "GT" "LE" "AL" "NV"
data_processing_table:
	.asciz "AND" "EOR" "SUB" "RSB" "ADD" "ADC" "SBC" "RSC" "TST" "TEQ" "CMP" "CMN" "ORR" "MOV" "BIC" "MVN"
clz_table:
	.asciz "UND"
swp_table:
	.asciz "UND" "UND"
mrs_table:
	.asciz "UND"
msr_table:
	.asciz "UND"
mul_table:
	.asciz "MUL\0\0" "MLA\0\0" "\0\0\0\0\0" "\0\0\0\0\0" "UMULL" "UMLAL" "SMULL" "SMLAL"
branch_table:
	.asciz "B" "BL" "BX" "BLX"
data_transfer_table:
	.asciz "STRB" "LDRB" "STR\0" "LDR\0"
data_transfer_table2:
	.asciz "STRH\0" "LDRH\0" "STRSH" "LDRSH" "STRSB" "LDRSB" "STRSB" "LDRSB"
multi_data_transfer_table:
	.asciz "STM" "LDM"

print_one:
	.asciz "1\n"
print_string:
	.asciz "%s\t"
print_spaces:
	.asciz "  "
print_break:
	.asciz "\n"