MY8255_A EQU 0600H           ;A�����������λ��ӿڣ���4*4���̵���ɨ��ӿ�
MY8255_B EQU 0602H	;B����������ܶ���ӿ�
MY8255_C EQU 0604H
MY8255_CON  EQU 0606H
SSTACK  SEGMENT STACK
    DW 16 DUP(?)
SSTACK  ENDS
; DATBLE�� ����Ҫ���밴����ֵ��Ӧ��Ҫ������ʾ����ֵ
; ���簴��1��ʾ��ֵ��1 ���������͸���ʾ������06H
; �ó�����ͨ���жϰ������� ��ȡ������ƫ�����������DTABLE��
; ���簴��1��ƫ������1 ����ɨ�谴�� �ó�һ��ֵ 1
; Ȼ�����ø�ֵ��DTABLE���ҵ���Ҫ���ֵ�Ķ�Ӧ��ʾ����ֵ
; ��B���ͳ�ȥ����
DATA SEGMENT
    DTABLE  DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH,77H,7CH,39H,5EH,79H,71H,00H ;0-9��A-F��00H��ʾ����ʾ
DATA ENDS
CODE SEGMENT
    ASSUME CS:CODE,DS:DATA
START:
    MOV AX,DATA
    MOV DS,AX		;�������ݶζλ�ַ(�����Լ�������DATA���ݶκ�Ҫ��ֵDS)
    CALL CLEARSI	;����ڴ���ʾ����
    MOV DX,MY8255_CON       ;д 8255 ������
    MOV AL,81H		 ;10000001 ��ʾAB�����������C�ڵ���λ��������
    OUT DX,AL
;����ɨ�輰�������ʾ Steps : 
;1.�ȿ���û�м����£�ע����������
BEGIN:
    CALL DIS              ;������ʾ�ӳ���
    CALL CCSCAN     ;ɨ�裬����û�а�������
    JNZ INK1	;�а�������
    JMP BEGIN	;û�а�������
INK1:  
    CALL DIS	;��ʾ����
    CALL DALLY	;��ʱ20ms
    CALL DALLY
    CALL CCSCAN	;�ٴ�ɨ�裬ȷ���а������£���������
    JNZ INK2             ;�м����£�ת�� INK2�����������а�������
    JMP BEGIN
;2.��ȷ�����¼���λ��,��ɨ�跨
INK2:  
    MOV CH,0FEH	;��A��д���Ҫ�����У���ɨ�裩��0���ǣ�1111 1110 B
    MOV CL,00H	;CL��¼�кţ�����Ӧ�е�ƫ����
    ;��ѭ�� ��ɨ���� �ӵ�һ�п�ʼ
COLUM:  
    MOV AL,CH
    MOV DX,MY8255_A   ;A������λѡ�źţ�ѡ�е�0�����
    OUT DX,AL
    MOV DX,MY8255_C   ;C�ڵ�4λ�����ź�
    IN AL,DX
    
    ;L1~L4��ʾ�к�
    ;������ɨ�裬��⵽ָ���кŶ�Ӧ��λ��1������λ��0 
    ;��1~4�е�һλ��������ֱ��ǣ�00H��04H,08H,0CH
L1: 
    TEST AL,01H             ;is L1?
    JNZ L2
    MOV AL,00H              ;L1
    JMP KCODE
L2: 
    TEST AL,02H             ;is L2?
    JNZ L3
    MOV AL,04H              ;L2
    JMP KCODE
L3: 
    TEST AL,04H             ;is L3?
    JNZ L4
    MOV AL,08H              ;L3
    JMP KCODE
L4: 
    TEST AL,08H             ;is L4?
    JNZ NEXT	      ;4�ж����ǣ�˵��������һ�еģ���������һ��
    MOV AL,0CH              ;L4
KCODE:  
    ADD AL,CL	;��Ϊ���̴�������� , AL�ǵ�ǰ��һ�е���ʼ��С��CL�ǵ�ǰ�е�ƫ��
    CALL PUTBUF	;��Ӧ����д���ڴ�
KON: 
    CALL DIS
    CALL CCSCAN
    JNZ KON
    JMP BEGIN
NEXT:  
    INC CL
    MOV AL,CH
    TEST AL,08H
    JZ KERR
    ROL AL,1
    MOV CH,AL
    JMP COLUM
KERR:   
    JMP BEGIN
;����ɨ���ӳ���
CCSCAN: 
    MOV AL,00H             	
    MOV DX,MY8255_A
    OUT DX,AL		;���00H������е���
    MOV DX,MY8255_C
    IN AL,DX		;����а������£����Ӧ���кŵ�λ����ʾ0������Ϊ1
    NOT AL		;ȡ������ô�а������µ��кŴ�0���1
    AND AL,0FH		;����Ƿ���λ��ֵΪ1
    RET
    
;����ڴ���ʾ�����ӳ���
CLEARSI:
    PUSH AX
    PUSH CX
    MOV CX,06H
    MOV SI,3000H
    MOV AL,00H          ;�建����00H
CLEARSI1:    
    MOV [SI],AL            ;����ʾ����
    INC SI
    LOOP CLEARSI1
    POP CX
    POP AX
    RET
;��ʾ�ӳ���
;������ʵ�Ǵ�X6��X1������ʾ��
;ÿ��������ʾ����ܿ� ���ǻ���Ϊ��6������һ����ʾ ��ʵ�������ʾ
DIS: 
    PUSH AX                 
    MOV SI,3000H
    MOV DL,0DFH	;1101 1111 ���������6λ�����ұߣ�����������
    MOV AL,DL
    ;��ʾ[SI]��ʼ����λ���ֵ�����ܣ�˳���Ǵ��ҵ���
    ;����ֱ�ӽ�Ҫ��ʾ���������A�ڣ�����ת������֮��Ӧ��λѡ�ź�
    ;��ʽ�ǽ�������Ϊλ��ѡ��DATABLE�д洢��
AGAIN:  
    PUSH DX
    MOV DX,MY8255_A          ;λѡ�ź���A��
    OUT DX,AL
    MOV AL,[SI]	;[SI]����Ҫ����ĸ�����
    MOV BX,OFFSET DTABLE
    AND AX,00FFH
    ADD BX,AX	;OFFSET DTABLE + �ĸ����ִ�Сƫ��
    MOV AL,[BX]	;ȡ�������ַ�Ķ����ź�
    MOV DX,MY8255_B           ;�����ź���B��
    OUT DX,AL
    CALL DALLY
    INC SI
    POP DX
    MOV AL,DL
    TEST AL,01H
    JZ OUT1
    ROR AL,1                          ;����1λ������һ��5->4->3->2->1
    MOV DL,AL
    JMP AGAIN
OUT1:  
    POP AX
    RET
;��ʱ�ӳ���
DALLY:  
    PUSH CX                
    MOV CX,0006H
    T1: MOV AX,009FH
    T2: DEC AX
    JNZ T2
    LOOP T1
    POP CX
    RET
; ����õ�ƫ��������3000H--3005H��
; ���ں������ʾ 
; ��ʾ��ʵ���Ǵ�3000H--3005H�ж�ȡƫ����
; Ȼ����table���ҵ�������ֵ����
;װ������
PUTBUF: 
    PUSH AX
    MOV SI,3005H
    ;��������ʾ������ǰ��һλ
GOAHEAD:
    MOV AL,[SI-1]
    MOV [SI],AL
    DEC SI
    CMP SI,3000H
    JNZ GOAHEAD
    POP AX
    MOV [SI],AL	;�����̴��������д����ʾλ����ĩλ
        
    
GOBACK: 
    RET
CODE ENDS
    END START