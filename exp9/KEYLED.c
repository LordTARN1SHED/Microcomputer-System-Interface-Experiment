;=======================================================
; �ļ���: KeyLed.asm
; ��������: ���̼��������ʾʵ�飬ͨ��8255���ơ�
;     8255��B�ڿ�������ܵĶ���ʾ��A�ڿ��Ƽ�����ɨ��
;     ������ܵ�λ������C�ڿ��Ƽ��̵���ɨ�衣
;     ���°������ð�����Ӧ��λ�ý���˳����ʾ��������ϡ�
;=======================================================

MY8255_A    EQU  0600H
MY8255_B    EQU  0602H
MY8255_C    EQU  0604H
MY8255_CON	EQU  0606H

SSTACK	SEGMENT STACK
		DW 16 DUP(?)
SSTACK	ENDS		

DATA  	SEGMENT
DTABLE	DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H
		DB 7FH,6FH,77H,7CH,39H,5EH,79H,00H
		
FLAG    DB 00H
XX      DW 00H
NOW     DW 3000H
DATA  	ENDS

CODE 	SEGMENT
      	ASSUME CS:CODE,DS:DATA
START:  MOV AX,DATA
		MOV DS,AX
 		MOV SI,3000H
		MOV AL,0FH
		MOV [SI],AL				;����ʾ����
		MOV [SI+1],AL
		MOV [SI+2],AL
		MOV [SI+3],AL
		MOV [SI+4],AL
		MOV [SI+5],AL
		MOV DI,3000H
        MOV DX,MY8255_CON		;д8255������
        MOV AL,81H
		OUT DX,AL
BEGIN:  CALL DIS				;������ʾ�ӳ���
		CALL CLEAR				;����
		CALL CCSCAN				;ɨ��
		JNZ INK1
		JMP BEGIN
INK1:   CALL DIS
        CALL DALLY
        CALL DALLY
        CALL CLEAR
		CALL CCSCAN
		JNZ INK2				;�м����£�ת��INK2
		JMP BEGIN
;========================================
;ȷ�����¼���λ��
;========================================
INK2:   MOV CH,0FEH
		MOV CL,00H

COLUM:  MOV AL,CH
        MOV DX,MY8255_A 
		OUT DX,AL
        MOV DX,MY8255_C 
		IN AL,DX

L1:     TEST AL,01H         ;is L1?
        JNZ L2

        MOV AL,00H          ;L1
		JMP KCODE

L2:     TEST AL,02H         ;is L2?
        JNZ L3

        MOV AL,04H          ;L2
        JMP KCODE

L3:     TEST AL,04H         ;is L3?
        JNZ L4

        MOV AL,08H          ;L3
		JMP KCODE

L4:     TEST AL,08H         ;is L4?
        JNZ NEXT

        MOV AL,0CH          ;L4

KCODE:  ADD AL,CL
		CALL PUTBUF

		PUSH AX
KON:    CALL DIS
		CALL CLEAR
		CALL CCSCAN
		JNZ KON
		POP AX

NEXT:   INC CL
		MOV AL,CH
		TEST AL,08H
		JZ KERR
		ROL AL,1
		MOV CH,AL
		JMP COLUM
KERR:   JMP BEGIN
;========================================
;����ɨ���ӳ���
;========================================
CCSCAN: MOV AL,00H
        MOV DX,MY8255_A  
		OUT DX,AL
        MOV DX,MY8255_C 
        IN  AL,DX
		NOT AL
        AND AL,0FH
		RET
;========================================
;�����ӳ���
;========================================
CLEAR:  MOV DX,MY8255_B 
        MOV AL,00H
        OUT DX,AL
		RET
;========================================
;��ʾ�ӳ���
;========================================
DIS:    PUSH AX
		MOV SI,NOW
		MOV DL,0DFH
		MOV AL,DL
AGAIN:  PUSH DX
        MOV DX,MY8255_A 
        MOV XX,DI
        SUB XX,3000H
NEXT2:
        CMP XX,00H
        JE NEXT1
        ROR AL,1
        DEC XX
        JMP NEXT2
NEXT1:
        OUT DX,AL
        MOV AL,[SI]
        MOV BX,OFFSET DTABLE
		AND AX,00FFH
		ADD BX,AX
		MOV AL,[BX]
        MOV DX,MY8255_B 
		OUT DX,AL
		
		CALL DALLY
        POP DX
		
        
OUT1:   POP AX
		RET
;====== ��ʱ�ӳ��� ======		
DALLY:  PUSH CX
        MOV CX,0006H
T1:     MOV AX,009FH
T2:     DEC AX
		JNZ T2
		LOOP T1
		POP CX
		RET
;========================================
;�����ֵ����Ӧλ�Ļ�����
;========================================
PUTBUF: 
        CMP FLAG,1
        JE RIGHT
LEFT:
        MOV SI,DI
		MOV [SI],AL
		MOV NOW,DI
		INC DI
		CMP DI,3006H
		JNZ GOBACK
		MOV DI,3005H
		MOV FLAG,1
		JMP GOBACK
RIGHT:
        MOV SI,DI
		MOV [SI],AL
		MOV NOW,DI
		DEC DI
		CMP DI,2FFFH
		JNZ GOBACK
		MOV DI,3000H
		MOV FLAG,0
		JMP GOBACK
GOBACK: RET

CODE	ENDS
		END START