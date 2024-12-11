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

SSTACK	SEGMENT STACK
		DW 16 DUP(?)
SSTACK	ENDS		

DATA  	SEGMENT
TAB		DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H
		DB 7FH,6FH,77H,7CH,39H,5EH,79H,00H
POSI    DB 0FEH
DIRE	DB 01H
NUMB	DB 0FH
DATA  	ENDS

CODE 	SEGMENT
      	ASSUME CS:CODE,DS:DATA
      	
START:	MOV DX,CON8255		;写8255控制字
        MOV AL,81H
		OUT DX,AL
		
JUDGE:	CALL DIS
		CALL DELAY
		CALL DELAY
		CALL CLEAR
		CALL CCSCAN
		JNZ L1				;有键按下，转到INK2
		JMP JUDGE
;========================================
;确定按下键的位置
;========================================
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
		JZ JUDGE
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
		CMP NUMB, 28H
		JZ RED
		CMP NUMB, 48H
		JZ REE
		CMP NUMB, 88H
		JZ REF
		JMP JUDGE
		
RE0:	MOV NUMB, 00H
		JMP MERGE
RE1:	MOV NUMB, 01H
		JMP MERGE
RE2:	MOV NUMB, 02H
		JMP MERGE
RE3:	MOV NUMB, 03H
		JMP MERGE
RE4:	MOV NUMB, 04H
		JMP MERGE
RE5:	MOV NUMB, 05H
		JMP MERGE
RE6:	MOV NUMB, 06H
		JMP MERGE
RE7:	MOV NUMB, 07H
		JMP MERGE
RE8:	MOV NUMB, 08H
		JMP MERGE
RE9:	MOV NUMB, 09H
		JMP MERGE
REA:	MOV NUMB, 0AH
		JMP MERGE
REB:	MOV NUMB, 0BH
		JMP MERGE
REC:	MOV NUMB, 0CH
		JMP MERGE
RED:	MOV NUMB, 0DH
		JMP MERGE
REE:	MOV NUMB, 0EH
		JMP MERGE
REF:	JMP EX

MERGE:	CMP DIRE, 00H
		JZ LEFT
		JMP RIGHT
		
LEFT:	MOV DIRE, 00H
		ROL POSI, 1H
		CMP POSI, 0BFH
		JZ RIGHT
		JMP JUDGE
		
RIGHT:	MOV DIRE, 01H
		ROR POSI, 1H
		CMP POSI, 7FH
		JZ LEFT
		JMP JUDGE
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
DIS:    MOV AX,DATA
		MOV DS,AX
		MOV DX, A8255
		MOV AL, POSI
		OUT DX, AL
		
		MOV DX, B8255
		MOV BX, OFFSET TAB
		MOV AL, NUMB
		ADD BX, AX
		AND BX, 00FFH
		MOV AL, [DS:BX]
		OUT DX, AL
		
		RET
;====== 延时子程序 ======		
DELAY:  PUSH CX
		PUSH AX
        MOV CX,0006H
T1:     MOV AX,009FH
T2:     DEC AX
		JNZ T2
		LOOP T1
		POP AX
		POP CX
		RET

EX:		NOP
CODE	ENDS
		END START
