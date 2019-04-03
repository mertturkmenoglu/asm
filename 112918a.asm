; sayinin ustunu alir

stackseg		SEGMENT PARA STACK 'stack'
				DW 20 DUP(?)
stackseg		ENDS
dataseg			SEGMENT PARA 'data'
sayi			DW 2
ust				DW 10
sonuc			DW ?
dataseg 		ENDS
codeseg			SEGMENT PARA 'code'
				ASSUME CS:codeseg, DS:dataseg, SS:stackseg
MAIN			PROC FAR
				
				PUSH DS
				XOR AX, AX
				PUSH AX
				
				MOV AX, dataseg
				MOV DS, AX
				
				MOV CX, ust
				MOV BX, sayi
				CALL USTAL
				MOV sonuc, AX
				RETF
MAIN			ENDP
USTAL			PROC NEAR
				MOV  AX, 1
L1:				MUL BX
				LOOP L1
				RET
USTAL			ENDP
codeseg			ENDS
				END MAIN
