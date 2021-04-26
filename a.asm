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

	mov	rsi,	str
	call	getNum
	call	writeNum
	jmp	Exit

;----------Get Num----------- 
;Returns the number rsi is 
;Pointing in RAX
getNum:

push	r8  ;Ans
push	r9  ;Digit
push	rbx
push	rcx
push	rdx

xor	r8,	r8

	gWhile:
	mov	r9b,	[rsi] ;One digit
	cmp	r9b,	'0'
	jl	gExit

	mov	rax,	r8
	mov	r10,	10
	mul	r10

	sub	r9,	'0'
	add	rax,	r9
	mov	r8,	rax

	inc	rsi
	jmp	gWhile

gExit:
mov	rax,	r8 ;Ans
;Pop
pop	rdx
pop	rcx
pop	rbx
pop	r9
pop	r8
ret
;----------Get Num-----------

Exit:
	;Exit
	mov	eax,	1
	mov	ebx,	0
	int	80h

