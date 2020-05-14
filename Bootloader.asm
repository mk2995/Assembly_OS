;Main ASM Bootloader file containing the Assembly code necessary
;to generate a simple 16 Operating System when compiled
;as an IMG file (Floppy).

;Author: Matthew Klein
 
[BITS 16]						;16-Bit Application
[ORG 0x7C00]					;Location to load OS into memory

start:
;Initial text
	MOV 	BL, 0x07			;color format - grey text, no backgground
	MOV 	SI, boot_load_str	;Place Bootloader pointer in SI
	CALL    PrintString			;Call Procedure for printing strings
	MOV		AH, 0x86			;Pause program before allowing user to control it
	MOV		CX, 60
	INT		0x15
	
	MOV		AH, 0x02			;Place cursor top left corner
	MOV		DL, 2
	MOV		DH, 2
	INT		0x10

;Blue border loop	
border:
	MOV		AH, 0x09			;Create border color
	MOV		CX, 76				;Border width
	MOV		AL, 0x20
	MOV		BL, 0x17			;Color of border (blue)
	INT		0x10
	MOV		AH, 0x02			;Move cursor one space down
	MOV		DL, 2
	INC		DH					
	INT		0x10
	CMP		DH, 23				;Check if bottom of border was reached (border height)
	JNE		border

;Draw? text
	MOV		AH, 0x02			;Place cursor in the center of the screen
	MOV		DL, 38
	MOV		DH, 12
	INT		0x10
	MOV 	BL, 0x07			;color format - grey text, no backgground
	MOV 	SI, draw			;Place Bootloader pointer in SI
	CALL    PrintString			;Call Procedure for printing strings
	
;Mouse control	
	MOV		AH, 0x01			;creates box cursor
	MOV		CX, 0x07
	INT		0x10
	
	MOV		BL, 0x02			;origin point 2,2
	MOV		CL, 0x02
	CALL	Mouse




;Print Single Character Procedure
;Preconditions: BL must be set to specify the color of the text and background
PrintCharacter:			
	MOV		AH, 0x0E			;print single character
	MOV 	BH, 0x00			;page number
	INT		0x10				;interupt
	RET							

;Procedure for printing multiple characters 
;using the PrintCharacter procedure to create strings
;Precondition: SI must be set to the addresss of the String being printed	
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
	
	MOV		AH, 0x00			;Wait on Keypress
	INT		0x16
	
	CMP		AL, 0x77			;Go up via a "W"
	JE		Up
	CMP		AL, 0x73			;Go Down via a "S"
	JE		Down
	CMP		AL, 0x61			;Go Left via a "A"
	JE		Left
	CMP		AL, 0x64			;Go Right via a "D"
	JE		Right
	JMP		Mouse

;Procedure to place cursor one level Up 	
Up:
	CMP		CL, 0x02			;Top Bound
	JE		Mouse
	SUB		CL, 0x01
	JMP		Mouse

;Procedure to place cursor one level Down	
Down:
	CMP		CL, 22				;Bottom Bound
	JE		Mouse
	ADD		CL, 0x01
	JMP		Mouse
;Procedure to place cursor one level Left	
Left:
	CMP		BL, 0x02			;Left Bound
	JE		Mouse
	SUB		BL, 0x01
	JMP		Mouse

;Procedure to place cursor one level Right	
Right:
	CMP		BL, 77				;Right Bound
	JE		Mouse
	ADD		BL, 0x01
	JMP		Mouse
	
;Data
boot_load_str	db	'Welcome to MattOS', 0
draw			db	'Draw?', 0

Times	510 - ($ - $$) db 0
DW		0xAA55