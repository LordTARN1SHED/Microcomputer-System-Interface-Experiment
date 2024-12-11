
; ======================================================== =

; ======================================================== =
; ====================================================== =
; 文件名: KeyLed.asm
; 功能描述: 键盘及数码管显示实验，通过8255控制。
;     8255的B口控制数码管的段显示，A口控制键盘列扫描
;     及数码管的位驱动，C口控制键盘的行扫描。
;     按下按键，该按键对应的位置将按顺序显示在数码管上。
; ====================================================== =


IOY      EQU  0600H
A8254    EQU  IOY + 00H * 2
B8254    EQU  IOY + 01H * 2
C8254    EQU  IOY + 02H * 2
CON8254  EQU  IOY + 03H * 2

MY8255_A    EQU 0640H; PA端口
MY8255_B    EQU 0642H; PB端口
MY8255_C    EQU 0644H; PC端口
MY8255_MODE EQU 0646H; 控制寄存器端口

SSTACK  SEGMENT STACK
DW 32 DUP(? )
SSTACK  ENDS

SSTACK	SEGMENT STACK
DW 16 DUP(? )
SSTACK	ENDS

DATA  	SEGMENT
DTABLE	DB 3FH, 06H, 5BH, 4FH, 66H, 6DH, 7DH, 07H
        DB 7FH, 6FH, 77H, 7CH, 39H, 5EH, 79H, 00H

COUNT1  DB 00H
COUNT2  DB 00H
COUNT3  DB 00H
COUNT4  DB 00H

FLAG    DB 01H
XX      DW 00H
NOW     DW 3000H
FINISH  DB 00H
STO     DB 00H

DATA  	ENDS

CODE 	SEGMENT
ASSUME CS : CODE, DS : DATA
START : 

MOV AX, OFFSET MIR6
MOV SI, 0038H
MOV[SI], AX
MOV AX, CS
MOV SI, 003AH
MOV[SI], AX

MOV AX, DATA
MOV DS, AX
MOV SI, 3000H
MOV AL, 00H
MOV[SI], AL; 清显示缓冲
MOV[SI + 1], AL
MOV AL, 0FH
MOV[SI + 2], AL
MOV[SI + 3], AL
MOV[SI + 4], AL
MOV[SI + 5], AL
MOV DI, 3000H
MOV DX, MY8255_MODE; 写8255控制字
MOV AL, 81H
OUT DX, AL

MOV DX, CON8254; 8254
MOV AL, 36H; 计数器0, 方式3
OUT DX, AL
MOV DX, A8254
MOV AL, 0E8H
OUT DX, AL
MOV AL, 03H
OUT DX, AL
MOV DX, CON8254; 8254
MOV AL, 76H; 计数器1, 方式3
OUT DX, AL
MOV DX, B8254
MOV AL, 0E8H
OUT DX, AL
MOV AL, 03H
OUT DX, AL

CLI
MOV AL, 11H
OUT 20H, AL
MOV AL, 08H
OUT 21H, AL
MOV AL, 04H
OUT 21H, AL
MOV AL, 07H
OUT 21H, AL
MOV AL, 2FH
OUT 21H, AL


BEGIN : 
CMP FLAG,01H
JNE N1
CLI
N1:
CMP STO,01H
JNE N2
CALL STOP
N2:
CALL DIS; 调用显示子程序
CALL CLEAR; 清屏
CALL CCSCAN; 扫描
JNZ INK1
JMP BEGIN
INK1 : CALL DIS
CALL DALLY
CALL DALLY
CALL CLEAR
CALL CCSCAN
JNZ INK2; 有键按下，转到INK2
JMP BEGIN
; ========================================
; 确定按下键的位置
; ========================================
INK2:   MOV CH, 0FEH
MOV CL, 00H

COLUM : MOV AL, CH
MOV DX, MY8255_A
OUT DX, AL
MOV DX, MY8255_C
IN AL, DX

L1 : TEST AL, 01H; is L1 ?
JNZ L2

MOV AL, 00H; L1
JMP KCODE

L2 : TEST AL, 02H; is L2 ?
JNZ L3

MOV AL, 04H; L2
JMP KCODE

L3 : TEST AL, 04H; is L3 ?
JNZ L4

MOV AL, 08H; L3
JMP KCODE

L4 : TEST AL, 08H; is L4 ?
JNZ NEXT

MOV AL, 0CH; L4

KCODE : ADD AL, CL
CALL PUTBUF

PUSH AX
KON : CALL DIS
CALL CLEAR
CALL CCSCAN
JNZ KON
POP AX

NEXT : INC CL
MOV AL, CH
TEST AL, 08H
JZ KERR
ROL AL, 1
MOV CH, AL
JMP COLUM
KERR : JMP BEGIN
; ========================================
; 键盘扫描子程序
; ========================================
CCSCAN: MOV AL, 00H
MOV DX, MY8255_A
OUT DX, AL
MOV DX, MY8255_C
IN  AL, DX
NOT AL
AND AL, 0FH
RET
; ========================================
; 清屏子程序
; ========================================
CLEAR:  
	MOV DX, MY8255_B
	MOV AL, 00H
	OUT DX, AL
	RET
