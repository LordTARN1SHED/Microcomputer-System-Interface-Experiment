;=========================================================
; 文件名: INT1.ASM
; 功能描述: 8259中断实验，中断源为主片8259的IRQ7
;           每产生一次中断输出显示一个字符7
;=========================================================

SSTACK	SEGMENT STACK
		DW 32 DUP(?)
SSTACK	ENDS

CODE   	SEGMENT
	   	ASSUME CS:CODE
START: 	PUSH DS
		MOV AX, 0000H
		MOV DS, AX
		MOV AX, OFFSET MIR7		;取中断入口地址
		MOV SI, 003CH			;中断矢量地址
		MOV [SI], AX			;填IRQ7的偏移矢量
		MOV AX, CS				;段地址
		MOV SI, 003EH
		MOV [SI], AX			;填IRQ7的段地址矢量
		CLI
		POP DS
		;初始化主片8259
		MOV AL, 11H
		OUT 20H, AL				;ICW1
		MOV AL, 08H
		OUT 21H, AL				;ICW2
		MOV AL, 04H
		OUT 21H, AL				;ICW3
		MOV AL, 01H
		OUT 21H, AL				;ICW4
		;初始化从片8259
  	    ;MOV AL,11H
        ;OUT 0A0H,AL
        ;MOV AL,30H
        ;OUT 0A1H,AL
        ;MOV AL,02H
        ;OUT 0A1H,AL
        ;MOV AL,01H
        ;OUT 0A1H,AL
        ;MOV AL,0FFH
        ;OUT 0A1H,AL
						
		MOV AL, 6FH				;OCW1
		OUT 21H, AL
		STI
AA1:	NOP
		JMP AA1
		
MIR7:	STI
		CALL DELAY
		MOV AX, 0137H
		INT 10H					;显示字符7
		MOV AX, 0120H
		INT 10H
		MOV AL, 20H
		OUT 20H, AL				;中断结束命令
		IRET
		
DELAY:	PUSH CX
		MOV CX, 0F00H
AA0:	PUSH AX
		POP  AX
		LOOP AA0
		POP CX
		RET
		
CODE	ENDS
		END  START