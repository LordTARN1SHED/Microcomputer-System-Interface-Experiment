;接IOY0
A8255 EQU 0600H
B8255 EQU 0602H
C8255 EQU 0604H
CON8255  EQU 0606H

DATA SEGMENT
        LIST DB 3FH ,06H, 5BH, 4FH, 66H ,6DH, 7DH, 07H, 7FH, 6FH,77H,7CH,39H,5EH,79H,71H,00H
    TABLER :
    	DB  0EEH,0DEH,0BEH,7EH
        DB  0EDH,0DDH,0BDH,7DH
        DB  0EBH,0DBH,0BBH,7BH
        DB  0E7H,0D7H,0B7H,77H
    TIME DB 00H, 00H    
    FLAGS DB 00H;控制数码管的显示与否，1为显示，0为不显示
    FLAGI DB 00H;记录初始化是输入的第一个数还是第二个数
    FLAGB DB 00H ;记录B键是第一次按还是第二次按 
    FLAGA DB 00H;记录A键是第几次按下
    FLAGSS DB 00H;
    SHUMA DB 00H, 00H, 00H, 00H
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE,DS:DATA
START: 
    CALL INITIALIZE   
L1: 
    CALL SHOW
    CALL DELAY
    CALL CLEAR
    MOV DX,A8255
    MOV AL,00H
    OUT DX,AL
    MOV DX,C8255
    IN AL,DX
    AND AL,0FH
    CMP AL,0FH
    JZ L1;按键全部为高电平，没有键按下
    CALL DELAY;消除前沿抖动
    MOV DX,A8255
    MOV AL,00H
    OUT DX,AL
    MOV DX,C8255
    IN AL,DX
    AND AL,0FH
    CMP AL,0FH
    JZ L1;消抖前的按键是由于干扰
    ;到此说明有按键输入
    MOV AH,11111110B
    MOV DX,A8255
    MOV CX,04H
L3: 
    MOV AL,AH
    MOV DX,A8255
    OUT DX,AL
    MOV DX,C8255
    IN AL,DX
    AND AL,0FH
    CMP AL,0FH
    JNZ L2;L2是行扫描成功，确定了行数
    ROL AH,1
    LOOP L3
    JMP L1;行扫描没成功的处理-
L2:
    MOV CL,4
    SHL AH,CL;AH的高四位是行数
    OR AL,AH;此时AL的高四位为行数，低四位为列数
    LEA SI,TABLER
    MOV BL,00H 
    MOV BH,00H
L5: CMP AL,[SI+BX]
    JZ L4;确定了AL代表的是哪个键码，值在BL中，进行数码管显示
    INC BL
    CMP BL,0DH
    JNZ L5;键码已经小于16个
    JMP L1;键码值已经大于16个了，但还是没找到，放弃本次显示，重新按键输入
    
L4:;此时键码的偏移量已经在BL中了
    CMP BL,0AH
    JE CALLA
    CMP BL,0BH
    JE CALLB
    CMP BL,0CH
    JE CALLC  
    LEA SI,FLAGI
    MOV AL,[SI]
    CMP AL,01H
    JBE INPUT
    JMP L1;初始化之后按得无效键
CALLA:
    CALL CALLA1
L6:    
	MOV DX,A8255;按键是否松开
    MOV AL,00H
    OUT DX,AL
    MOV DX,C8255
    IN AL,DX
    AND AL,0FH
    CMP AL,0FH
    JE LBACK
    CALL SHOW
    JMP L6
CALLB:
    CALL CALLB1
L7:    
	MOV DX,A8255;按键是否松开
    MOV AL,00H
    OUT DX,AL
    MOV DX,C8255
    IN AL,DX
    AND AL,0FH
    CMP AL,0FH
    JE LBACK
    CALL SHOW
    JMP L7
INPUT:
    CALL INPUT1
L8:    
	MOV DX,A8255;按键是否松开
    MOV AL,00H
    OUT DX,AL
    MOV DX,C8255
    IN AL,DX
    AND AL,0FH
    CMP AL,0FH
    JE LBACK
    CALL SHOW
    CALL DELAY
    CALL CLEAR
    JMP L8
LBACK:  
    JMP L1

;===================================================================
CALLC:
    CALL CLEAR
    MOV AH,4CH
    INT 21H 