; ========================================
; 启动计时子程序
; ========================================
START1:  
	    PUSH AX
		MOV SI, DI
		MOV AL, [SI]
		MOV SI, 3004H
		MOV[SI], AL
		MOV SI, DI
		INC SI
		MOV AL, [SI]
		MOV SI, 3005H
		MOV[SI], AL
		MOV AL, 00H
		MOV SI, 3003H
		MOV[SI], AL
		MOV AL, 00H
		MOV SI, 3002H
		MOV[SI], AL
		STI
		POP AX
		MOV FLAG,00H
		MOV FINISH,01H
		RET
; ========================================
; 显示子程序
; ========================================
DIS:    PUSH AX
		MOV SI,3000H
		MOV DL,0DFH
		MOV AL,DL
AGAIN:  PUSH DX
        MOV DX,MY8255_A 
        OUT DX,AL
        MOV AL,[SI]
        MOV BX,OFFSET DTABLE
		AND AX,00FFH
		ADD BX,AX
		MOV AL,[BX]
        MOV DX,MY8255_B 
		OUT DX,AL
		CALL DALLY
		INC SI
        POP DX
        MOV AL,DL
		TEST AL,01H
        JZ  OUT1
		ROR AL,1
		MOV DL,AL
		JMP AGAIN
OUT1:   POP AX
		RET

; ====== 延时子程序 ======
DALLY:  
    PUSH CX
    MOV CX, 0006H
T1 : 
    MOV AX, 009FH
T2 : 
    DEC AX
    JNZ T2
    LOOP T1
    POP CX
    RET
    
; ====== 延时子程序 ======
DALLY2:  
    PUSH CX
    MOV CX, 04FFH
T11 : 
    MOV AX, 00FFH
T22 : 
    DEC AX
    JNZ T22
    LOOP T11
    POP CX
    RET
;========================================
;存键盘值到相应位的缓冲中
;========================================
SHOWCOUNT: 
		PUSH AX
		MOV SI,3005H
		MOV AL,COUNT1
		MOV [SI],AL
		DEC SI
		MOV AL,COUNT2
		MOV[SI], AL
		DEC SI
		MOV AL,COUNT3
		MOV[SI], AL
		DEC SI
		MOV AL,COUNT4
		MOV[SI], AL
		POP AX
		RET
; ========================================
; 存键盘值到相应位的缓冲中
; ========================================
PUTBUF: 
	CMP AL,09H
	JA CHECKA

		PUSH AX
		MOV SI, DI
		MOV AL, [SI]
		INC SI
		MOV[SI], AL

		MOV COUNT1,AL

		POP AX
		MOV SI, DI
		MOV[SI], AL

		MOV COUNT2,AL

CHECKA:
		CMP AL,0AH
		JNE CHECKB
		MOV SI,3005H
		CMP FINISH,00H
		JE K1
		MOV SI, 3000H
		MOV AL, 00H
		MOV[SI], AL; 清显示缓冲
		MOV[SI + 1], AL
		MOV AL, 0FH
		MOV[SI + 2], AL
		MOV[SI + 3], AL
		MOV[SI + 4], AL
		MOV[SI + 5], AL
		MOV DI, 3000H
		CLI
		MOV COUNT1,00H
		MOV COUNT2,00H
		MOV COUNT3,00H
		MOV COUNT4,00H
		MOV FLAG,01H
		MOV FINISH,00H
		JMP GOBACK
K1:
		CALL START1
	    JMP GOBACK

CHECKB:
		CMP AL, 0BH
		JNE CHECKC
		CMP FINISH,01H
		JNE GOBACK

		CMP FLAG,00H
		JE PAUSE
CONTINUE:
		MOV FLAG,00H
		STI
		JMP GOBACK
PAUSE:
		MOV FLAG,01H
		CLI
		JMP GOBACK

CHECKC:
		CMP AL, 0CH
		JNE GOBACK
		MOV SI, 3000H
		MOV AL, 0FH
		MOV[SI], AL; 清显示缓冲
		MOV[SI + 1], AL
		MOV[SI + 2], AL
		MOV[SI + 3], AL
		MOV[SI + 4], AL
		MOV[SI + 5], AL
		MOV DI, 3000H
		CLI
		MOV COUNT1,0FH
		MOV COUNT2,0FH
		MOV COUNT3,0FH
		MOV COUNT4,0FH
		MOV FLAG,01H
		MOV FINISH,00H
		JMP ENDD

GOBACK: 
	RET

