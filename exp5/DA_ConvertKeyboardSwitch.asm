SSTACK	SEGMENT STACK
		DW 64 DUP(?)
SSTACK	ENDS
;0809Ñ¡ÔñIOY0¶Ë¿Ú
ADC0809 EQU 0600H

;0832Ñ¡ÔñIOY3¶Ë¿Ú
DAC0832 EQU 06C0H

CODE SEGMENT
	ASSUME CS:CODE 

START:

    MOV AX, OFFSET MIR6
    MOV SI, 0038H      
    MOV [SI], AX       
    MOV AX, CS         
    MOV SI, 003AH
    MOV [SI], AX

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
    STI

	   MOV AX,00H
	   MOV DX, ADC0809
	   MOV CX,0FH
	   ;MOV AL,00H
       MOV BH,00H

JCC:
           NOP
JCAA1:
	   ;¾â³Ý²¨
	   OUT DX,AL
	   CALL DELAY
	   INC AL
	   INC AL
	   INC AL
	   INC AL
	   CMP AL,0F0H
	   JNE JCAA1
JCAA3:	   
	   MOV AL,00H
	   JMP JCAA1


JX:
       MOV BL, 00H
JXAA1:
	   ;¾ØÐÎ²¨
	   PUSH AX
	   MOV AL,BL
	   OUT DX,AL
	   POP AX
	   CALL DELAY
	   INC AL
	   CMP AL,2FH
	   JNE JXAA1
JXAA3:	   
       MOV AL,00H
	   NOT BL
	   JMP JXAA1


SJ:
           NOP
SJAA1:
	   ;Èý½Ç²¨
	   OUT DX,AL
	   CALL DELAY2
	   INC AL
	   CMP AL,0F0H
	   JNE SJAA1

SJAA3:	   
	   OUT DX,AL
	   CALL DELAY2
	   DEC AL
	   CMP AL,00H
	   JNE SJAA3
       JMP SJAA1


JT:
           MOV BL,0FH
JTAA1:
	   ;½×ÌÝ²¨
           CMP BL,00H
           JE CHANGE
	       OUT DX,AL
	       CALL DELAY
           DEC BL
           JMP JTAA1
CHANGE:
       MOV BL,0FH
	   CALL DELAY
	   ADD AL,20H
	   CMP AL,0FFH
	   JNE JTAA1
JTAA3:	   
	   MOV AL,00H
	   JMP JTAA1



OVER:
	   MOV AL,00H
	   OUT DX,AL
	   CALL DELAY
	   JMP OVER
	   



MIR6:
    STI
    INC BH
    CMP BH,04H
    JNE NOTSET
    MOV BH,00H
NOTSET:
    CMP BH,00H
    JE JCC
    CMP BH,01H
    JE JX
    CMP BH,02H
    JE SJ
    CMP BH,03H
    JE JT
    IRET
    
DELAY: PUSH CX
       MOV  CX,0F00H
AA2:   PUSH AX
       POP  AX
	   LOOP AA2
   	   POP  CX
	   RET


DELAY2: PUSH CX
       MOV  CX,0400H
AA22:   PUSH AX
       POP  AX
	   LOOP AA22
   	   POP  CX
	   RET
	   
CODE ENDS
	 END START