;=======================================================
; 文件名: KeyLed.asm
; 功能描述: 键盘及数码管显示实验，通过8255控制。
;     8255的B口控制数码管的段显示，A口控制键盘列扫描
;     及数码管的位驱动，C口控制键盘的行扫描。
;     按下按键，该按键对应的位置将按顺序显示在数码管上。
;=======================================================

A8255   EQU  0600H
B8255   EQU  0602H
C8255   EQU  0604H
CON8255 EQU  0606H

A8254    EQU  0640H
B8254    EQU  0642H
C8254    EQU  0644H
CON8254  EQU  0646H

SSTACK	SEGMENT STACK
		DW 16 DUP(?)
SSTACK	ENDS		

DATA  	SEGMENT
TAB		DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH
POSI    DB 00H
NUMB	DB 00H
STATE	DB 00H
FLAG	DB 00H
ZERO	DB 00H
DATA  	ENDS

CODE 	SEGMENT
      	ASSUME CS:CODE,DS:DATA
      	
START:	MOV DX,CON8255		;写8255控制字
        MOV AL,81H
		OUT DX,AL
		
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
	
		;IR6
		MOV SI, 0038H
		MOV AX, OFFSET IR6
		MOV [SI], AX
		MOV AX, CS
		MOV [SI+2], AX
		
		MOV DX, CON8254			;8254
		MOV AL, 34H				;计数器0，方式2
		OUT DX, AL
		
		MOV DX, A8254
		MOV AL, 050H
		OUT DX, AL
		MOV AL, 0C3H
		OUT DX, AL

		MOV DX, CON8254			;8254
		MOV AL, 74H				;计数器1，方式2
		OUT DX, AL
		
		MOV SI, 3000H
		MOV AL, 00H
		MOV [SI], AL
		MOV [SI+1], AL
		MOV [SI+2], AL
		MOV [SI+3], AL
		MOV STATE, 00H
		MOV FLAG, 00H
		MOV NUMB, 00H
		MOV POSI, 00H
		MOV ZERO, 00H
		
JUDGE:	PUSH CX
		MOV AL, ZERO
		AND AX,00FFH
		JNZ	TWIN
		CALL DIS
		POP CX
		;CALL CLEAR
		CALL CCSCAN
		JNZ ANSWER				;有键按下，转到ANSWER
		JMP JUDGE
		
TWIN:	CLI
		MOV ZERO, 00H
		PUSH CX
		MOV CX, 03H
CONTI2:	PUSH CX
		MOV CX, 010H
CONTI1:	CALL DIS
		LOOP CONTI1
		POP CX
		MOV DX, A8255
		MOV AL, 0FFH
		OUT DX, AL
		CALL DELAY2
		LOOP CONTI2
		POP CX
		MOV STATE, 00H
		JMP JUDGE
		
;========================================
;确定按下键的位置
;========================================
ANSWER:	CALL READ0
		CMP FLAG, 00H
		JZ	JUDGE
		CMP FLAG, 01H
		JZ	NUMBER
		CMP FLAG, 02H
		JZ	GOCAN
		CMP FLAG, 03H
		JZ	STOPON0
		CMP FLAG, 04H
		JZ	EX0
		
EX0:	JMP EX
STOPON0:JMP STOPON
		
NUMBER:	MOV AL, STATE
		CMP AL, 00H
		JNZ JUDGE
		MOV AX,0000H
		MOV DS,AX
		MOV SI, 3000H
		MOV AL, [SI+2]
		MOV [SI+3], AL
		MOV AL, [SI+1]
		MOV [SI+2], AL
		MOV AL, [SI]
		MOV [SI+1], AL
		MOV AL, NUMB
		MOV [SI], AL
		JMP JUDGE

GOCAN:	CMP STATE, 00H
		JZ	GO
		CMP STATE, 01H
		JZ	CAN
		JMP JUDGE
GO:		MOV STATE, 01H
		STI
		
		MOV DX, B8254
		MOV AL, 014H
		OUT DX, AL
		MOV AL, 00H
		OUT DX, AL
		JMP JUDGE
