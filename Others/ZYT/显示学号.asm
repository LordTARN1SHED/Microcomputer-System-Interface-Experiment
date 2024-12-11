ASSUME CS:CODE,DS:DATA

DATA SEGMENT
NUMBER:
    DB 3FH ;0  
    DB 06H ;1
    DB 5BH ;2
    DB 4FH ;3
    DB 66H ;4
    DB 6DH ;5
    DB 7DH ;6
    DB 07H ;7
    DB 7FH ;8
    DB 6FH ;9
ZYT:
DB   5BH 
DB   06H
DB   06H
DB   3FH
DB   4FH
DB   5BH
DATA ENDS


CODE SEGMENT

START:

MOV AX,DATA  ;SET DS
MOV DS,AX

MOV DX,0646H ;SET 8255
MOV AL,90H
OUT DX,AL

SHOW:        ;SHOW
MOV DX,0640H   ;IN A 
IN AL,DX

        
LEA DI,ZYT   

MOV BL,0FEH
MOV CX,0006H
  
S:  
    PUSH BX
    OR BL,AL
    
    PUSH AX     ;OUT C
    MOV AL,BL    
    MOV DX,0644H
    OUT DX,AL
    POP AX


    PUSH AX     ;OUT B
    MOV AL,DS:[DI] 
    MOV DX,0642H 
    OUT DX,AL
    CALL DELAY
    ;CALL DELAY
    ;CALL DELAY
    ;CALL DELAY
    
    POP AX
     
    POP BX
    ROL BL,1 

    INC DI
    LOOP S
    ;CALL DELAY
    ;CALL DELAY
    ;CALL DELAY
    ;CALL DELAY
    
    
    JMP SHOW




DELAY:
PUSH CX
MOV CX,000FFH
LOOP $
POP CX
RET

CODE ENDS

END START
