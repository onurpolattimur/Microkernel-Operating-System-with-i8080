	; 8080 assembler code
	.hexfile MicroKernel.hex
	.binfile MicroKernel.com
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
	LOAD_EXEC   equ 5
	PROCESS_EXIT	equ 9
	SET_QUANTUM	equ 6

	; Position for stack pointer
	stack   equ 4000h

org 0028H
handleInterrupt:
	DI
	jmp readFromInterruptBuffer
		
org 0000H
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

org 0D00H	


sum	ds 1 ; will keep the sum
sumName: dw 'Sum.com', 00H
runningProcess ds 2 ; will keep the running process
collatzName: dw 'Collatz.com', 00H
primeName: dw 'Primes.com', 00H
initName: dw 'init', 00H
processStates: dw 'PID -- Process Name -- PC.LOW -- PC.HIGH --  BASE.LOW -- BASE.HI', 00AH, 00H
line: dw ' -- ', 00H 
nl: dw 00AH,00H
printNL:
	LXI B,nl
	MVI A,PRINT_STR
	CALL GTU_OS
	RET 
begin:
	DI
	LXI SP, stack 	; always initialize the stack pointer

	MVI A, 0
	STA runningProcess
	STA sum	
	
	;Set next
	MVI A, 1
	LXI H, 0202H ;Next pointer of first process
	MOV M, A
	
	;Set base
	LXI H,020Eh
	MVI M,0
	INX H 
	MVI M,0

	;Set stack
    LXI H,020Ah
    MVI M,00H
    INX H
    MVI M,40H

	;Set ProcessName
	LXI H, 0211H
	LXI B, initName 
	MOV M, B
	INX H 
	MOV M, C 


	;Load first program
	LXI B, sumName  
	MVI H, 040H
	MVI L, 000H
	MVI A, LOAD_EXEC
	CALL GTU_OS
	
	;Set next
	MVI A, 2
	LXI H, 0302H ;Next pointer of first process
	MOV M, A
	
	;Set base
	LXI H, 030Eh
	MVI M, 000H
	INX H
	MVI M, 040H

	;Set stack
    LXI H,030Ah
    MVI M,00H
    INX H
    MVI M,40H

	;Set ProcessName
	LXI H, 0311H
	LXI B, sumName 
	MOV M, B
	INX H 
	MOV M, C 

	;Load second program
	LXI B, collatzName  
	MVI H, 080H
	MVI L, 000H
	MVI A, LOAD_EXEC
	CALL GTU_OS
	
	;Set next
	MVI A, 3
	LXI H, 402H ;Next pointer of second process
	MOV M, A
	
	;Set base
	LXI H, 040EH
	MVI M, 000H
	INX H
	MVI M, 080H

	;Set stack
    LXI H,040Ah
    MVI M,00H
    INX H
    MVI M,40H

	;Set ProcessName
	LXI H, 0411H
	LXI B, collatzName 
	MOV M, B
	INX H 
	MOV M, C 

	;Load third program
	LXI B, primeName  
	MVI H, 0C0H
	MVI L, 000H
	MVI A, LOAD_EXEC
	CALL GTU_OS
	
	;Set next
	MVI A, 0
	LXI H, 0502H ;Next pointer of third process
	MOV M, A
	
	;Set base
	LXI H, 050Eh
	MVI M, 000H
	INX H
	MVI M, 0C0H

	;Set stack
    LXI H,050Ah
    MVI M,00H
    INX H
    MVI M,40H

	;Set ProcessName
	LXI H, 0511H
	LXI B, primeName 
	MOV M, B
	INX H 
	MOV M, C 

	EI

	LOOP:
	LDA sum
	SUI 1
	JNZ LOOP
	hlt
	
