;=========================================================
; 文件名: A82542.ASM
; 功能描述: 产生1s方波，输入时钟为1MHz，使用计数器0和1
;           计数初值均为03E8H
;=========================================================

A8254    EQU  0600H
B8254    EQU  0602H
C8254    EQU  0604H
CON8254  EQU  0606H

SSTACK	SEGMENT STACK
		DW 32 DUP(?)
SSTACK	ENDS

DATA SEGMENT
	FLAG DB 01H
DATA ENDS

CODE SEGMENT
	ASSUME CS:CODE, SS:SSTACK, DS:DATA
	
START:

	MOV DX, CON8254			;8254
	MOV AL, 70H				;计数器1，方式3
	OUT DX, AL
		
	MOV DX, B8254
	MOV AL, 01H
	OUT DX, AL
	MOV AL, 00H
	OUT DX, AL
	
AA1:
	NOP
	JMP AA1
		
CODE	ENDS
		END  START