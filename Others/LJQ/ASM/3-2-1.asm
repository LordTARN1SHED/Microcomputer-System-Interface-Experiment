;===================================================================
; 文件名:3-2-1.asm
; 功能描述: 32位寄存器和32位指令使用的基本用法，
;			对存储区中的一组双字进行排序，并将排序结果显示在屏幕上。
;===================================================================

.386p
TSTACK	SEGMENT	STACK	USE16 
	DB	64	DUP(?)
TSTACK	ENDS

DATA	SEGMENT	USE16
MES1	DB	'The array is:','$'
MES2	DB	'After sort:','$'
DATA1	DD	110015H,111101D8H,22110002H,111a0004H,1d110009H,111f044H,11d10203H,32H
COUNT	=8
DATA	ENDS

CODE	SEGMENT	USE16
		ASSUME	CS:CODE,DS:DATA
START:	MOV 	AX,DATA			;显示未排序的数组
		MOV		DS,AX
		MOV		DX,OFFSET MES1	
		MOV		AH,09H
		INT 	21H

		CALL	KENTER			;换行
		CALL	SAHEX		
		CALL	KENTER

		CALL	BUBBLE			;显示排序后的数组
		MOV		DX,OFFSET MES2
		MOV		AH,09H
		INT		21H
		
		CALL	KENTER
		CALL	SAHEX
		CALL	KENTER
		
		MOV 	AX,4C00H
		INT 	21H				;程序终止


BUBBLE	PROC	
		XOR		ESI,ESI
		XOR		ECX,ECX
		MOV		SI,OFFSET DATA1
		MOV		CX,COUNT
L1:		XOR		EBX,EBX
L2:		CMP		EBX,ECX
		JAE		LB
		MOV		EAX,[ESI+EBX*4+4]	
		CMP		[ESI+EBX*4],EAX
		JGE		LNS
		XCHG	[ESI+EBX*4],EAX
		MOV		[ESI+EBX*4+4],EAX
LNS:	INC		EBX
		JMP		L2
LB:		LOOP	L1
		RET
BUBBLE	ENDP

SAHEX	PROC	NEAR
		XOR		ESI,ESI
		XOR		ECX,ECX
		MOV		SI,OFFSET DATA1
		MOV		CX,COUNT*4
C1:		MOV		EBX,ECX
		DEC		EBX
		MOV		AL,DS:[ESI+EBX]
		AND		AL,0F0H				;取高4位
		SHR		AL,4
		CMP		AL,0AH				;是否是A以上的数
		JB		C2		
		ADD		AL,07H		
C2:		ADD		AL,30H		
		MOV		DL,AL
		MOV		AH,02H
		INT		21H					;显示字符
		MOV		AL,DS:[ESI+EBX]
		AND		AL,0FH				;取低4位
		CMP		AL,0AH
		JB		C3
		ADD 	AL,07H
C3:		ADD		AL,30H
		MOV		DL,AL				;显示字符
		MOV		AH,02H
		INT		21H
		TEST	EBX,03H
		JNZ		C4
		MOV 	DL,20H
		MOV     AH,02H
		INT 	21H					;空格
C4:		LOOP	C1
		RET
SAHEX	ENDP

KENTER	PROC	NEAR
		MOV		AH,02H
		MOV 	DL,0DH
		INT 	21H					;回车
		MOV 	AH,02H
		MOV 	DL,0AH
		INT 	21H					;换行
		RET
KENTER	ENDP

CODE	ENDS
		END		START
