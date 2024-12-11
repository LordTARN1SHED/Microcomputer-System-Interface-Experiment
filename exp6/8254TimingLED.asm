
;=========================================================

;=========================================================
 
IOY0     EQU  0600H             ;IOY0
A8254    EQU  IOY0+00H*2
B8254    EQU  IOY0+01H*2
C8254    EQU  IOY0+02H*2
CON8254  EQU  IOY0+03H*2

MY8255_A    EQU 0640H;PA�˿�
MY8255_B    EQU 0642H;PB�˿�
MY8255_MODE EQU 0646H;���ƼĴ����˿�
 
SSTACK  SEGMENT STACK
        DW 32 DUP(?)
SSTACK  ENDS
 
CODE    SEGMENT
        ASSUME CS:CODE
START:  
    MOV BL,00H
    
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

        MOV  DX,MY8255_MODE;ͨ�����ƼĴ����˿ڳ�ʼ��8255
        MOV  AL,90H
        OUT  DX,AL
       
        MOV DX, CON8254         ;8254
        MOV AL, 36H             ;������0,��ʽ3
        OUT DX, AL
        MOV DX, A8254
        MOV AL, 0E8H
        OUT DX, AL
        MOV AL, 03H
        OUT DX, AL
        MOV DX, CON8254         ;8254
        MOV AL, 76H             ;������1,��ʽ3
        OUT DX, AL
        MOV DX, B8254
        MOV AL, 0E8H
        OUT DX, AL
        MOV AL, 03H
        OUT DX, AL
AA1:    JMP AA1


MIR6:
    STI
    ROL BL,1
    INC BL
    PUSH AX
    MOV AL,BL
    MOV  DX,MY8255_B;��AL����Ϣת��PB�˿ڣ����ݣ�
    OUT  DX,AL
    POP AX
    
    IRET

CODE    ENDS
        END  START