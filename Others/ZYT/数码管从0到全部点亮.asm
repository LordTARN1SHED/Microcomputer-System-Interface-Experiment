ASSUME CS:CODE,DS:DATA

DATA SEGMENT
LIGHT DB 
DATA ENDS

CODE SEGMENT 
START:


MOV AX,0000H  ;SET DS
MOV DS,AX

MOV AX,OFFSET MIR7 ;INSTALL
MOV SI,003CH
MOV [SI],AX
MOV AX,CS
MOV SI,003EH
MOV [SI],AX

CLI
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



MOV DX,0646H ;SET 8255
MOV AL,90H
OUT DX,AL

MOV DX,0606H ;SET 8254
MOV AL,76H
OUT DX,AL

MOV DX,0602H ;SET T1
MOV AL,00H
OUT DX,AL
MOV AL,48H
OUT DX,AL

MAIN:




JMP MAIN
MIR7:     ;MIR7
ROL LIGHT,1
INC LIGHT

MOV DX,0642H 
MOV AL,LIGHT
OUT DX,AL


IRET

CODE ENDS

END START
