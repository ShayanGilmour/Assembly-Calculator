%include "in_out.asm"

section .data
	Msg1	db	'Input:'
	Len1	equ	$-Msg1

section .bss
	str:	resb	51

section .text
	global _start

_start:
	;Input
	mov	rax,	3
	mov	rbx,	2
	mov	rcx,	str
	mov	rdx,	51
	int	80h

	call	getNum
	call	writeNum

;----------Get Num-----------
getNum:
	push	rax ;Functional
	push	r8  ;Ans
	push	r9  ;Digit

	xor	r8,	r8

	gWhile:
	
	mov	r9b,	

	gExit:
		pop r9
		pop	r8
		pop 	rax
	

;----------Get Num-----------1

Exit:
	;Exit
	mov	eax,	1
	mov	ebx,	0
	int	80h

