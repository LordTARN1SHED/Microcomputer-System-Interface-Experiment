;=======================================================
; 文件名:   A4-1.ASM
; 功能描述: 分支程序的设计
;=======================================================

SSTACK	SEGMENT STACK
		DW 64 DUP(?)
SSTACK	ENDS

CODE	SEGMENT
		ASSUME CS:CODE

START:	MOV CX, 0010H
		MOV SI, 3100H
		MOV DI, 3200H
		CMP SI, DI
		JA A2
		ADD SI, CX
		ADD DI, CX
		DEC SI
		DEC DI
A1:		MOV AL, [SI]
		MOV [DI], AL
		DEC SI
		DEC DI
		DEC CX
		JNE A1
		JMP A3
A2:		MOV AL, [SI]
		MOV [DI], AL
		INC SI
		INC DI
		DEC CX
		JNE A2
A3:		MOV AX,4C00H
		INT 21H					;程序终止
CODE	ENDS
		END START