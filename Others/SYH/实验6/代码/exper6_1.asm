;=========================================================
; �ļ���: A82542.ASM
; ��������: ����1s����������ʱ��Ϊ1MHz��ʹ�ü�����0��1
;           ������ֵ��Ϊ03E8H
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
	MOV AL, 70H				;������1����ʽ3
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