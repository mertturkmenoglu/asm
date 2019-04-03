myss		SEGMENT PARA STACK 'my_stack'
			DW 20 DUP(?)
myss		ENDS

myds		SEGMENT PARA 'my_data'
tek_top		DD 0
cift_top	DD 0
tek_say		DW 0
cift_say	DW 0
tek_ort		DW 0
cift_ort	DW 0
dizi		DW 300 DUP(?)
n			DW 300
myds		ENDS

mycs		SEGMENT PARA 'my_code'
			ASSUME CS:mycs, SS:myss, DS:myds
MAIN		PROC FAR
			PUSH DS
			XOR AX, AX
			PUSH AX
			MOV AX, myds
			MOV DS, AX
			MOV CX, N
			LEA SI, dizi
don:		MOV AX, [SI]
			TEST AX, 0001H
			JZ c_label
			INC tek_say
			ADD WORD PTR [tek_top], AX
			ADC WORD PTR [tek_top+2], 0
			JMP artir
c_label:	INC cift_say
			ADD WORD PTR [cift_top], AX
			ADC WORD PTR [cift_top+2], 0
artir:		ADD SI, 2
			LOOP don
			MOV DX, WORD PTR [cift_top+2]
			MOV AX, WORD PTR [cift_top]
			DIV cift_say
			MOV cift_ort, AX
			MOV DX, WORD PTR [tek_top+2]
			MOV AX, WORD PTR [tek_top]
			DIV tek_say
			MOV tek_ort, AX
			RETF
MAIN 		ENDP
mycs		ENDS
		END MAIN
