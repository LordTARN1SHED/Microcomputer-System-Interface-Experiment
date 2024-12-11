;=========================================================
; 文件名: 
; 功能描述: 步进电机控制实验
;=========================================================

SSTACK	SEGMENT STACK
		DW 256 DUP(?)
SSTACK	ENDS

DATA	SEGMENT
TABDT	DB 01H,03H,02H,06H,04H,0CH,08H,09H  
DATA	ENDS

CODE	SEGMENT
		ASSUME CS:CODE, DS:DATA

START:  MOV AX, DATA
        MOV DS, AX

MAIN:   MOV AL, 90H			; 控制B口工作于方式0，输出
		MOV DX, 0606H              
		OUT DX, AL
A1:		MOV BX, OFFSET TABDT
        MOV CX, 0008H                          	
A2:		MOV	AL,[BX]   
		MOV DX, 0602H		; 写B口       
		OUT	DX, AL
		CALL DALLY			; 控制步进电机的转速                
		INC	BX                                      
		LOOP A2
		JMP	A1
DALLY:	PUSH CX                   
		MOV CX,8000H
A3:		PUSH AX
		POP	AX
		LOOP A3
		POP	CX
		RET
		
CODE	ENDS
		END START
      	
