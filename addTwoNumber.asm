stackseg SEGMENT PARA STACK 'STACK'
			DW 20 DUP(?)
stackseg ENDS
dataseg SEGMENT PARA 'DATA'
			SAYI1 DW 12
			SAYI2 DW 12 
			TOPLAM DW ?
dataseg ENDS
codeseg SEGMENT PARA 'CODE'
			ASSUME CS: codeseg, DS: dataseg, SS: stackseg
			MAIN PROC FAR	
			PUSH DS
			XOR AX, AX
			PUSH AX
			MOV AX, dataseg
			MOV DS, AX
	
			MOV AX, SAYI1
			ADD AX, SAYI2
			MOV TOPLAM, AX
	
			RETF
MAIN ENDP
codeseg 	ENDS
			END MAIN