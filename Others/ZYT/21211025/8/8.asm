;8255�ӿڳ�ʼ������CS���ӵ�IOY�˿ھ���
A8255_CON EQU 0606H
A8255_A EQU 0600H           ;A�����������λ��ӿ�
A8255_B EQU 0602H           ;B����������ܶ���ӿ�
A8255_C EQU 0604H
;����ܵ����ݱ��ֱ��ʾ0-9
DATA SEGMENT
TABLE1:
    DB 3FH	;����0�Ķ��룬��B��
    DB 06H
    DB 5BH
    DB 4FH
    DB 66H
    DB 6DH
    DB 7DH
    DB 07H
    DB 7FH
    DB 6FH	;����9�Ķ��룬��B��
DATA ENDS   
CODE SEGMENT
    ASSUME CS:CODE,DS:DATA
START:
    MOV DX,A8255_CON	;д8255������	
    MOV AL,81H		;1000 0001 ��ʾAB�����
    OUT DX,AL    
    MOV AX,DATA    ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!���ݶζλ�ַ
    MOV DS,AX     
    ;���ݶα���TABLE1��ƫ�Ƶ�ַ
    LEA SI,TABLE1
  
    MOV CX,0AH		;ѭ����ʾ0~9��10�����֣�����0���ҵ����ƶ���������1���ҵ����ƶ�,... 
    MOV BX,0000H		;BX��ʾҪ��ʾ������     !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!��ʼ����ֵ����ѭ��֮��
X1: 
    PUSH CX    		;�ȱ������ѭ������
    MOV CX,06H    		;ÿ��������ʾ�ֱ���ʾ��6�������
    
    MOV AL,11011111B	;���������Ҳ��X6��Ӧ8255��PA5      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!��ʼ����ֵ����ѭ��֮��
X2:
    MOV DX,A8255_A               ;8255�ӿ�A����λѡ�ӿ�
    OUT DX,AL
    
    ROR AL,1   		;ѭ��������ʾλ
    PUSH AX 		;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!������Ҫ�õ�AL��������push AX������AL����
    
    MOV AL,[BX+SI]		;�ҵ������ź�
    MOV DX,A8255_B               ;8255�ӿ�B���Ӷ���ӿ�
    OUT DX,AL     
    
    POP AX          		;�������ѭ�����ƺ��λѡ�źţ�ѡ���ұ�һ������ܽ��е���
    CALL DELAY		;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!����delayһ��
    LOOP X2		;�ڲ�ѭ��CX��
    POP CX  		;�������ѭ������
    
    INC BX			;ѡ����һ��Ҫ��ʾ������
    LOOP X1 		;�������ѭ������CX
    
    JMP START  
  
DELAY:
    PUSH CX
    MOV CX,0FFFFH
X4:
    LOOP X4
    MOV CX,0FFFFH
X5:
    LOOP X5
    POP CX
    RET
CODE ENDS
     END START