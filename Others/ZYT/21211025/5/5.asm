;��ѯ
CODE SEGMENT
    ASSUME CS:CODE
START:
    MOV DX, 0686H  ;8255��ʼ����ͬ��
    MOV AL, 90H
    OUT DX, AL
 
X3: 
    MOV DX, 0640H  ;����AD����
    OUT DX, AL
 
X1: 
    MOV DX,0680H
    IN AL,DX       ;��8255A�ڶ���EOC״̬
    TEST AL,80H    ;���EOC�Ƿ�Ϊ�ߵ�ƽ
    JNZ X1         ;������ǵ͵�ƽ����ʾδ��ʼת������ת������ѯ
 
X2:
    MOV DX,0680H
    IN AL,DX       ;��8255A�ڶ���EOC״̬   
    TEST AL,80H    ;���EOC�Ƿ�Ϊ�ߵ�ƽ
    JZ X2          ;����Ǹߵ�ƽ����ʾװ�����
 
    MOV DX,0640H
    IN AL,DX       ;��ADC0809����ת����ɵ�����
    MOV DX, 0682H
    OUT DX,AL      ;��8255B�����ת����ɵ�����
    JMP X3         ;ѭ��ת��
CODE ENDS 
    END START