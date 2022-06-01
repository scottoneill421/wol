# PURPOSE: 	Used to wake a configured set of hosts as specified in hosts file
#		Wake - Wake a host from hosts
#		Add  - Add a host to hosts file
#		Del  - Delete a host from the hosts file
#		List - List all hosts in the host file
#
# INPUT:	flag (indicating the action)
#		hostname of host to perform action on
#		mac address of host if host is being added

.include "linux.s"
.include "ref.s"

.section .data
	help_text:
		.ascii "Usage: wol [option] [host]\n"
		.ascii "	-w [host]		- Wake host from hosts\n"
		.ascii "	-a [host] [macaddr]	- Add host to hosts\n"
		.ascii "	-d [host]		- Delete host from hosts\n"
		.ascii "	-l			- List all hosts in hosts\n\0"
	help_end:
		.equ help_len, help_end - help_text

	wake_txt:
		.ascii "WAKE FLAG\0"
	add_txt:
		.ascii "ADD FLAG\0"
	del_txt:
		.ascii "DEL FLAG\0"
	list_txt:
		.ascii "LIST FLAG\0"

.section .bss

.section .text
	.equ ST_ARGC,		0
	.equ ST_OPT,		16
	.equ ST_HOST,		24
	.equ ST_MACADDR,	32  	

.globl _start
_start:
	movq %rsp, %rbp

	movq $2, %rax
	cmpq %rax, ST_ARGC(%rbp)
	jl help

	# check flag is correct length (no -wa or -dkjhljh)
	movq ST_OPT(%rbp), %rdi
	call str_len
	cmpq $2, %rax
	jne help

	# inspect flag is valid, if valid, compare with valid options
	call get_flag
	cmpq $WAKE_FLAG, %rax
	je wake_host

	cmpq $ADD_FLAG, %rax
	je add_host

	cmpq $DEL_FLAG, %rax
	je del_host

	cmpq $LIST_FLAG, %rax
	je list_host

# display help text, then exit
help:
	movq $SYS_WRITE, %rax
	movq $STDOUT, %rdi
	movq $help_text, %rsi
	movq $help_len, %rdx
	syscall
	movq $1, %rdi
	jmp exit	

# exit program
exit:
	movq $SYS_EXIT, %rax
	syscall

# call the wake function (Send magic packet to a specified host)
wake_host:
	cmpq $3, ST_ARGC(%rbp)

	movq ST_HOST(%rbp), %rdi
	call wake
	jmp exit

# call the add function (Add a host to hosts file)
add_host:
	movq $add_txt, %rdi
	call print
	jmp exit

# call the del function (Delete a host from hosts file)
del_host:
	movq $del_txt, %rdi
	call print
	jmp exit

# call the list function (List all hosts in hosts file)
list_host: 
	movq $list_txt, %rdi
	call print
	jmp exit
