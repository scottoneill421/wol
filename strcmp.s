# PURPOSE:	Compare two strings
#
# INPUT:	%rdi - str1, %rsi - str2
#
# OUTPUT:	0 if different, 1 if same
#
# REGISTERS:
#	%rdi - str1
#	%rsi - str2
#	%al  - char1
#	%bl  - char2

.section .text
	.globl str_cmp
	.type str_cmp, @function
	
str_cmp:
	pushq %rbp
	movq %rsp, %rbp

loop:
	movb (%rdi), %al
	movb (%rsi), %bl

	incq %rdi
	incq %rsi

	cmpb %al, %bl
	jne not_equal

	cmpb $0, %al
	jne loop

equal:
	movq $0, %rax
	jmp exit

not_equal:
	movq $1, %rax

exit:
	movq %rbp, %rsp
	popq %rbp
	ret