CAN:	MOV STATE, 00H
		MOV AX,0000H
		MOV DS,AX
		MOV SI, 3000H
		MOV AL, 00H
		MOV [SI], AL
		MOV [SI+1], AL
		MOV [SI+2], AL
		MOV [SI+3], AL
		CLI
		JMP JUDGE
		
STOPON:	CMP STATE, 01H
		JZ	STOP
		CMP STATE, 03H
		JZ	ON
		JMP JUDGE
STOP:	MOV STATE, 03H
		CLI
		JMP JUDGE
ON:		MOV STATE, 01H
		STI
		JMP JUDGE
		
;========================================
;读取键盘子程序
;========================================
READ0:	NOP		
L1:		MOV CL,0DFH
		MOV AL,CL
        MOV DX,A8255 
		OUT DX,AL
        MOV DX,C8255
		IN AL,DX
		NOT AL
        AND AL,0FH
		CMP AL, 00H
		JZ L2
		MOV NUMB, AL
		JMP LL1

L2:     MOV CL,0EFH
		MOV AL,CL
        MOV DX,A8255 
		OUT DX,AL
        MOV DX,C8255
		IN AL,DX
		NOT AL
        AND AL,0FH
		CMP AL, 00H
		JZ L3
		MOV NUMB, AL
		JMP LL2

L3:		MOV CL,0F7H
		MOV AL,CL
        MOV DX,A8255 
		OUT DX,AL
        MOV DX,C8255
		IN AL,DX
		NOT AL
        AND AL,0FH
		CMP AL, 00H
		JZ L4
		MOV NUMB, AL
		JMP LL3

L4:     MOV CL,0FBH
		MOV AL,CL
        MOV DX,A8255 
		OUT DX,AL
        MOV DX,C8255
		IN AL,DX
		NOT AL
        AND AL,0FH
		CMP AL, 00H
		JZ AN0
		MOV NUMB, AL
		JMP LL4

LL1:    MOV CL,0DFH
		MOV AL,CL
        MOV DX,A8255 
		OUT DX,AL
        MOV DX,C8255
		IN AL,DX
		NOT AL
        AND AL,0FH
		CMP AL, NUMB
		JZ LL1
		OR NUMB,10H
		JMP RESULT

LL2:    MOV CL,0EFH
		MOV AL,CL
        MOV DX,A8255 
		OUT DX,AL
        MOV DX,C8255
		IN AL,DX
		NOT AL
        AND AL,0FH
		CMP AL, NUMB
		JZ LL2
		OR NUMB,20H
		JMP RESULT
		
LL3:	MOV CL,0F7H
		MOV AL,CL
        MOV DX,A8255 
		OUT DX,AL
        MOV DX,C8255
		IN AL,DX
		NOT AL
        AND AL,0FH
		CMP AL, NUMB
		JZ LL3
		OR NUMB,40H
		JMP RESULT
		
LL4:    MOV CL,0FBH
		MOV AL,CL
        MOV DX,A8255 
		OUT DX,AL
        MOV DX,C8255
		IN AL,DX
		NOT AL
        AND AL,0FH
		CMP AL, NUMB
		JZ LL4
		OR NUMB,80H
		JMP RESULT
		
AN0:	MOV FLAG, 00H
		JMP BACK
		
RESULT: CMP NUMB, 11H
		JZ RE0
		CMP NUMB, 21H
		JZ RE1
		CMP NUMB, 41H
		JZ RE2
		CMP NUMB, 81H
		JZ RE3
		CMP NUMB, 12H
		JZ RE4
		CMP NUMB, 22H
		JZ RE5
		CMP NUMB, 42H
		JZ RE6
		CMP NUMB, 82H
		JZ RE7
		CMP NUMB, 14H
		JZ RE8
		CMP NUMB, 24H
		JZ RE9
		CMP NUMB, 44H
		JZ REA
		CMP NUMB, 84H
		JZ REB
		CMP NUMB, 18H
		JZ REC
		JMP AN0
		
RE0:	MOV NUMB, 00H
		JMP AN1
