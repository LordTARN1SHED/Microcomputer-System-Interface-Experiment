DATA SEGMENT 
    SIGN DB 00H    
DATA ENDS
CODE SEGMENT 
    ASSUME CS:CODE,DS:DATA
START: 
    MOV AX, 0000H
    MOV BX, 0000H
    MOV DS, AX           
 
    MOV DX, 0646H
    MOV AL, 90H
    OUT DX, AL        
    MOV DX, 0642H       
    MOV AL,80H        
    OUT DX,AL        
    

    MOV AX, OFFSET MIR6
    MOV SI, 0038H      
    MOV [SI], AX       
    MOV AX, CS         
    MOV SI, 003AH
    MOV [SI], AX
    MOV AX, OFFSET MIR7
    MOV SI, 003CH
    MOV [SI], AX
    MOV AX, CS
    MOV SI, 003EH
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
 
MI:
	CMP SIGN,00H
	JZ MI
    CMP SIGN,02H      
    JE A2			 
A1: 
    CLI
    MOV DX, 0642H
    IN AL,DX          
    CMP AL,01H        
    JE AA1            
    ROR AL,1         
    CALL DELAY       
    CALL DELAY
    OUT DX,AL         
    JMP MI            
AA1:
    CMP BL ,80H
    JNZ AAA1
	MOV SIGN,00H
	STI
	JMP MI 
AAA1:
    MOV AL, BL
    MOV SIGN, 02H
    STI
    MOV AL ,BL
	JMP X
A2: 
    MOV DX, 0642H
    IN AL,DX
X:    ;MOV AL ,BL
    CMP AL,80H       
    JE AA2           
    ROL AL,1         
    CALL DELAY       
    CALL DELAY
    OUT DX,AL        
    JMP MI          
AA2:
	MOV SIGN,00H
	JMP MI
 
MIR6:
    STI
    MOV DX, 0642H
    IN AL,DX 
    MOV BL, AL             
    MOV SIGN,01H     
    IRET
 
MIR7:  
    STI
    MOV DX, 0642H
    IN AL,DX
    MOV BL, AL              
    MOV SIGN,02H     
    IRET

DELAY PROC NEAR  
	MOV CX,0FFFFH
	LOOP $
	RET
DELAY ENDP 
 
CODE ENDS
    END START