;中断处理程序
MIR6 :
    CLI
	CMP COUNT4,00H
	JNE NEXT1
	MOV COUNT4,09H
	    ;DEC COUNT3
		CMP COUNT3, 00H
		JNE NEXT2
		MOV COUNT3, 05H
			;DEC COUNT2
			CMP COUNT2, 00H
			JNE NEXT3
			MOV COUNT3, 09H
				;DEC COUNT1
				CMP COUNT1, 00H
				JNE NEXT4
				MOV FINISH,00H
		        MOV FLAG,01H
		        ;CALL STOP
		        MOV COUNT1,00H
				MOV COUNT2,00H
				MOV COUNT3,00H
				MOV COUNT4,00H
				CALL SHOWCOUNT
				MOV STO,01H
				JMP TOIRET
			NEXT4:
				DEC COUNT1
			JMP CALLS
		NEXT3:
			DEC COUNT2
		JMP CALLS
	NEXT2:
	    DEC COUNT3
	JMP CALLS
NEXT1:
	DEC COUNT4
CALLS:
	CALL SHOWCOUNT
	STI

TOIRET:
    IRET

STOP:
    	
		MOV AL, 00H
		MOV SI, 3000H
		MOV[SI], AL; 清显示缓冲
		MOV SI, 3001H
		MOV[SI], AL
		MOV SI, 3002H
		MOV[SI], AL
		MOV SI, 3003H
		MOV[SI], AL
		MOV SI, 3004H
		MOV[SI], AL
		MOV SI, 3005H
		MOV[SI], AL

        PUSH CX
    	MOV CX,003FH
UV1:
		CALL DIS
		DEC CX
		CMP CX,0H
		JNE UV1
		POP CX
		
		MOV AL, 0FH
		MOV SI, 3000H
		MOV[SI], AL; 清显示缓冲
		MOV SI, 3001H
		MOV[SI], AL
		MOV SI, 3002H
		MOV[SI], AL
		MOV SI, 3003H
		MOV[SI], AL
		MOV SI, 3004H
		MOV[SI], AL
		MOV SI, 3005H
		MOV[SI], AL

        PUSH CX
    	MOV CX,003FH
UV2:
		CALL DIS
		DEC CX
		CMP CX,0H
		JNE UV2
		POP CX
		
		MOV AL, 00H
		MOV SI, 3000H
		MOV[SI], AL; 清显示缓冲
		MOV SI, 3001H
		MOV[SI], AL
		MOV SI, 3002H
		MOV[SI], AL
		MOV SI, 3003H
		MOV[SI], AL
		MOV SI, 3004H
		MOV[SI], AL
		MOV SI, 3005H
		MOV[SI], AL

        PUSH CX
    	MOV CX,003FH
UV3:
		CALL DIS
		DEC CX
		CMP CX,0H
		JNE UV3
		POP CX
		
		MOV AL, 0FH
		MOV SI, 3000H
		MOV[SI], AL; 清显示缓冲
		MOV SI, 3001H
		MOV[SI], AL
		MOV SI, 3002H
		MOV[SI], AL
		MOV SI, 3003H
		MOV[SI], AL
		MOV SI, 3004H
		MOV[SI], AL
		MOV SI, 3005H
		MOV[SI], AL

        PUSH CX
    	MOV CX,003FH
UV4:
		CALL DIS
		DEC CX
		CMP CX,0H
		JNE UV4
		POP CX
		
			MOV AL, 00H
		MOV SI, 3000H
		MOV[SI], AL; 清显示缓冲
		MOV SI, 3001H
		MOV[SI], AL
		MOV SI, 3002H
		MOV[SI], AL
		MOV SI, 3003H
		MOV[SI], AL
		MOV SI, 3004H
		MOV[SI], AL
		MOV SI, 3005H
		MOV[SI], AL

        PUSH CX
    	MOV CX,003FH
UV5:
		CALL DIS
		DEC CX
		CMP CX,0H
		JNE UV5
		POP CX
		
		MOV AL, 0FH
		MOV SI, 3000H
		MOV[SI], AL; 清显示缓冲
		MOV SI, 3001H
		MOV[SI], AL
		MOV SI, 3002H
		MOV[SI], AL
		MOV SI, 3003H
		MOV[SI], AL
		MOV SI, 3004H
		MOV[SI], AL
		MOV SI, 3005H
		MOV[SI], AL

        PUSH CX
    	MOV CX,003FH
UV6:
		CALL DIS
		DEC CX
		CMP CX,0H
		JNE UV6
		POP CX
		
		MOV AL, 00H
		MOV SI, 3000H
		MOV[SI], AL; 清显示缓冲
		MOV SI, 3001H
		MOV[SI], AL
		MOV AL, 0FH
		MOV SI, 3002H
		MOV[SI], AL
		MOV SI, 3003H
		MOV[SI], AL
		MOV SI, 3004H
		MOV[SI], AL
		MOV SI, 3005H
		MOV[SI], AL
		CALL DIS


		MOV STO,00H
		RET

ENDD:

CODE	ENDS
END START