; 8080 assembler code
	.hexfile ShowPrimes.hex
	.binfile ShowPrimes.com
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

	; Position for stack pointer
	stack   equ 04000h

	org 000H
	jmp begin

	; Start of our Operating System
GTU_OS:	
	PUSH D
	push D
	push H
	push psw
	nop	; This is where we run our OS in C++, see the CPU8080::isSystemCall()
		; function for the detail.
	pop psw
	pop h
	pop D
	pop D
	ret
	; ---------------------------------------------------------------
	; YOU SHOULD NOT CHANGE ANYTHING ABOVE THIS LINE        

	;This program adds numbers from 0 to 10. The result is stored at variable
	; sum. The results is also printed on the screen.


number dw 1 //Starting number for printing numbers.
newLine: dw 00AH,00H ;null terminated newline string
primeText:	dw ' prime',00H ; null terminated string
;DIVIDE OPERATION from cookbook.
;Before divide operation:
;   BC -> Divident
;   DE -> Divider
;After divide operation:
;   C  -> Quatient
;   E  -> Remainder
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
		
;print newline using PRINT_STR syscall.
printnewLine:
	LXI B, newLine	    ; put the address of primeText in registers B and C
	MVI A, PRINT_STR	; store the OS call code to A
	call GTU_OS			; call the OS
	ret

;Print 16 bit decimal number to screen.
;This procedure can print only between 0-2600 numbers.
;I print the number in two part.
;    1516|_10_
;    -___| 151
;       6
;First print quatient and then print remainder.
printNumber:
	LXI D,10 ;LOAD D = 10 to divide number(BC) 10 -> number / 10
	
	CALL DIV
	;C -> BÖLÜM
	;E -> KALAN
	MOV A,C ;A=C to control whether C is ZERO.
	SUI 0	;A=A-0
	CNZ printNumber0 ;Print Quotient.First part of the number.
	
	MOV B,E     ;Second part of the number.
	MVI A,PRINT_B
	CALL GTU_OS
	RET

;Print first part of the number.
printNumber0:
	MOV B,C
	MVI A,PRINT_B
	CALL GTU_OS
	RET

;Print prime to screen.
print_prime:
	LXI B, primeText	; put the address of primeText in registers B and C
	MVI A, PRINT_STR	; store the OS call code to A
	call GTU_OS			; call the OS
	ret

;Control the current number. if number is 1, do not check whether number is prime.
;Else, go to prime loop and check the number.
isPrimeNumber:
    MOV H,B         ;H = B
    MOV L,C         ;L = C

    ;Control for 1
    MOV A,H
    SUI 0
    JNZ primeloop

    MOV A,L
    SUI 1
    RZ


;Main control procedure controls current number is prime.
;This procedure, divides current number by any less number starting from current number -1.
;After divide operation, if remainder is zero exit the loop and do not print anyting on the screen.
;Else decrease divider number and continue with divide operation.
;After all of that, if divider number is 1 exit the control loop and prime that number is prime.
primeloop:
    ;We will start divide op. from number-1. So, decrease HL.
    DCX H           ;HL = HL-1
    ;Control part
    MOV A,L         ;A = H
    SUI 1           ;A = A - 1 to control the loop.
    JNZ resume
    MOV A,H
    SUI 0
    CZ print_prime  ;exit and write number is prime.
    RZ              ;No need to continue the loop, return.

    resume:
    MOV D,H         ;D = H for divide op.
    MOV E,L         ;E = L for divide op.
    PUSH H
    PUSH B
        CALL DIV
        MOV A,E
        ADD D
        POP B
        POP H
        RZ          ;If remainder = 0, then number is not prime. RETURN.
    JNZ primeloop
    RET

;Main procedure.
begin:
	LXI SP,stack 	; always initialize the stack pointer
    LHLD number		;LOAD number from mem to H L register.
loop:

    MOV B,H			;B = H
    MOV C,L			;C = L


    PUSH B			;PUSH BC TO STACK to keep data
    PUSH H			;PUSH HL TO STACK to keep data
        CALL printNumber; print number to screen.
    POP H			;POP HL to restore data
    POP B			;POP BC	to restore data

    PUSH B			;PUSH BC TO STACK to keep data
    PUSH H			;PUSH HL TO STACK to keep data


    CALL isPrimeNumber; Call control procedure.

    CALL printnewLine   ;print new line.
    POP H			;POP HL to restore data
    POP B			;POP BC	to restore data


    MVI B,0
    MVI C,1
    DAD B			;HL = HL + BC, now HL = number + 1

    MOV B,H         ;B = H
    MOV C,L         ;C = L

    MOV A,B         ;A = B
    SUI 3           ;A = A - 3
    CZ mayExit      ;First part of the hex number is 03 if the part left is E9 then exit loop.
    JMP loop        ;if not continue the loop.


mayExit:
    MOV A,C         ;A = C
    SUI 233         ;A = A - 233
    JZ exit         ;If zero exit.
    RET             ;If not, return.



exit:
    MVI A,9
    CALL GTU_OS
