;Main ASM Bootloader file containing the Assembly code necessary
;to generate a simple 16 Operating System when compiled
;as an IMG file (Floppy).

;Author: Matthew Klein
 
[BITS 16]						;16-Bit Application
[ORG 0x7C00]					;Location to load OS into memory

start:
;Initial Text
	MOV 	SI, boot_load_str	;Place Bootloader pointer in SI
	CALL    PrintString			;Call Procedure for printing strings
	
;Mouse control	
	MOV		AH, 0x01			;creates box cursor
	MOV		CX, 0x07
	INT		0x10
	
	MOV		BL, 0x00			;origin point 0,0
	MOV		CL, 0x00
	CALL	Mouse




;Print Single Character Procedure
PrintCharacter:			
	MOV		AH, 0x0E			;print single character
	MOV 	BH, 0x00			;page number
	MOV 	BL, 0x07			;color format - grey text, black backgground
	
	INT		0x10				;interupt
	RET							

;Procedure for printing multiple characters 
;using the PrintCharacter procedure to create strings	
PrintString:
next_character:
	MOV 	AL, [SI]			;Store String Byte into AL
	INC		SI					;Incriment the pointer
	OR  	AL, AL				;Check if AL = 0
	JZ		exit_function		;branch if zero = true
	CALL 	PrintCharacter		;otherwise print a new character
	CALL	next_character
	exit_function:
	RET
	
;Procedure for mnipulating the cursor within the OS
;Preconditions: BL and CL are set to 0 for origin point	
Mouse:
	MOV		AH, 0x02			;Place cursor at origin point
	MOV		DL, BL
	MOV		DH, CL
	INT		0x10
	
	MOV		AH, 0x00			;Create Keypress
	INT		0x16
	
	CMP		AL, 0x73			;Go up via a "W"
	JE		Up
	CMP		AL, 0x77			;Go Down via a "S"
	JE		Down
	CMP		AL, 0x61			;Go Left via a "A"
	JE		Left
	CMP		AL, 0x64			;Go Right via a "D"
	JE		Right
	JMP		Mouse

;Procedure to place cursor one level Up 	
Up:
	ADD		CL, 0x01
	JMP		Mouse

;Procedure to place cursor one level Down	
Down:
	SUB		CL, 0x01
	JMP		Mouse
;Procedure to place cursor one level Left	
Left:
	SUB		BL, 0x01
	JMP		Mouse

;Procedure to place cursor one level Right	
Right:
	ADD		BL, 0x01
	JMP		Mouse
	
;Data
boot_load_str	db	'Matts first OS', 0

Times	510 - ($ - $$) db 0
DW		0xAA55