RE1:	MOV NUMB, 01H
		JMP AN1
RE2:	MOV NUMB, 02H
		JMP AN1
RE3:	MOV NUMB, 03H
		JMP AN1
RE4:	MOV NUMB, 04H
		JMP AN1
RE5:	MOV NUMB, 05H
		JMP AN1
RE6:	MOV NUMB, 06H
		JMP AN1
RE7:	MOV NUMB, 07H
		JMP AN1
RE8:	MOV NUMB, 08H
		JMP AN1
RE9:	MOV NUMB, 09H
		JMP AN1
REA:	MOV NUMB, 0AH
		JMP AN2
REB:	MOV NUMB, 0BH
		JMP AN3
REC:	MOV NUMB, 0CH
		JMP AN4
		
AN1:	MOV FLAG, 01H
		JMP BACK
AN2:	MOV FLAG, 02H
		JMP BACK
AN3:	MOV FLAG, 03H
		JMP BACK
AN4:	MOV FLAG, 04H

BACK:	NOP
		RET
;========================================
;键盘扫描子程序
;========================================
CCSCAN: MOV AL,00H
        MOV DX,A8255
		OUT DX,AL
        MOV DX,C8255
        IN  AL,DX
		NOT AL
        AND AL,0FH
		RET
;========================================
;清屏子程序
;========================================
CLEAR:  MOV DX,B8255
        MOV AL,00H
        OUT DX,AL
		RET
;========================================
;显示子程序
;========================================
DIS:    PUSH CX
		MOV CX, 04H
		MOV SI, 3000H
		MOV POSI, 0FEH
		
AA1:	MOV DX, A8255
		MOV AL, POSI
		OUT DX, AL
		
		MOV DX, B8255
		MOV BX, OFFSET TAB
		MOV AX, 0000H
		MOV DS, AX
		MOV AL, [SI]
		ADD BX, AX
		AND BX, 00FFH
		MOV AX,DATA
		MOV DS,AX
		MOV AL, [BX]
		OUT DX, AL
		
		CALL DELAY
		MOV DX, B8255
		MOV AL, 00H
		OUT DX, AL
		
		INC SI
		
		MOV AX, 0000H
		MOV DS, AX
		ROL POSI, 1H
		
		LOOP AA1
		
		POP CX
		RET
;====== 延时子程序 ======		
DELAY:  PUSH CX
		PUSH AX
        MOV CX,0020H
T1:     MOV AX,0030H
T2:     DEC AX
		JNZ T2
		LOOP T1
		POP AX
		POP CX
		RET
		
DELAY2:  PUSH CX
		PUSH AX
        MOV CX,0155H
TT1:    MOV AX,0155H
TT2:    DEC AX
		JNZ TT2
		LOOP TT1
		POP AX
		POP CX
		RET
;====== 中断处理程序 ======	
IR6:	
		CLI
		MOV AX,0000H
		MOV DS,AX
		MOV SI, 3000H
		MOV AL, [SI]
		CMP AL, 00H
		JZ W1
		DEC AL
		MOV [SI], AL
		JMP RETURN
		
W1:		MOV AL, 09H
		MOV [SI], AL
		MOV AL, [SI+1]
		CMP AL, 00H
		JZ	W2
		DEC AL
		MOV [SI+1], AL
		JMP RETURN
		
W2:		MOV AL, 05H
		MOV [SI+1], AL
		MOV AL, [SI+2]
		CMP AL, 00H
		JZ W3
		DEC AL
		MOV [SI+2], AL
		JMP RETURN
		
W3:		MOV AL, 09H
		MOV [SI+2], AL
		MOV AL, [SI+3]
		CMP AL, 00H
		JZ WWW
		DEC AL
		MOV [SI+3], AL
		JMP RETURN
		
WWW:	MOV SI, 3000H
		MOV AL, 00H
		MOV [SI], AL
		MOV [SI+1], AL
		MOV [SI+2], AL
		MOV [SI+3], AL
		MOV ZERO, 01H
		
RETURN:	NOP
		STI
		IRET

EX:		NOP
CODE	ENDS
		END START
