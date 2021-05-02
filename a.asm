%include "in_out.asm"

section .data
	mInput db	0xA,'Input:',0xA
	lInput equ	$-mInput

section .bss
	str:	resb	501

	sPtr:	resb	8	;Starting Pointer
	ePtr:	resb	8	;Ending Pointer

section .text
	global _start


;------------------------------INSTRUCTION------------------------------

;+-*/		Sum, Sub, Mul, Div
;a^b		a to the power of b
;a\b		logarithm of a in base b

;Each operation must be in a parethesis
;So in each parenthesis there must be at most 1 operation.

;To use the last result, use character a or A

;Input Samples:
; (((1+2)*3)/5)
; ((a*a)\2)

;The calculator will show step by step of its work on input
;To exit, use character $

;------------------------------INSTRUCTION------------------------------

_start:

xor	r10,	r10 ;Last answer

getInput:
	mov	rax,	4
	mov	rbx,	1
	mov	rcx,	mInput
	mov	rdx,	lInput
	int	0x80

	mov	rax,	3
	mov	rbx,	2
	mov	rcx,	str
	mov	rdx,	501
	int	80h

	mov	al,	[str]
	cmp	al,	'$'
	jz	Exit

replaceA: ;Replaces each A with r10 (the last answer)
	mov	rsi,	str
	dec	rsi
rWhile:
	inc	rsi
	mov	al,	[rsi]
	
	cmp	al,	0xA
	je	nextPar
	
	cmp	al,	'a'
	jz	replaceRSI
	cmp	al,	'A'
	jz	replaceRSI

	jmp	rWhile


nextPar: 	;Finding inner-most parenthesis
	mov	rsi,	str
	dec	rsi

iWhile:
	inc	rsi
	
	mov	al,	[rsi]
	
	cmp	al, 0xA
	jz	getInput
	cmp	al, '('
	jz	setOpen
	cmp	al, ')'
	jz	setClose

	jmp	iWhile
	

Solve: ;Solving the content of the inner parenthesis

	mov	rsi,	[sPtr]
	inc	rsi

	call	getNum
	mov	r13,	rax	;First number
	xor	r14,	r14 
	mov	r14b,	[rsi]	;Operator
	inc	rsi
	call	getNum
	mov	r15,	rax	;Second number

	call	Calculate
	mov	r10,	rax ;Update the last answer
	mov	rsi,	[sPtr]
	mov	rdi,	[ePtr]
	inc	rdi
	call	putNum

	call	printStr
	jmp	nextPar


setOpen:
mov	[sPtr], rsi
jmp	iWhile

setClose:
mov	[ePtr], rsi
jmp	Solve

printStr: ;Prints str
push	rax
push	rbx
push	rcx
push	rdx

	mov	rax,	4
	mov	rbx,	1
	mov	rcx,	str
	mov	rdx,	501
	int	0x80

pop	rdx
pop	rcx
pop	rbx
pop	rax
ret

;-----------Calculate----------
;Calculates
;A		(-+/*^\)		B
;r13		  r14b 	    r15
;Returns the answer in RAX

Calculate:
push	r9
push	rbx
push	rcx
push	rdx

cmp	r14b,	'+'
jz	calcSum
cmp	r14b,	'-'
jz	calcSub
cmp	r14b,	'*'
jz	calcMul
cmp	r14b,	'/'
jz	calcDiv
cmp	r14b,	'^'
jz	calcPow
cmp	r14b,	'\'
jz	calcLog

calcSum:
add	r13,	r15
mov	rax,	r13
jmp	calcRet

calcSub:
sub	r13,	r15
mov	rax,	r13
jmp	calcRet

calcMul:
xor	rdx,	rdx
mov	rax,	r13
mul	r15
jmp	calcRet

calcDiv:
xor	rdx,	rdx
mov	rax,	r13
div	r15
jmp	calcRet

calcPow:
mov	rax,	1
powWhile:
	cmp	r15,	0
	jz	calcRet
	xor	rdx,	rdx
	mul	r13
	dec	r15
	jmp	powWhile

calcLog:
mov	r9,	0
mov	rax,	r13
logWhile:
	cmp	rax,	1
	jz	logSwap
	xor	rdx,	rdx
	div	r15
	inc	r9
	jmp	logWhile
logSwap:
	mov	rax,	r9
	jmp	calcRet

calcRet:
pop	rdx
pop	rcx
pop	rbx
pop	r9
ret
;----------------------------


;--------Replace RSI---------
;Replaces the character 'a'
;which RSI is pointing to with
;the last answer (r10)

replaceRSI:
push	r9
;Rshift str from after 'a'
;So we can use putNum.

mov	r9,	str
add	r9,	450
mov	rdi,	r9
add	rdi,	20

rshiftWhile:
dec	r9
dec	rdi

cmp	rsi,	r9
jz	callPutNum
mov	al,	[r9]
mov	[rdi], al
jmp	rshiftWhile

callPutNum:
inc	rdi
mov	rax,	r10
call	putNum

pop	r9
call	printStr
jmp	replaceA
;----------------------------



;----------Put Num-----------
;Puts the number RAX
;in the string. then fills 
;the empty erea by shifting
;the string to left
putNum:
push	rax
push	rbx
push	rcx
push	rdx

cmp	rax,	0
jz	putZero

mov	rbx,	10
xor	rcx,	rcx ;Number of digits

pWhile:
	cmp	rax,	0
	jz	pPrint

	xor	rdx,	rdx
	div	rbx
	push	rdx
	inc	rcx
	jmp	pWhile


pPrint:
	cmp	rcx,	0
	jz	pShiftL
	dec	rcx
	pop	rax
	add	rax,	0x30
	mov	[rsi], al
	inc	rsi
	jmp	pPrint


putZero: ;Zero is a special case
	mov	rax,	0
	add	rax,	0x30
	mov	[rsi], al
	inc	rsi
	jmp	pShiftL

pShiftL:
	mov	al,	[rdi]
	mov	bl,	0x00
	mov	[rdi], bl
	mov	[rsi], al
	cmp	al, 0xA
	jz	makeNull
	inc	rsi
	inc	rdi

	jmp	pShiftL

makeNull:
	mov	rdi,	str
	add	rdi,	501
mnWhile:
	inc	rsi
	cmp	rsi,	rdi
	jz	pEnd
	mov	al,	0x00
	mov	[rsi], al

	jmp	mnWhile

pEnd:
pop	rdx
pop	rcx
pop	rbx
pop	rax
ret
;----------------------------


;----------Get Num----------- 
;Returns the the
;number rsi is 
;Pointing in RAX
getNum:

push	r8  ;Ans
push	r9  ;Digit
push	rbx
push	rcx
push	rdx
push	r10

xor	r8,	r8

	gWhile:
	mov	r9b,	[rsi] ;One digit
	cmp	r9b,	'0'
	jl	gExit
	cmp	r9b,	'9'
	jg	gExit

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
pop	r10
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

