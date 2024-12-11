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
	;��ʼ��8255��ʽ������
	MOV DX, 0646H
	MOV AL, 90H
	OUT DX, AL

	CLI
	;ICW1
	MOV DX, 0020H
	MOV AL, 11H
	OUT DX, AL
	
	;ICW2
	MOV DX, 0021H
	MOV AL, 08H
	OUT DX, AL
	
	;ICW3
	MOV DX, 0021H
	MOV AL, 04H
	OUT DX, AL
	
	;ICW4
	MOV DX, 0021H
	MOV AL, 07H
	OUT DX, AL
	
	;OCW1
	MOV DX, 0021H
	MOV AL, 0BFH
	OUT DX, AL
	
	STI
	
	;IR6
	MOV SI, 0038H
	MOV AX, OFFSET IR6
	MOV [SI], AX
	MOV AX, CS
	MOV [SI+2], AX
	
	
	MOV DX, CON8254			;8254
	MOV AL, 34H				;������0����ʽ3
	OUT DX, AL
		
	MOV DX, A8254
	MOV AL, 050H
	OUT DX, AL
	MOV AL, 0C3H
	OUT DX, AL

	MOV DX, CON8254			;8254
	MOV AL, 74H				;������1����ʽ3
	OUT DX, AL
		
	MOV DX, B8254
	MOV AL, 014H
	OUT DX, AL
	MOV AL, 00H
	OUT DX, AL

	MOV FLAG, 00H
	
AA1:
	NOP
	JMP AA1
	
IR6:
	ROL FLAG, 1
	INC FLAG
	MOV DX, 0642H
	MOV AL, FLAG
	OUT DX, AL
	IRET
		
CODE	ENDS
		END  START