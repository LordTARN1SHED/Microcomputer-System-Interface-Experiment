CODE SEGMENT
    ASSUME CS:CODE
START: 
    ; 8255��ʼ��
    MOV DX, 0686H  ;8255���ƶ˿ڵ�ַ��ѡȡ��IOY2�˿ڣ����ƿڵ�ַ�� 0686H
    MOV AL, 90H    ;8255�����֣�90H=10010000B����ʾA�����룬B�����
    OUT DX, AL     ;������������д����ƶ˿�
MI:
    MOV AL,00H   ; ���� 0 ͨ��
    MOV DX, 0640H   ;����A/D���� IOY1����ADC0809��IOY1�ĵ�ַ�� 0640H
    OUT DX, AL
 
    CALL DELAY
    IN AL, DX      ;��A/D�������
 
    MOV DX, 0682H ;8255 B �ڵ�ַΪ 0682H������ IOY2
    OUT DX,AL   ;��������� B �� 
    JMP MI
    
DELAY:             ;��ʱ����
    PUSH CX        ;�����ֳ�
    MOV CX,0FFFFH;

L1: PUSH AX
    POP AX
    LOOP L1
    POP CX 
    RET
    
CODE ENDS 
    END START