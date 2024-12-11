;8255接口初始化，由CS连接的IOY端口决定
A8255_CON EQU 0606H
A8255_A EQU 0600H           ;A口连接数码管位码接口
A8255_B EQU 0602H           ;B口连接数码管段码接口
A8255_C EQU 0604H
;数码管的数据表，分别表示0-9
DATA SEGMENT
TABLE1:
    DB 3FH	;数字0的段码，送B口
    DB 06H
    DB 5BH
    DB 4FH
    DB 66H
    DB 6DH
    DB 7DH
    DB 07H
    DB 7FH
    DB 6FH	;数字9的段码，送B口
DATA ENDS   
CODE SEGMENT
    ASSUME CS:CODE,DS:DATA
START:
    MOV DX,A8255_CON	;写8255控制字	
    MOV AL,81H		;1000 0001 表示AB口输出
    OUT DX,AL    
    MOV AX,DATA    ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!数据段段基址
    MOV DS,AX     
    ;数据段变量TABLE1的偏移地址
    LEA SI,TABLE1
  
    MOV CX,0AH		;循环显示0~9这10个数字，数字0从右到左移动，再数字1从右到左移动,... 
    MOV BX,0000H		;BX表示要显示的数字     !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!初始化的值放在循环之外
X1: 
    PUSH CX    		;先保存外层循环次数
    MOV CX,06H    		;每个数字显示分别显示在6个数码管
    
    MOV AL,11011111B	;首先是最右侧的X6对应8255的PA5      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!初始化的值放在循环之外
X2:
    MOV DX,A8255_A               ;8255接口A连接位选接口
    OUT DX,AL
    
    ROR AL,1   		;循环右移显示位
    PUSH AX 		;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!后面又要用到AL，所以先push AX，保存AL内容
    
    MOV AL,[BX+SI]		;找到段码信号
    MOV DX,A8255_B               ;8255接口B连接段码接口
    OUT DX,AL     
    
    POP AX          		;保存的是循环右移后的位选信号，选中右边一个数码管进行点亮
    CALL DELAY		;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!送完delay一下
    LOOP X2		;内层循环CX次
    POP CX  		;弹出外层循环次数
    
    INC BX			;选中下一个要显示的数字
    LOOP X1 		;弹出外层循环次数CX
    
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