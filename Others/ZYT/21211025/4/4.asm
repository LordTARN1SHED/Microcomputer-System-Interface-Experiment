CODE SEGMENT
    ASSUME CS:CODE
START: 
    ; 8255初始化
    MOV DX, 0686H  ;8255控制端口地址，选取的IOY2端口，控制口地址是 0686H
    MOV AL, 90H    ;8255控制字，90H=10010000B，表示A口输入，B口输出
    OUT DX, AL     ;将上述控制字写入控制端口
MI:
    MOV AL,00H   ; 设置 0 通道
    MOV DX, 0640H   ;启动A/D采样 IOY1用作ADC0809，IOY1的地址是 0640H
    OUT DX, AL
 
    CALL DELAY
    IN AL, DX      ;读A/D采样结果
 
    MOV DX, 0682H ;8255 B 口地址为 0682H，连接 IOY2
    OUT DX,AL   ;采样结果送 B 口 
    JMP MI
    
DELAY:             ;延时程序
    PUSH CX        ;保护现场
    MOV CX,0FFFFH;

L1: PUSH AX
    POP AX
    LOOP L1
    POP CX 
    RET
    
CODE ENDS 
    END START