;================================================================================    
INITIALIZE:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    ;设置中断向量
    MOV AX,0000H
    MOV DS,AX
	MOV AX,OFFSET MIR6
	MOV SI,0038H
	MOV [SI],AX
	INC SI
	INC SI
	MOV AX,CS
	MOV [SI],AX
	
	CLI 	;关中断
	MOV AL,11H    
    OUT 20H, AL    ;命令字ICW1，11H=00010001B
    MOV AL, 08H
    OUT 21H, AL    ;命令字ICW2，08H=00001000B
    MOV AL, 04H
    OUT 21H, AL    ;命令字ICW3，04H=00000100B
    MOV AL, 07H
    OUT 21H, AL    ;命令字ICW4，01H=00000001B
    MOV AL, 2FH    ;OCW1
    OUT 21H, AL 
    STI 
         
    MOV AX,DATA
	MOV DS,AX 
	
	LEA SI,FLAGA
	MOV AL,00H
	MOV [SI],AL
	 
	LEA SI,FLAGB
	MOV AL,00H
	MOV [SI],AL
	
	LEA SI,FLAGS
	MOV AL,00H
	MOV [SI],AL
	
	LEA SI,FLAGI
	MOV AL,00H
	MOV [SI],AL
	
	LEA SI,TIME
	MOV AL,00H
	MOV [SI],AL
	MOV [SI+1],AL
	
	LEA SI,SHUMA
	MOV AL,16
	MOV [SI],AL
	MOV [SI+1],AL
	MOV [SI+2],AL
	MOV [SI+3],AL
		
    ;将8254 cs接IOY1，地址是0640H
	MOV DX,0646H
	MOV AL,36H
	OUT DX,AL
	MOV DX,0640H
	MOV AL,0e8H
	OUT DX,AL			;03e8
	MOV AL,03H
	OUT DX,AL;选定计数器0持续产生方波3

	MOV DX,0646H
	MOV AL,76H
	OUT DX,AL;选定计数器1工作在方式3,并且写入16位数字
	MOV DX,0642H
	MOV AL,00H 			;4800
	OUT DX,AL
	MOV AL,48H
	OUT DX,AL

;将CLK2接在系统的CLK上

    MOV DX,CON8255
    MOV AL,81H
    OUT DX,AL;设置8255控制字，使得A,B口和C口低四位进行输入
    MOV DX,A8255
    MOV AL,00H
    OUT DX,AL
    MOV DX,B8255
    MOV AL,48H
    OUT DX,AL;开始时数码管不显示
   	CALL DELAY
   	CALL CLEAR
   

POP DI
POP SI
POP DX
POP CX
POP BX
POP AX
RET
;=============================================================
CALLA1:
    PUSH  AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI 
    LEA SI,FLAGA
    MOV AL,[SI]
    CMP AL,00H
    JNE CA1 
    LEA SI,FLAGS
    MOV AL,01H
    MOV [SI],AL;通知中断可以开始显示倒计时了
    LEA SI,FLAGI
    MOV AL,[SI]
    CMP AL,01H
    JA CA2;输入时输入了两个数，那么数码管1也要显示值 
    LEA SI,TIME
    LEA DI,SHUMA
    MOV AL,00H ;只输入了一个数，开始显示为0X00
    MOV [DI],AL
    MOV AL,[SI]
    MOV [DI+1],AL
    MOV AL,00H
    MOV [DI+2],AL
    MOV [DI+3],AL 
    LEA SI,FLAGA;表示第一次按下A键
    MOV AL,01H
    MOV [SI],AL
    JMP CABACK 
     
     
CA2: 
    LEA SI,TIME
    LEA DI,SHUMA
    MOV AL,[SI]  ;并且开始显示数为XX00
    MOV [DI],AL
    MOV AL,[SI+1]
    MOV [DI+1],AL
    MOV AL,00H
    MOV [DI+2],AL
    MOV AL,00H
    MOV [DI+3],AL
    
    LEA SI,FLAGA;表示第一次按下A键
    MOV AL,01H
    MOV [SI],AL
    JMP CABACK 
CA1:
    CALL INITIALIZE 
CABACK:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
;==================================================================
CALLB1: 
    PUSH  AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    LEA SI,FLAGB
    MOV AL,[SI]
    CMP AL,00H ;说明是第一次按下B键
    JNE CB1
    INC AL
    MOV [SI],AL
    LEA SI,FLAGS
    MOV AL,00H;暂停
    MOV [SI],AL
    JMP CBBACK
CB1: 
    LEA SI,FLAGB
    MOV AL,00H
    MOV [SI],AL
    LEA SI,FLAGS
    MOV AL,01H;继续
    MOV [SI],AL
CBBACK:
	POP DI
	POP SI
	POP DX
	POP CX
	POP BX
	POP AX 
    RET

;====================================================================
INPUT1:
   PUSH  AX
  ;  PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI 
    LEA SI,FLAGI
    MOV AL,[SI]
    CMP AL,00H
    JNE I1;输入的是第二个数
    LEA SI,TIME
    MOV [SI],BL
    LEA SI,SHUMA
    MOV [SI+0],BL;放数到数码管3
    MOV AL,01H
    LEA SI,FLAGI
    MOV [SI],AL
    JMP IBACK
I1:
    LEA SI,TIME
    MOV [SI+1],BL
    LEA SI,SHUMA
    MOV [SI+1],BL
    MOV AL,02H
    LEA SI,FLAGI
    MOV [SI],AL
IBACK:
    POP DI
    POP SI
    POP DX
    POP CX
  ;  POP BX
    POP AX 
    RET
    
