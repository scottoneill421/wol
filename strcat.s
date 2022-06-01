# PURPOSE:	Add str2 to end of str1
#
# INPUT:	%rdi - str1, %rsi - str2
#
# OUTPUT:	%rax - length of new string
#
# REGISTER:
#	%rdi - str1
#	%rsi - str2
#	%al  - char

.include "linux.s"

.section .text
	.globl str_cat
	.type str_cat, @function

str_cat:
	movq $0, %rax

loop_a:
	movb (%rdi), %al
	cmpb $END_OF_FILE, %al
	je loop_b

	incq %rdi
	incq %rax

	jmp loop_a

loop_b:
	movb (%rsi), %al
	movb %al, (%rdi)

	cmpb $END_OF_FILE, %al
	je end

	incq %rdi
	incq %rsi
	incq %rax

	jmp loop_b

end:
	subq %rax, %rdi
	ret
	


