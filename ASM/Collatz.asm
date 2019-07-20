; 8080 assembler code
	.hexfile Collatz.hex
	.binfile Collatz.com
	; try "hex" for downloading in hex format
	.download bin  
	.objcopy gobjcopy
	.postbuild echo "OK!"
	;.nodump

	; OS call list
	PRINT_B		equ 4
	PRINT_MEM	equ 3
	READ_B		equ 7
	READ_MEM	equ 2
	PRINT_STR	equ 1
	READ_STR	equ 8
	PROCESS_EXIT	equ 9
	SET_QUANTUM	equ 6

	; Position for stack pointer
	stack   equ 04000h

	org 000H
	jmp begin

	; Start of our Operating System
GTU_OS:	PUSH D
	push D
	push H
	push psw
	nop	; This is where we run our OS in C++, see the CPU8080::isSystemCall()
		; function for the detail.
	pop psw
	pop h
	pop d
	pop D
	ret
	; ---------------------------------------------------------------
	; YOU SHOULD NOT CHANGE ANYTHING ABOVE THIS LINE        

	;This program adds numbers from 0 to 10. The result is stored at variable
	; sum. The results is also printed on the screen.



MULT:   MVI B,0
        MVI E,9
MULT0:  MOV A,C
        RAR 
        MOV C,A 
        DCR E 
        JZ DONE 
        MOV A,B 
        JNC MULT1 
        ADD D 
MULT1:  RAR 
        MOV B,A 
        JMP MULT0 
DONE: RET


; DIVISION PROCEDURE TAKEN FROM THE 8080BOOK GIVEN IN THE FILES OF HOMEWORK
DIV:	MOV A,D 	; NEGATE THE DIVISOR
		CMA
		MOV	D,A
		MOV A,E
		CMA
		MOV E,A
		INX D		;FOR TWO'S COMPLEMENT
		LXI H,0
		MVI	A,17	;INITIALIZE LOOP COUNTER

DV0:	PUSH H		;SAVE REMAINDER
		DAD D		;SUBTRACT DIVISOR (ADD NEGATIVE)
		JNC DV1		;UNDER FLOW, RESTORE HL
		XTHL
DV1:	POP H
		PUSH PSW	;SAVE LOOP COUNTER (A)
		MOV A,C		;4 REGISTER LEFT SHIFT
		RAL			;WITH CARRY
		MOV C,A		;CY->C->B->L->H
		MOV A,B
		RAL
		MOV B,A
		MOV A,L
		RAL
		MOV L,A
		MOV A,H
		RAL
		MOV H,A
		POP PSW		;RESTORE LOOP COUNTER (A)
		DCR A		;DECREMENT IT
		JNZ DV0		;KEEP LOOPING
		
;-----------
		ORA A
		MOV A,H
		RAR
		MOV D,A
		MOV A,L
		RAR
		MOV E,A
		RET
		END


sum	ds 2 ; will keep the sum
indent:dw  ' ', 00H  
semicolon: dw ': ', 00H 
newline: dw '', 00AH, 00H

begin:
	LXI SP,stack 	; always initialize the stack pointer
    MVI A,1	

outterLoop:
	
	MOV L, A ; Keep original value of A
	SUI 26	 ; A=A-25
	JZ exit  ; Exit if the number is more than 25
	MOV A, L ; Restore orignal value of A
	CALL printInitialNumber
	PUSH H 
	CALL loop
	POP H 

	MOV A, L  ; Restore A
	INR A 	  ; Increase A to continue looping 
	JMP outterLoop	; Continue looping 


loop:
    CALL printNumbers
    MOV H, A 
    SUI 1
    ;CZ setValue
	CZ printNewLine
	RZ 
    MOV A, H 
    
    ; DIVIDE BY 2 
    MVI B, 0 
    MOV C, A
    MVI D, 0
    MVI E, 2
   
    PUSH H 
    CALL DIV 
    POP H 

    MOV A, E 
    CPI 0 

    PUSH PSW 
    CZ getHalf
    POP PSW 
	
    CNZ multWith3
	MOV A, H 
    jmp loop 
	RET 

getHalf:
    MOV A, H 
    MVI B, 0
    MOV C, A
    MVI D, 0 
    MVI E, 2
	PUSH H 
    CALL DIV 
	POP H 
    MOV A, C ; A is now half of original number.
	MOV H, A 
    RET 

printNumbers:
    PUSH B
    PUSH PSW
    MOV B, A
    MVI A, PRINT_B 
    CALL GTU_OS
	LXI B, indent
	MVI A, PRINT_STR
	CALL GTU_OS
    POP PSW 
    POP B 
    RET

multWith3:
    MOV A, H 
    MOV D, A 
    MVI C, 3
	PUSH H 
    CALL MULT 
	POP H 
    MOV A, C 
    ADI 1 
	MOV H, A 
    ; NOV A IS N*3+1
    RET 

setValue:
	MOV A, H
	JMP outterLoop

printInitialNumber: 
	PUSH B
	PUSH PSW
	MOV B, A 
	MVI A, PRINT_B
	CALL GTU_OS
	LXI B, semicolon
	MVI A, PRINT_STR
	CALL GTU_OS
	POP psw
	POP B
	RET 

printNewLine:
	PUSH B
	PUSH PSW 
	LXI B, newline
	MVI A, PRINT_STR
	CALL GTU_OS
	POP PSW
	POP B 
	RET 	
exit:
    MVI A,9
    CALL GTU_OS
