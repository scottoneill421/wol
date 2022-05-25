# PURPOSE:	Check length of string
#
# INPUT:	String address
#
# OUTPUT:	Int resembling length of string
#
# REGISTERS:
#	%rcx - counter
#	%al  - current char
#	%rdx - address of current char

.include "linux.s"

.section .text
	.globl str_len
	.type str_len, @function
	
# Prep function, initialize counter, get input string
str_len:
	movq $0, %rcx
	movq %rdi, %rdx

# if current char = 0 -> exit, else increment counter + address pointer
loop:
	movb (%rdx), %al
	cmpb $END_OF_FILE, %al
	je end

	incq %rcx
	incq %rdx

	jmp loop

# return counter and base pointer
end:
	movq %rcx, %rax
	ret
