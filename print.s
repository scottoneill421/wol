# PURPOSE:	Print supplied text
#
# INPUT:	string
#
# OUTPUT:	Nothing to output
#
# REGISTERS:
#	pretty straightforward

.include "linux.s"

.section .text
	.globl print
	.type print, @function

print:
	call str_len
	movq %rax, %rdx

	movq $SYS_WRITE, %rax
	movq %rdi, %rsi
	movq $STDOUT, %rdi
	syscall
	ret
