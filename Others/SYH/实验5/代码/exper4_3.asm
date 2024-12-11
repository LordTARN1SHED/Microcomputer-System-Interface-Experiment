SSTACK SEGMENT STACK
	DW 64 DUP(?)
SSTACK ENDS

CODE SEGMENT
	ASSUME CS:CODE
	
START:
	MOV DX, 0606H ;选择IOY0
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
	
AA1:
	CLI
	MOV DX, 0640H ;启动A/D转换
	OUT DX, AL
	CALL DELAY ;保证一次采样只中断一次
	STI
	
	JMP AA1
	
DELAY:
	PUSH CX
	PUSH AX
	MOV CX, 0FFFH
L1:
	LOOP L1
	POP AX
	POP CX
	RET
	
IR6:
	STI
	MOV DX, 0640H
	IN AL, DX
	MOV DX, 0602H
	OUT DX, AL
	JMP AA1
	IRET
	
CODE ENDS
	END START