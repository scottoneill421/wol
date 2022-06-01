# PURPOSE:	Wake a host from hosts
#
# INPUT:	%rdi - Hostname string
#
# OUTPUT:	%rax - exit code (0 - Success, 1 - Error)
#
# REGISTERS:
#	%r8 - File Buffer address (F_BUF)
#	%r9 - Host Buffer address (H_BUF)

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
		.ascii "wake error: Host's name is too large for BUF (30 char limit)\n\0"
	
	invalid_mac_text:
		.ascii "wake error: MACADDR read from hosts is invalid.\n\0"

	success:
		.ascii "Successful match\n\0"
	no_success:
		.ascii "No match found\n\0"
	
	magic_packet_header:
		.ascii "FFFFFF\0"

.section .bss
	.lcomm F_BUF, BUFSIZE
	.lcomm H_BUF, MAX_HOST_LEN + 1
	.lcomm P_BUF, MPCKSIZE

.section .text
	.equ ST_FD,  -8

	.globl wake
	.type wake, @function

wake:
	# Initialise function, store hostname, check length
	pushq %rbp
	movq %rsp, %rbp

	subq $8, %rsp
	movq %rdi, %r8
	call str_len
	cmpq $MAX_HOST_LEN, %rax
	jg too_long	

open_hosts:
	movq $SYS_OPEN, %rax
	movq $hosts, %rdi
	movq $0, %rsi
	movq $0666, %rdx
	syscall
	movq %rax, ST_FD(%rbp)   

read_hosts:
	movq $SYS_READ, %rax
	movq ST_FD(%rbp), %rdi
	movq $F_BUF, %rsi
	movq $BUFSIZE, %rdx
	syscall

read_buffer:
	movq $F_BUF, %rcx

read_host:
	movq $H_BUF, %rdx

read_char:
	cmpb $END_OF_HOST, (%rcx)
	je check_match
	movb (%rcx), %al
	movb %al, (%rdx)	
	incq %rcx
	incq %rdx
	jmp read_char

check_match:
	movb $0, (%rdx)

	movq $H_BUF, %rdi
	movq %r8, %rsi
	call str_cmp
	cmpq $0, %rax
	je match_found

	addq $19, %rcx
	jmp read_host

match_found:
	movq $H_BUF, %rdx

read_mac:
	incq %rcx
	cmpb $NEWLINE, (%rcx)
	je validate_mac

	cmpb $COLON, (%rcx)
	je read_mac

get_mac_byte:
	# Less than ascii 0
	cmpb $48, (%rcx)
	jl invalid_mac
	
	# More than ascii F
	cmpb $70, (%rcx)
	jg invalid_mac
	
	# Less than/equal to ascii 9
	cmpb $57, (%rcx)
	jle add_byte
	
	# More than/equal to ascii A
	cmpb $65, (%rcx)
	jge add_byte
	
	jmp invalid_mac

add_byte:
	movb (%rcx), %al
	movb %al, (%rdx)
	incq %rdx
	jmp read_mac

validate_mac:
	movq $H_BUF, %rdi
	call str_len
	cmpq $MACSIZE, %rax
	jne invalid_mac

make_packet:
	movq $P_BUF, %rdi
	movq $magic_packet_header, %rsi
	call str_cat
	movq $0, %rcx
add_mac:
	movq $P_BUF, %rdi
	movq $H_BUF, %rsi
	call str_cat
	incq %rcx
	cmpq $16, %rcx
	jl add_mac

exit:
	movq $P_BUF, %rdi
	call print
	movq $SYS_CLOSE, %rax
	movq ST_FD(%rbp), %rdi
	syscall

	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret

too_long:
	movq $too_long_txt, %rdi
	call print
	movq $1, %rax
	jmp exit

invalid_mac:
	movq $invalid_mac_text, %rdi
	call print
	movq $1, %rax
	jmp exit