;=====================================================================
MIR6:
    PUSH  AX ;先show之后检测是否是0000
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
   LEA SI,FLAGSS
   MOV AL,[SI]
   INC AL
   MOV [SI],AL
   CMP AL,01H
   JNE MBACK
   MOV AL,00H
   MOV [SI],AL
    LEA SI,FLAGS
    MOV AL,[SI]
    CMP AL,01H
    JE M9;数码管标志位是0不让显示
MBACK:    
    MOV AL,20H
	OUT 20H,AL
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    IRET
M9:    CALL SHOW
    LEA SI,SHUMA
    MOV AL,[SI+3];数码管4，秒的个位
    CMP AL,00H
    JE M2;秒的个位是0
    DEC AL
    MOV [SI+3],AL
    JMP MBACK;秒的个位-1返回
M2:
    LEA SI,SHUMA
    MOV AL,[SI+2]
    CMP AL,00H
    JE M3;秒的个位十位都为0，向分借位
    
    ;到这里是秒的十位不为0，个位为0
    DEC AL
    MOV [SI+2],AL
    MOV AL,09H
    MOV [SI+3],AL;十位减一，个位置9
    JMP MBACK

M3:
    LEA SI,SHUMA
    MOV AL,[SI+1]
    CMP AL,00H
    JE M4;分的个位，秒的十位和个位均为零
    DEC AL
    MOV [SI+1],AL
    MOV AL,05H
    MOV [SI+2],AL
    MOV AL,09H
    MOV [SI+3],AL
    JMP MBACK
M4:
    LEA SI,SHUMA
    MOV AL,[SI]
    CMP AL,00H
    JE M5;分和秒都是0
    DEC AL
    MOV [SI],AL
    MOV AL,09H
    MOV [SI+1],AL
    MOV AL,05H
    MOV [SI+2],AL
    MOV AL,09H
    MOV [SI+3],AL
    JMP MBACK 
M5:
    ;到这里说明是0000了，计时结束，闪烁三次，回到初始状态
    MOV CX,0FFH
M6:
    CALL SHOW
    LOOP M6
    CALL LDELAY;时间长一些，看出来是在闪烁
    MOV CX,0FFH
M7:
    CALL SHOW
    LOOP M7
   	CALL LDELAY;时间长一些，看出来是在闪烁
    MOV CX,0FFH
M8:
    CALL SHOW
    LOOP M8    
    CALL INITIALIZE;回到初始状态
    JMP MBACK

    
;======================================================================
SHOW:
    PUSH  AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    MOV DX,A8255
    MOV AL,11111110B
    OUT DX,AL
    LEA DI,SHUMA
    MOV AL,[DI]
    MOV AH,00H
    MOV BX,AX
    LEA DI,LIST
    MOV AL,[DI+BX]
    MOV DX,B8255
    OUT DX,AL
    CALL DELAY
    CALL CLEAR 
    
    
    MOV DX,A8255
    MOV AL,11111101B
    OUT DX,AL
    LEA DI,SHUMA
    MOV AL,[DI+1]
    MOV AH,00H
    MOV BX,AX
    LEA DI,LIST
    MOV AL,[DI+BX]
    MOV DX,B8255
    OUT DX,AL
    CALL DELAY
    CALL CLEAR 
    
    
    MOV DX,A8255
    MOV AL,11111011B
    OUT DX,AL
    LEA DI,SHUMA
    MOV AL,[DI+2]
    MOV AH,00H 
    MOV BX,AX
    LEA DI,LIST
    MOV AL,[DI+BX]
    MOV DX,B8255
    OUT DX,AL
    CALL DELAY
    CALL CLEAR 
    
    
    MOV DX,A8255
    MOV AL,11110111B
    OUT DX,AL
    LEA DI,SHUMA
    MOV AL,[DI+3]
    MOV AH,00H
    MOV BX,AX
    LEA DI,LIST
    MOV AL,[DI+BX]
    MOV DX,B8255
    OUT DX,AL
    CALL DELAY
    CALL CLEAR      
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET  
;==========================================================
CLEAR:
    PUSH  AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    MOV DX,A8255
    MOV AL,0FFH
    OUT DX,AL
    MOV DX,B8255
    MOV AL,00H
    OUT DX,AL
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
;=============================================================
DELAY:
    PUSH CX
    MOV CX,00FFH
D1:
    LOOP D1
    POP CX
    RET 


;=================================================================
LDELAY: 
    PUSH CX
    MOV  CX,0FFFFH
LD1:
    LOOP LD1 
    
    MOV  CX,0FFFFH
LD2:
    LOOP LD2
    
    MOV  CX,0FFFFH
LD3:
    LOOP LD4
        MOV  CX,0FFFFH
LD4:
    LOOP LD4
        MOV  CX,0FFFFH
LD5:
    LOOP LD5
        MOV  CX,0FFFFH
LD6:
    LOOP LD6
    POP CX
    RET
CODE ENDS
    END START