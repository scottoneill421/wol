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
	.equ ST_ARGC,	0
	.equ ST_OPT,	16
	.equ ST_ARG_1,	24
	.equ ST_ARG_2,	32  	

.globl _start
_start:
	movq %rsp, %rbp
	add $8, %rsp
	
	movq ST_OPT(%rbp), %rdi
	call str_len
	cmpq $2, %rax
	jne help

	call get_flag
	cmpq $WAKE_FLAG, %rax
	je wake_host

	cmpq $ADD_FLAG, %rax
	je add_host

	cmpq $DEL_FLAG, %rax
	je del_host

	cmpq $LIST_FLAG, %rax
	je list_host
help:
	movq $1, %rax
	movq $STDOUT, %rdi
	movq $help_text, %rsi
	movq $help_len, %rdx
	syscall
	movq $1, %rdi
	jmp exit	

exit:
	movq $SYS_EXIT, %rax
	syscall


wake_host:
	movq $wake_txt, %rdi
	call print
	jmp exit

add_host:
	movq $add_txt, %rdi
	call print
	jmp exit

del_host:
	movq $del_txt, %rdi
	call print
	jmp exit

list_host: 
	movq $list_txt, %rdi
	call print
	jmp exit
