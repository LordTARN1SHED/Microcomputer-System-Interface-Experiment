;中断
CODE SEGMENT
    ASSUME CS:CODE
START: 
MOV AX, 0000H
    MOV DS, AX
 
    MOV DX, 0686H
    MOV AL, 90H
    OUT DX, AL
 
    MOV AX, OFFSET MIR6 ;ADC0809的EOC引脚连接MIR6
    MOV SI, 0038H
    MOV [SI], AX
    MOV AX,CS
    MOV SI,003AH
    MOV [SI], AX
 
    CLI
    MOV AL, 11H
    OUT 20H, AL
    MOV AL, 08H
    OUT 21H, AL
    MOV AL,04H
    OUT 21H, AL
    MOV AL, 05H
    OUT 21H, AL
    MOV AL, 10101111B
    OUT 21H, AL
    STI
 
AA1: 
    CLI            ;关闭中断
    MOV DX, 0640H  ;启动AD采样
    OUT DX, AL
    CALL DELAY     ;延时一小段时间之后开中断，保证每一次AD转换中断只响应一次
    STI
    JMP AA1
MIR6:
    STI
    MOV DX,0640H   ;读入AD转换之后的值
    IN AL,DX
    MOV DX, 0682H  ;从8255B口输出
    OUT DX, AL
    MOV AL, 20H
    OUT 20H, AL
    IRET
DELAY:
    PUSH CX
    PUSH AX
    MOV CX,0FFFH
L1:
    LOOP L1
    POP AX
    POP CX
    RET
 
CODE ENDS
    END START