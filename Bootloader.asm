[BITS 16]						;16-Bit Application
[ORG 0x7C00]					;Location to load OS into memory

start:
	MOV 	SI, boot_load_str	;Place Bootloader pointer in SI
	CALL    PrintString			;Call Procedure for printing strings
	JMP     $					

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
	
;Data
boot_load_str	db	'Matts first OS', 0

Times	510 - ($ - $$) db 0
DW		0xAA55