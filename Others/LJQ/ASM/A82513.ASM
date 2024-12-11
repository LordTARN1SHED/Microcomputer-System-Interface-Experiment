;========================================================
; 文件名: A82513.ASM
; 功能描述: 接收机接收程序
;========================================================

M8251_DATA	EQU 0600H
M8251_CON	EQU 0602H

M8254_2		EQU 06C4H
M8254_CON	EQU 06C6H

SSTACK	SEGMENT STACK
		DW 64 DUP(?)
SSTACK	ENDS

CODE	SEGMENT
		ASSUME CS:CODE

START:	MOV AL, 0B6H			;初始化8254
		MOV DX, M8254_CON
		OUT DX, AL
		MOV AL, 0CH
		MOV DX, M8254_2
		OUT DX, AL
		MOV AL, 00H
		OUT DX, AL
		;CLI
		CALL INIT				;复位8251
		CALL DALLY
		MOV AL, 7EH
		MOV DX, M8251_CON
		OUT DX, AL 
		CALL DALLY
		MOV AL, 34H
		OUT DX, AL 
		CALL DALLY
		MOV AX, 0152H		;输出显示字符 'R'
		INT 10H
		MOV DI, 3000H
		MOV CX, 000AH
A1:		MOV DX, M8251_CON
		IN AL, DX
		AND AL, 02H
		JZ A1
		MOV DX, M8251_DATA
		IN AL, DX
		AND AL, 7FH
		MOV [DI],AL
		INC DI
		LOOP A1
		MOV AL, 00H
		MOV SI, 300AH
		MOV [SI], AL
		MOV AH, 06H
		MOV BX, 3000H
		INT 10H					;输出显示接收到的数据
		;STI
A2:		JMP A2
INIT:	MOV AL, 00H				;复位8251子程序
		MOV DX, M8251_CON
		OUT DX, AL
		CALL DALLY
		OUT DX, AL
		CALL DALLY
		OUT DX, AL
		CALL DALLY
		MOV AL, 40H
		OUT DX, AL
		RET
DALLY:	PUSH CX
		MOV CX, 3000H
A3:		PUSH AX
		POP AX
		LOOP A3
		POP CX
		RET
CODE	ENDS
		END START

