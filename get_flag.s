# PURPOSE:	Get the flag
#
# INPUT:	%rdi - flag string
#
# OUTPUT:	%rax - flag option
#
# REGISTERS:
#	%rdi - flag
#	%al  - comparison char
#	%bl  - inspected flag char
#	%rcx - index
#	%rdx - flag_opts len

.include "linux.s"
.include "ref.s"

.section .data

invalid_text:
	.ascii "get_flag: The given flag is invalid.\n\0"

valid_text:
	.ascii "The given flag is valid.\n\0"
 
flag_opts:
	.byte 0x2D, 0x77, 0x61, 0x64, 0x6C
flag_end:
	.equ flag_len, flag_end - flag_opts

.section .bss

.section .text

	.globl get_flag
	.type get_flag, @function

# check flag len, initialize counter, get options, get first flag char
get_flag:
	movq $0, %rcx
	movq $flag_len, %rdx
	movb (%rdi), %bl

# check first char is '-', if not -> invalid_flag, then load second char
check_switch:
	movb flag_opts(,%rcx,1), %al
	cmpb %al, %bl
	jne invalid_flag

	incq %rcx
	incq %rdi
	movb (%rdi), %bl

# loop through each valid char, compare to user input, if valid -> valid, else, fall through
# to invalid
check_char_loop:
	movb flag_opts(,%rcx,1), %al
	cmpb %bl, %al
	je valid_flag

	incq %rcx
	cmpq %rdx, %rcx
	jl check_char_loop

# char was invalid, exit with a code of zero
invalid_flag:
	movq $0, %rax
	ret

# char is valid, exit with %rcx (Aligns with flag constant as defined in ref.s)
valid_flag:
	movq %rcx, %rax
	ret 	             
