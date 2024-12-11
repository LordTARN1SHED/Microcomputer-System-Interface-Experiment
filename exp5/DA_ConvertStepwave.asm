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
	   MOV AX,00H
	   MOV DX, ADC0809
	   MOV CX,0FH
	   ;MOV AL,00H
           MOV BL,0FH

AA1:
	   ;½×ÌÝ²¨
                   CMP BL,00H
           JE CHANGE
	   OUT DX,AL
           DEC BL
           JMP AA1
CHANGE:
           MOV BL,0FH
	   CALL DELAY
	   ADD AL,0FH
	   CMP AL,0FFH
	   JNE AA1
AA3:	   
	   MOV AL,00H
	   LOOP AA1


OVER:
	   MOV AL,00H
	   OUT DX,AL
	   CALL DELAY
	   JMP OVER
	   
DELAY: PUSH CX
       MOV  CX,0F00H
AA2:   PUSH AX
       POP  AX
	   LOOP AA2
   	   POP  CX
	   RET
	   
CODE ENDS
	 END START