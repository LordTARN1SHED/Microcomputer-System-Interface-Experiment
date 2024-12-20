MY8255_A EQU 0600H           ;A口连接数码管位码接口，兼4*4键盘的列扫描接口
MY8255_B EQU 0602H	;B口连接数码管段码接口
MY8255_C EQU 0604H
MY8255_CON  EQU 0606H
SSTACK  SEGMENT STACK
    DW 16 DUP(?)
SSTACK  ENDS
; DATBLE是 将需要输入按键的值对应需要给的显示器的值
; 比如按键1表示的值是1 但是我们送给显示器的是06H
; 该程序是通过判断按键按下 获取其代表的偏移量（相对于DTABLE）
; 比如按键1的偏移量是1 我们扫描按键 得出一个值 1
; 然后利用该值在DTABLE中找到需要输出值的对应显示代码值
; 从B口送出去即可
DATA SEGMENT
    DTABLE  DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH,77H,7CH,39H,5EH,79H,71H,00H ;0-9，A-F，00H表示不显示
DATA ENDS
CODE SEGMENT
    ASSUME CS:CODE,DS:DATA
START:
    MOV AX,DATA
    MOV DS,AX		;设置数据段段基址(当你自己定义了DATA数据段后要赋值DS)
    CALL CLEARSI	;清空内存显示数字
    MOV DX,MY8255_CON       ;写 8255 控制字
    MOV AL,81H		 ;10000001 表示AB口用于输出，C口低四位用于输入
    OUT DX,AL
;键盘扫描及数码管显示 Steps : 
;1.先看有没有键按下，注意消除抖动
BEGIN:
    CALL DIS              ;调用显示子程序
    CALL CCSCAN     ;扫描，看有没有按键按下
    JNZ INK1	;有按键按下
    JMP BEGIN	;没有按键按下
INK1:  
    CALL DIS	;显示数据
    CALL DALLY	;延时20ms
    CALL DALLY
    CALL CCSCAN	;再次扫描，确认有按键按下，消除抖动
    JNZ INK2             ;有键按下，转到 INK2，这次是真的有按键按下
    JMP BEGIN
;2.再确定按下键的位置,列扫描法
INK2:  
    MOV CH,0FEH	;向A口写入的要检查的列（列扫描）第0列是：1111 1110 B
    MOV CL,00H	;CL记录列号，即对应行的偏移量
    ;列循环 即扫描列 从第一列开始
COLUM:  
    MOV AL,CH
    MOV DX,MY8255_A   ;A口连接位选信号，选中第0列输出
    OUT DX,AL
    MOV DX,MY8255_C   ;C口低4位读行信号
    IN AL,DX
    
    ;L1~L4表示行号
    ;进行列扫描，检测到指定行号对应的位是1，其余位是0 
    ;第1~4行第一位代表的数分别是：00H，04H,08H,0CH
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
    JNZ NEXT	      ;4行都不是，说明不是这一列的，继续找下一列
    MOV AL,0CH              ;L4
KCODE:  
    ADD AL,CL	;和为键盘代表的数字 , AL是当前这一行的起始大小，CL是当前行的偏移
    CALL PUTBUF	;相应数字写入内存
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
;键盘扫描子程序
CCSCAN: 
    MOV AL,00H             	
    MOV DX,MY8255_A
    OUT DX,AL		;输出00H检测所有的列
    MOV DX,MY8255_C
    IN AL,DX		;如果有按键按下，其对应的行号的位将显示0，否则为1
    NOT AL		;取反，那么有按键按下的行号从0变成1
    AND AL,0FH		;检测是否有位的值为1
    RET
    
;清空内存显示数字子程序
CLEARSI:
    PUSH AX
    PUSH CX
    MOV CX,06H
    MOV SI,3000H
    MOV AL,00H          ;清缓存用00H
CLEARSI1:    
    MOV [SI],AL            ;清显示缓冲
    INC SI
    LOOP CLEARSI1
    POP CX
    POP AX
    RET
;显示子程序
;这里其实是从X6到X1依次显示的
;每个数字显示间隔很快 我们会认为是6个数字一起显示 其实是逐个显示
DIS: 
    PUSH AX                 
    MOV SI,3000H
    MOV DL,0DFH	;1101 1111 ，先输出第6位在最右边，依次往左输
    MOV AL,DL
    ;显示[SI]起始的六位数字到数码管，顺序是从右到左
    ;不能直接将要显示数字输出在A口，必须转换成与之对应的位选信号
    ;方式是将数字作为位移选择DATABLE中存储的
AGAIN:  
    PUSH DX
    MOV DX,MY8255_A          ;位选信号送A口
    OUT DX,AL
    MOV AL,[SI]	;[SI]里存的要输出哪个数字
    MOV BX,OFFSET DTABLE
    AND AX,00FFH
    ADD BX,AX	;OFFSET DTABLE + 哪个数字大小偏移
    MOV AL,[BX]	;取出这个地址的段码信号
    MOV DX,MY8255_B           ;段码信号送B口
    OUT DX,AL
    CALL DALLY
    INC SI
    POP DX
    MOV AL,DL
    TEST AL,01H
    JZ OUT1
    ROR AL,1                          ;右移1位，输下一个5->4->3->2->1
    MOV DL,AL
    JMP AGAIN
OUT1:  
    POP AX
    RET
;延时子程序
DALLY:  
    PUSH CX                
    MOV CX,0006H
    T1: MOV AX,009FH
    T2: DEC AX
    JNZ T2
    LOOP T1
    POP CX
    RET
; 将获得的偏移量存入3000H--3005H中
; 便于后面的显示 
; 显示其实就是从3000H--3005H中读取偏移量
; 然后在table中找到真正的值即可
;装载数据
PUTBUF: 
    PUSH AX
    MOV SI,3005H
    ;将正在显示的数字前移一位
GOAHEAD:
    MOV AL,[SI-1]
    MOV [SI],AL
    DEC SI
    CMP SI,3000H
    JNZ GOAHEAD
    POP AX
    MOV [SI],AL	;将键盘代表的数字写入显示位的最末位
        
    
GOBACK: 
    RET
CODE ENDS
    END START