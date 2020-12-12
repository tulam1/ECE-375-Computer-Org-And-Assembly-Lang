;***********************************************************
;*
;*	Data Manipulation (Tu_Lam_Lab4_SourceCode.asm)
;*
;*	Description: Learn how data manipulation work in the 
;*  Mega128 microcontroller board and use it to display
;*  characters on the LCD.
;*
;*
;***********************************************************
;*
;*	 Author: Tu Lam
;*	   Date: October 22, 2020
;*
;***********************************************************

.include "m128def.inc"								; Include definition file

;***********************************************************
;*	Internal Register Definitions and Constants
;***********************************************************
.def	mpr = r16									; Multipurpose register is
													; required for LCD Driver

;***********************************************************
;*	Start of Code Segment
;***********************************************************
.cseg												; Beginning of code segment

;***********************************************************
;*	Interrupt Vectors
;***********************************************************
.org	$0000										; Beginning of IVs
		rjmp INIT									; Reset interrupt

.org	$0046										; End of Interrupt Vectors

;***********************************************************
;*	Program Initialization
;***********************************************************
INIT:												; The initialization routine
		ldi		mpr, low(RAMEND)					; Initialize Stack Pointer
		out		SPL, mpr
		ldi		mpr, high(RAMEND)
		out		SPH, mpr
		
		ldi		mpr, (0<<0)|(0<<1)|(0<<7)			; Set PD0, PD1, PD7 as input
		out		DDRD, mpr							; Input is set
		ldi		mpr, (1<<0)|(1<<1)|(1<<7)			; Set up pull-up resistor for PORTD (5V)
		out		PORTD, mpr

		rcall	LCDInit								; Initialize LCD Display
		
													; Move strings from Program Memory to Data Memory
		ldi		r30, low(STRING1_BEG << 1)			; Initialize Z-pointer in .DB for string 1 by taking the address shift to the left
		ldi		r31, high(STRING1_BEG << 1)			; (multiply by 2) to get to the first index of the .DB
		ldi		r28, low(LCDLn1Addr)				; Initialize the character destination (Data Memory)
		ldi		r29, high(LCDLn1Addr)
		clr		r20									; Set r20 to 0
		ldi		r20, 6								; load r20 with a counter of 6 for 1st string

LOOP1:
		lpm		mpr, Z+								;Load the string into r16
		st		Y+,	mpr								;Store content into Y-register
		dec		r20									;Decrement the counter
		brne	LOOP1								;If zero flag is not equal to 0, keep looping


		ldi		r30, low(STRING2_BEG << 1)			; Initialize Z-pointer in .DB for string 2
		ldi		r31, high(STRING2_BEG << 1)
		ldi		r28, low(LCDLn2Addr)				;Initialize the character destination (Data Memory)
		ldi		r29, high(LCDLn2Addr)
		clr		r20									; Set r20 to 0
		ldi		r20, 12								; load r20 with a counter of 12 for 2nd string

LOOP2:
		lpm		mpr, Z+								;Load the string into r16
		st		Y+,	mpr								;Store content into Y-register
		dec		r20									;Decrement the counter
		brne	LOOP2								;If zero flag is not equal to 0, keep looping

		
		
		; NOTE that there is no RET or RJMP from INIT, this
		; is because the next instruction executed is the
		; first instruction of the main program

;***********************************************************
;*	Main Program
;***********************************************************
MAIN:												; The Main program
		rcall	LCDWrite
		in		mpr, PIND							; Get the input of PIND
		cpi		mpr, (1 << 0)						; Compare if the PD0 is press
		brne	ENTER1								; If not equal, jump to PD1
		rcall	LCDWrite							; Display the strings on the LCD Display
		rjmp	MAIN
		
ENTER1:
		cpi		mpr, (1 << 1)						; Compare to PD1
		brne	ENTER7
		rcall	LCDWrLn2
		rcall	LCDWrLn1
		rjmp	MAIN

ENTER7:	
		cpi		mpr, (1 << 7)						; Compare to PD7
		brne	MAIN
		rcall	LCDClr
		rjmp	MAIN								; jump back to main and create an infinite
													; while loop.  Generally, every main program is an
													; infinite while loop, never let the main program
													; just run off

;***********************************************************
;*	Functions and Subroutines
;***********************************************************

;-----------------------------------------------------------
; Func: Template function header
; Desc: Cut and paste this and fill in the info at the 
;		beginning of your functions
;-----------------------------------------------------------
FUNC:												; Begin a function with a label
													; Save variables by pushing them to the stack

													; Execute the function here
		
													; Restore variables by popping them from the stack,
													; in reverse order

		ret											; End a function with RET

;***********************************************************
;*	Stored Program Data
;***********************************************************

;-----------------------------------------------------------
; An example of storing a string. Note the labels before and
; after the .DB directive; these can help to access the data
;-----------------------------------------------------------
STRING1_BEG:
.DB		"Tu Lam"									; Declaring data in ProgMem
STRING2_BEG:
.DB		"Hello, World"								; Declare string no.2
STRING_END:

;***********************************************************
;*	Additional Program Includes
;***********************************************************
.include "LCDDriver.asm"							; Include the LCD Driver
