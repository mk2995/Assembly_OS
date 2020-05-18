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

;Create Blue Border
	MOV		BL, 0x17			;Color of border (blue)
	CALL 	Border

;Draw text
	MOV		AH, 0x02			;Place cursor in the center of the screen
	MOV		DL, 31
	MOV		DH, 12
	INT		0x10
	MOV 	BL, 0x07			;color format - grey text, no backgground
	MOV 	SI, draw			;Place Bootloader pointer in SI
	CALL    PrintString			;Call Procedure for printing strings
	
;Wait on Space Key Press
space_pressed:
	MOV		AH, 0x00			;Wait on Keypress
	INT		0x16
	CMP		AL, 32				;Change Screen via a "SPACE" key press
	JNE		space_pressed
	
;Create Drawing Board
	MOV		AH, 0x02			;Place cursor top left corner
	MOV		DL, 0
	MOV		DH, 0
	INT		0x10
	MOV 	BL, 0x07			;color format - grey text, no backgground
	MOV 	SI, help			;Place Bootloader pointer in SI
	CALL    PrintString			;Call Procedure for printing strings
	MOV		AH, 0x02			;Place cursor on next line
	MOV		DL, 0
	MOV		DH, 1
	INT		0x10
	MOV 	BL, 0x07			;color format - grey text, no backgground
	MOV 	SI, clear			;Place Bootloader pointer in SI
	CALL    PrintString			;Call Procedure for printing strings
	
new_board:	
	MOV		BL, 0x70			;Color of border (white)
	CALL 	Border
	
;Mouse control	
	MOV		AH, 0x01			;creates box cursor
	MOV		CX, 0x07
	INT		0x10
	
	MOV		BL, 0x02			;origin point 2,2
	MOV		CL, 0x02
	CALL	Mouse


;Subroutines


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

;Procedure for creating a borded screen with a specified color
;Precondition: BL must be set to the Hexcode commandline screen color desired
Border:
	MOV		AH, 0x02			;Place cursor top left corner
	MOV		DL, 2
	MOV		DH, 2
	INT		0x10
next_panel:
	MOV		AH, 0x09			;Create border color
	MOV		CX, 76				;Border width
	MOV		AL, 0x20
	INT		0x10
	MOV		AH, 0x02			;Move cursor one space down
	MOV		DL, 2
	INC		DH					
	INT		0x10
	CMP		DH, 23				;Check if bottom of border was reached (border height)
	JNE		next_panel
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
	
	CMP		AL, 0x72			;Print Red via a "R"
	JE		Red
	CMP		AL, 0x62			;Print Blue via a "B"
	JE		Blue
	CMP		AL, 0x67			;Print Green via a "G"
	JE		Green
	CMP		AL, 0x77			;Go up via a "W"
	JE		Up
	CMP		AL, 0x73			;Go Down via a "S"
	JE		Down
	CMP		AL, 0x61			;Go Left via a "A"
	JE		Left
	CMP		AL, 0x64			;Go Right via a "D"
	JE		Right
	CMP		AL, 32				;Clear board via "SPACE"
	JE		new_board
	JMP		Mouse

;Procedure to Print Red Character 	
Red:
	PUSH	BX					;Stores the current position values to the stack
	PUSH	CX
	MOV 	BL, 0x74			;color format - red text, white background
	MOV		AH, 0x09			;Create border color
	MOV		CX, 1				;Border width
	MOV		AL, 0x20
	INT		0x10
	MOV		AL, 0x2E			;Place Red "."
	CALL	PrintCharacter
	POP		CX					;Loads the current position values from the stack
	POP		BX
	JMP		Mouse
	
;Procedure to Print Blue Character 	
Blue:
	PUSH	BX					;Stores the current position values to the stack
	PUSH	CX
	MOV 	BL, 0x71			;color format - blue text, white background
	MOV		AH, 0x09			;Create border color
	MOV		CX, 1				;Border width
	MOV		AL, 0x20
	INT		0x10
	MOV		AL, 0x2E			;Place Blue "."
	CALL	PrintCharacter
	POP		CX					;Loads the current position values from the stack
	POP		BX
	JMP		Mouse
	
;Procedure to Print Green Character 	
Green:
	PUSH	BX					;Stores the current position values to the stack
	PUSH	CX
	MOV 	BL, 0x72			;color format - green text, white background
	MOV		AH, 0x09			;Create border color
	MOV		CX, 1				;Border width
	MOV		AL, 0x20
	INT		0x10
	MOV		AL, 0x2E			;Place Green "."
	CALL	PrintCharacter
	POP		CX					;Loads the current position values from the stack
	POP		BX
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
draw			db	'Press SPACE to Draw', 0
help			db	'Move with W, A, S, and D | Paint by Pressing R, B, or G', 0
clear			db	'Press SPACE to Clear Board', 0

Times	510 - ($ - $$) db 0
DW		0xAA55