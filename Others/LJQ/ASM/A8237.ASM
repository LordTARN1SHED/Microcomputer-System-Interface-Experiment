;========================================================
; 文件名: DMA1.ASM
; 功能描述: 8237DMA传送实验，源地址为1000H，目标地址为
;     0000H，通过E命令改变8000:2000连续10个存储单元的值，
;     运行程序后，通过D8000:0000查看传送结果。
;========================================================

STACK SEGMENT STACK
	DW 64 DUP(?)
STACK ENDS

CODE SEGMENT
	ASSUME CS:CODE

START:	MOV AL, 00
		MOV DX, 061AH	
		OUT DX, AL			;发总清命令

AA1:	MOV AL, 00H
		MOV DX, 0600H			;通道0(Source)
		OUT DX,AL
		MOV AL,10H
		OUT DX,AL
		
		MOV AL,00H	
		MOV DX, 0604H			;通道1(Dest)
		OUT DX,AL
		MOV AL,00H
		OUT DX,AL
	
		MOV AL,0AH
		MOV DX, 0602H			;传输字节个数
		OUT DX,AL
		MOV AL,00H
		OUT DX,AL
	
		MOV AL,0AH
		MOV DX, 0606H			;传输字节个数
		OUT DX,AL
		MOV AL,00H
		OUT DX,AL
	
		MOV AL,88H
		MOV DX, 0616H			;通道0方式字
		OUT DX,AL
		MOV AL,85H				;通道1方式字
		OUT DX,AL
	
		MOV AL,81H
		MOV DX, 0610H			;命令字
		OUT DX,AL
	
		MOV AL,04H
		MOV DX, 0612H			;请求字
		OUT DX,AL
	
		MOV AL,00H
		MOV DX, 061EH			;屏蔽字
		OUT DX,AL
		
		MOV AX,4C00H
		INT 21H					;程序终止
CODE 	ENDS
     	END START