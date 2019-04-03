myss 		SEGMENT PARA STACK 'yigin'
			DW 40 DUP(?)
myss 		ENDS

myds			SEGMENT PARA 'veri'
dizi1			DB 0DH, 18H, 1FH,0FBH, 28H, 0BH, 01H, 34H, 14H, 0FFH
dizi2			DB 01H, 02H, 03H, 1BH, 0AH, 0AH,0FFH, 19H, 42H, 0FFH
dizi3 			DW 10 DUP(0)
n			DW 10
myds			ENDS

mycs			SEGMENT PARA 'kod'
			ASSUME CS:mycs, DS:myds, SS:myss
ANA 			PROC FAR
			PUSH DS
			XOR AX, AX
			PUSH AX
			MOV AX, myds
			MOV DS, AX
			
			XOR BX, BX
			MOV CX, n
			
L1:			XOR AX, AX
			MOV AL, [BX+0000]
			PUSH AX
			MOV AL, [BX+000Ah]
			PUSH AX
			CALL fonks
			SHL BX, 1
			POP [BX+0014]
			SHR BX, 1
			ADD BX, +01
			LOOP L1
			
			RETF
ANA			ENDP
FONKS		PROC NEAR
			PUSH BP
			PUSH BX
			PUSH DX
			MOV BP, SP
			MOV BX, [BP+08]
			MOV DX, [BP+0Ah]
			CMP BX, +01
			JNZ L2
			MOV [BP+0Ah], DX
			JMP L3
			NOP
L2:			TEST BX, 0001
			JZ L4
			SHR BX, 1
			PUSH BX
			MOV BX, DX
			SHL DX, 1
			PUSH DX
			CALL FONKS
			POP [BP+0Ah]
			ADD [BP+0Ah], BX
			JMP L3
			NOP
L4:			SHR BX,1
			SHL DX, 1
			PUSH DX
			PUSH BX
			CALL FONKS
			POP [BP+0Ah]
L3:			POP DX
			POP BX
			POP BP
			RET 2
FONKS		ENDP
mycs			ENDS
			END ANA
