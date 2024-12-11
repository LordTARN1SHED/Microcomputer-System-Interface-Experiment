;8255接口初始化，由CS连接的IOY端口决定
A8255_CON EQU 0606H
A8255_A EQU 0600H           ;A口连接数码管位码接口
A8255_B EQU 0602H           ;B口连接数码管段码接口
A8255_C EQU 0604H
;数码管的数据表
DATA SEGMENT
TABLE1:
    DB 06H	;数字1的段码，送B口
    DB 5BH
    DB 4FH
DATA ENDS   
CODE SEGMENT
    ASSUME CS:CODE,DS:DATA
    
START:
	;8255初始化
	MOV AL,10000001B	;AB口均输出
	MOV DX,A8255_CON
	OUT DX,AL
	
	;段基址和偏移
	MOV AX,DATA   
	MOV DS,AX
	LEA SI,TABLE1
	
	;先送位码低电平，选中哪个数码管进行输出，再送段码显示哪个数字
NEXT2:
	MOV BX,05H	;要显示的数
	;先数字6显示在最右端
	MOV CX,06H	;内层循环
	MOV AL,11011111B  ;选中最右端X6即A口P5 
NEXT1:
	;显示一个数字，先送位码
	MOV DX,A8255_A
	OUT DX,AL
	
	PUSH AX  
	;显示一个数字，再送段码
	MOV AL,[BX+SI]
	MOV DX,A8255_B
	OUT DX,AL
	
	POP AX
	ROR AL,1
	DEC BX
	CALL DELAY	
	LOOP NEXT1	;要循环6次,CX+LOOP自动循环CX次
	
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