;========================================================
; �ļ���:   Wmd861.Asm
; ��������: ��ʼ���ڴ�3000H��ַ��Ԫ��ʼ��16���ֽڣ�����
;           Ϊ0��15��16�����ݡ�
;========================================================
; ʵ��Ŀ��: ��ʵ��Ϊϵͳ��ʶʵ�飬Ŀ������ͨ����ʵ����
;           ѧϰʵ��ϵͳ��ʹ�á�
;========================================================

SSTACK	SEGMENT STACK				;�����ջ��
		DW 32 DUP(?)
SSTACK	ENDS

CODE	SEGMENT
		ASSUME CS:CODE, SS:SSTACK
START:	PUSH DS
		XOR AX, AX
		MOV DS, AX
		MOV SI, 3000H				;����������ʼ��ַ
		MOV CX, 16					;ѭ������
AA1:	MOV [SI], AL
		INC SI						;��ַ�Լ�1
		INC AL						;�����Լ�1
		LOOP AA1
		MOV AX,4C00H
		INT 21H						;������ֹ
CODE	ENDS
		END START
	