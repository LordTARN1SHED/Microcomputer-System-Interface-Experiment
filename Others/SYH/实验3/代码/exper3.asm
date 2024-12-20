
SSTACK SEGMENT STACK
	DW 32 DUP(?)
SSTACK ENDS

DATA SEGMENT
	FLAG DB 00H
	REG DB 80H
	INDEX DB 00H
DATA ENDS

CODE SEGMENT
	ASSUME CS:CODE, SS:SSTACK, DS:DATA
START:
	MOV AX, 0000H
	MOV DS, AX
	MOV CX, 00H;
	
	;��ʼ��8255��ʽ������
	MOV DX, 0646H
	MOV AL, 90H
	OUT DX, AL
	
	;D0��
	MOV DX, 0642H
	MOV AL, 80H
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
	MOV AL, 3FH
	OUT DX, AL
	
	STI
	
	;IR6
	MOV SI, 0038H
	MOV AX, OFFSET IR6
	MOV [SI], AX
	MOV AX, CS
	MOV [SI+2], AX
	
	;IR7
	MOV SI, 003CH
	MOV AX, OFFSET IR7
	MOV [SI], AX
	MOV AX, CS
	MOV [SI+2], AX

AA1:
	MOV INDEX, 00H
CONTINUE:	
	CALL DELAY
	CMP FLAG, 00H
	JE CONTINUE

	MOV REG, 80H

	CMP FLAG, 01H
	JE AA2
	CMP FLAG, 02H
	JE AA3

	JMP AA1
	
;IR6
AA2:
	MOV DX, 0642H
	IN AL, DX
	CMP AL, 01H ;���ұߵ���
	JE AA8
	ROR AL, 1 ;����
	OUT DX, AL
	CALL DELAY
	JMP AA2

;IR7
AA3:
	MOV DX, 0642H
	IN AL, DX
	CMP AL, 80H ;�������
	JE AA7
	CMP FLAG, 01H
	JE AA2
	MOV FLAG, 02H
	ROL AL, 1 ;����
RETURN:
	OUT DX, AL
	CALL DELAY
	JMP AA3
	
AA8:
	CMP INDEX, 00H
	JE AA7
	JMP AA4
	
AA4:
	MOV FLAG, 00H
	MOV AL, REG
	CMP AL, 80H
	JNE RETURN
	JMP AA1
	
AA7:
	MOV FLAG, 00H
	JMP AA1

IR6:
	CMP FLAG, 02H
	JE BB1
	JMP BB2
BB1:
	MOV DX, 0642H
	IN AL, DX
	MOV REG, AL
BB2:
	MOV FLAG, 01H
	IRET
	
IR7:
	STI
	MOV INDEX, 01H
	MOV FLAG, 02H
	IRET

DELAY:
	PUSH CX
	PUSH AX
	MOV AX, 0FFH
AA6:
	MOV CX, 01FFH
AA5:
	DEC CX
	CMP CX, 00H
	JNE AA5
	DEC AX
	CMP AX, 00H
	JNE AA6
	POP AX
	POP CX
	RET

CODE ENDS
	END START


	