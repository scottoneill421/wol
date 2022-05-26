# PURPOSE:	Wake a host from hosts
#
# INPUT:	%rdi - Hostname string
#
# OUTPUT:	%rax - exit code (0 - Success, 1 - Error)
#
# REGISTERS:
#	%rbx - Hostname

# steps:
# 	1. Get hostname from %rdi
#	2. Open hosts file
#	3. Read file to find host
#	4. Grab macaddr stored with host
#	5. create a magic packet using macaddr
#	6. send to host's macaddr

.include "linux.s"
.include "ref.s"

.section .data
	hosts:
		.ascii "hosts\0"
	
	too_long_txt:
		.ascii "wake error: Host's name is too large for buffer (256 char limit)\n\0"

.section .bss
	.lcomm buffer, BUFSIZE


.section .text
	.equ ST_FD, -8

	.globl wake
	.type wake, @function

wake:
	# Initialise function, store hostname, check length
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp
	movq %rdi, %rbx
	call str_len
	cmpq $BUFSIZE, %rax
	jg too_long
	
	# Open hosts file, store on stack
	movq $SYS_OPEN, %rax
	movq $hosts, %rdi
	movq $0, %rsi
	movq $0666, %rdx
	syscall
	movq %rax, ST_FD(%rbp)

	

	movq $0, %rax
exit:
	movq %rbp, %rsp
	popq %rbp
	ret

too_long:
	movq $too_long_txt, %rdi
	call print
	movq $1, %rax
	jmp exit