readFromInterruptBuffer:
	LDA runningProcess ; A = runningProcess
	PUSH PSW 
	
	MOV B, A	; B holds running process too
	MVI C, 0 	; C=0
	ADI 2 ; A=A+2
	MOV H, A ; H=A
	MVI L, 0 ; L=0 | HL now holds the pointer
	
	;ProcessState
	MVI M, 0 ; set process to ready | 1=running, 0=ready
	
	;ProcessNumber
	INX H
	MOV M, B 
	
	;Next
	INX H
	MOV A, M ; next process id is now in A
	MOV B, A ; B holds process id too, which will be used later
	
	
	; Start getting entries from interrupt buffer
	LXI D, 256 ; DE -> 256
	
	;Register A
	INX H
	LDAX D ; get Register A from interrupt buffer
	MOV M, A
	
	;Register B
	INX D 	;257
	INX H
	LDAX D
	MOV M, A
	
	;Register C
	INX D	;258
	INX H
	LDAX D
	MOV M, A
	
	;Register D
	INX D	;259
	INX H
	LDAX D
	MOV M, A
	
	;Register E
	INX D	;260
	INX H
	LDAX D
	MOV M, A
	
	;Register H
	INX D	;261
	INX H
	LDAX D
	MOV M, A
	
	;Register L
	INX D	;262
	INX H
	LDAX D
	MOV M, A
	
	;SP.LOW
	INX D	;263
	INX H
	LDAX D
	MOV M, A
	
	;SP.HI
	INX D	;264
	INX H
	LDAX D
	MOV M, A
	
	;PC.LOW
	INX D	;265
	INX H
	LDAX D
	MOV M, A
	
	;PC.HI
	INX D	;266
	INX H
	LDAX D
	MOV M, A
	
	;BASEREG.LOW
	INX D	;267
	INX H
	LDAX D
	MOV M, A
	
	;BASEREG.HI
	INX D	;268
	INX H
	LDAX D
	MOV M, A
	
	;CONDITION
	INX D	;269
	INX H
	LDAX D
	MOV M, A


	;------------------------------------------------------------
	;Print process states
	;POP PSW ;A=CurrentProcess
	;PUSH B
	;PUSH PSW

	;LXI B, processStates
	;MVI A, PRINT_STR
	;CALL GTU_OS
	;POP PSW

	;PROCESS ID
	;PUSH PSW
	;MOV B, A
	;MVI A, PRINT_B
	;CALL GTU_OS

	;LXI B, line
	;MVI A, PRINT_STR
	;CALL GTU_OS
	;POP PSW

	;PROCESS NAME
	;ADI 2
	;MOV H, A
	;MVI L, 11h
	;MOV B, M
	;INX H
	;MOV C, M
	;MVI A, PRINT_STR
	;CALL GTU_OS

	;LXI B, line
	;MVI A, PRINT_STR
	;CALL GTU_OS

	;PC.LOW
	;LXI D, 265	;265
	;LDAX D
	;MOV B, A
	;MVI A, PRINT_B
	;CALL GTU_OS

	;LXI B, line
	;MVI A, PRINT_STR
	;CALL GTU_OS

	;PC.HI
	;INX D	;266
	;LDAX D
	;MOV B, A
	;MVI A, PRINT_B
	;CALL GTU_OS

	;LXI B, line
	;MVI A, PRINT_STR
	;CALL GTU_OS

	;BASE.LOW
	;INX D 	;267
	;LDAX D
	;MOV B, A
	;MVI A, PRINT_B
	;CALL GTU_OS

	;LXI B, line
	;MVI A, PRINT_STR
	;CALL GTU_OS

	;BASE.HI
	;INX D	;268
	;LDAX D
	;MOV B, A
	;MVI A, PRINT_B
	;CALL GTU_OS


	;CALL printNL

	;POP B
	;------------------------------------------------------------
	; Load process from process table according to next process id in B
	MOV A, B 
	ADI 2	
	MOV H, A 
	MVI L, 0AH	; Now HL points to SP.LOW
	MOV D, H ; D now holds backup of H, in order to be used after the sp is changed
	
	MOV A, B 	; A hold next process id
	STA runningProcess
	
	;B=SP.LOW
	MOV B, M

	;C=SP.HI
	INX H 
	MOV C, M
	
	;H=C, L=B
	MOV H, C
	MOV L, B
	
	SPHL
	
	;------------------------------------------------------------------
	;A = process id 
	
	MOV H, D
	MVI L, 0 ;HL holds pointer to process table.
		
	;ProcessState
	MVI M, 1	
	
	;ProcesNumber
	INX H
	MOV M, A
	
	;Next
	INX H
	
	;Register D
	INX H
	INX H
	INX H
	INX H
	MOV D, M
	
	;REGISTER E
	INX H
	MOV E, M
	
	PUSH D ; Keep DE in the bottom of stack
	
	;REGISTER H 
	INX H 
	MOV B, M ; B=H from memory 
	
	;REGISTER L
	INX H 
	MOV C, M ; C=L from memory 
	
	PUSH B ; Keep HL in stack
	
	
	;Go back to the address of register A
	
	;REGISTER A
	ADI 2
	MOV H, A
	MVI L, 03H
	
	MOV B,M
	
	;CONDITION
	MVI L, 10H
	MOV C,M
	
	PUSH B
	
	;PC.HI
	MVI L, 0DH
	MOV B, M
	
	;PC.LOW
	MVI L, 0CH
	MOV C, M
	
	PUSH B
	
	;BASEREG.HI
	MVI L, 0FH
	MOV B, M
	
	;BASEREG.LOW
	MVI L, 0EH
	MOV C, M
	
	PUSH B
	
	;REGISTER B
	MVI L, 04H
	MOV B, M
	
	;REGISTER C
	MVI L, 05H
	MOV C, M
	
	POP D
	POP H
	POP PSW
	EI
	PCHL
