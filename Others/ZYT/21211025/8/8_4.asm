;8255�ӿڳ�ʼ������CS���ӵ�IOY�˿ھ���
A8255_CON EQU 0606H
A8255_A EQU 0600H           ;A�����������λ��ӿ�
A8255_B EQU 0602H           ;B����������ܶ���ӿ�
A8255_C EQU 0604H
;����ܵ����ݱ�
DATA SEGMENT
TABLE1:
    DB 06H	;����1�Ķ��룬��B��
    DB 5BH
    DB 4FH
DATA ENDS   
CODE SEGMENT
    ASSUME CS:CODE,DS:DATA
    
START:
	;8255��ʼ��
	MOV AL,10000001B	;AB�ھ����
	MOV DX,A8255_CON
	OUT DX,AL
	
	;�λ�ַ��ƫ��
	MOV AX,DATA   
	MOV DS,AX
	LEA SI,TABLE1
	
	;����λ��͵�ƽ��ѡ���ĸ�����ܽ�����������Ͷ�����ʾ�ĸ�����
NEXT2:
	MOV BX,05H	;Ҫ��ʾ����
	;������6��ʾ�����Ҷ�
	MOV CX,06H	;�ڲ�ѭ��
	MOV AL,11011111B  ;ѡ�����Ҷ�X6��A��P5 
NEXT1:
	;��ʾһ�����֣�����λ��
	MOV DX,A8255_A
	OUT DX,AL
	
	PUSH AX  
	;��ʾһ�����֣����Ͷ���
	MOV AL,[BX+SI]
	MOV DX,A8255_B
	OUT DX,AL
	
	POP AX
	ROR AL,1
	DEC BX
	CALL DELAY	
	LOOP NEXT1	;Ҫѭ��6��,CX+LOOP�Զ�ѭ��CX��
	
	JMP NEXT2
	
	
DELAY:
    PUSH CX
    MOV CX,000FFH
X4:
    LOOP X4
    MOV CX,000FFH
X5:
    LOOP X5
    POP CX
    RET
    	
CODE ENDS
END START