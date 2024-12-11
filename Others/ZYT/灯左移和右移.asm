ASSUME CS:CODE,DS:DATA

DATA SEGMENT
FLAG DB 0H
LIGHT DB 80H
DATA ENDS

CODE SEGMENT
START:

MOV AX,0000H  ;SET 
MOV DS,AX

MOV DX,0646H
MOV AX,90H
OUT DX,AL

MOV AX,OFFSET MIR6  ;INSTALL
MOV SI,0038H
MOV [SI],AX
MOV AX,CS
MOV SI,003AH
MOV [SI],AX

MOV AX,OFFSET MIR7
MOV SI,003CH
MOV [SI],AX
MOV AX,CS
MOV SI,003EH
MOV [SI],AX

CLI          ;SET INT_WORD
  MOV AL,11H
  OUT 20H,AL
  MOV AL,08H
  OUT 21H,AL
  MOV AL,04H
  OUT 21H,AL
  MOV AL,07H
  OUT 21H,AL
  MOV AL,2FH
  OUT 21H,AL
STI

MAIN:           ;MIAN

MOV DX,0642H
MOV AL,LIGHT
OUT DX,AL
CALL DELAY

S:
   CMP FLAG,0H
   JE  CONTINUE 
   CMP FLAG,2H
   JE  RIGHT
    
LEFT:
    ROL LIGHT,1
    MOV AL,LIGHT
    OUT DX,AL
    CALL DELAY
    CMP FLAG,1H 
    JE LEFT
      

RIGHT: 
     ROR LIGHT,1
     MOV AL,LIGHT
     OUT DX,AL
     CALL DELAY
     CMP FLAG,2H
     JE RIGHT
     

CONTINUE:   JMP S

MIR6:        ;MIR6
MOV FLAG,1H
IRET

MIR7:        ;MIR7
MOV FLAG,2H
IRET


DELAY:
PUSH CX
MOV CX,0FFFFH
LOOP $
POP CX
RET

CODE ENDS
END START