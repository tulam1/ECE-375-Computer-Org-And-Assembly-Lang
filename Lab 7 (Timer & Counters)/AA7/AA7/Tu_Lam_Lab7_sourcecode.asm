;***********************************************************
;*
;*	Tu_Lam_Lab7_sourcecode.asm
;*
;*	Description: This file include moving the BumpBot but also
;*				 display the the speed changes in the BumpBot.
;*				 Also, you will learn how to use the Timer.
;*
;***********************************************************
;*
;*	 Author: Tu Lam
;*	   Date: November 14th, 2020
;*
;***********************************************************

.include "m128def.inc"			; Include definition file

;***********************************************************
;*	Internal Register Definitions and Constants
;***********************************************************
.def	mpr = r16				; Multipurpose register
.def	waitcnt = r17			; A wait counter from R17-R19
.def    olcnt = r18
.def    ilcnt = r19
.def	temp = r20				; Temporary register to use
.def	led = r21				; LED display

.equ	EngEnR = 4				; right Engine Enable Bit
.equ	EngEnL = 7				; left Engine Enable Bit
.equ	EngDirR = 5				; right Engine Direction Bit
.equ	EngDirL = 6				; left Engine Direction Bit
.equ	Speed = 17				; Speed of counter increment

;***********************************************************
;*	Start of Code Segment
;***********************************************************
.cseg							; beginning of code segment

;***********************************************************
;*	Interrupt Vectors
;***********************************************************
.org	$0000
		rjmp	INIT					; reset interrupt

		; place instructions in interrupt vectors here, if needed
.org	$0002
		rcall	SPEED_UP				; Call SPEED_UP interrupt
		reti							; Return from interrupt

.org	$0004
		rcall	SPEED_DOWN				; Call SPEED_DOWN interrupt
		reti							; Return from interrupt

.org	$0006
		rcall	SPEED_MAX				; Call SPEED_MAX interrupt
		reti							; Return from interrupt

.org	$0008
		rcall	SPEED_MIN				; Call SPEED_MIN interrupt
		reti							; Return from interrupt

.org	$0046							; end of interrupt vectors

;***********************************************************
;*	Program Initialization
;***********************************************************
INIT:
		ldi		mpr, low(RAMEND)		; Initialize Stack Pointer
		out		SPL, mpr
		ldi		mpr, high(RAMEND)
		out		SPH, mpr

		ldi		mpr, 0b11111111			; Configure I/O ports
		out		DDRB, mpr				; Initialize output for PORT B
		ldi		mpr, 0b11110000			; Initialize input for PORT D
		out		DDRD, mpr

		; Configure External Interrupts, if needed
		ldi		mpr, 0b10101010			; Set the Interrupt Sense Control to falling edge 
		sts		EICRA, mpr
		ldi		mpr, 0b00001111			; Configure the External Interrupt Mask
		out		EIMSK, mpr
		
		; Configure 8-bit Timer/Counters
		ldi		mpr, 0b01111001			; Setting up the Fast PWM mode
		out		TCCR0, mpr				; No prescaling (And inverting)
		out		TCCR2, mpr
		

		; Set TekBot to Move Forward (1<<EngDirR|1<<EngDirL)
		ldi		led, (1<<EngDirR)|(1<<EngDirL)
		out		PORTB, led

		; Set initial speed, display on Port B pins 3:0
		ldi		mpr, 0b00000000			; Initialize to be 0 at first
		out		OCR0, mpr
		out		OCR2, mpr

		; Enable global interrupts (if any are used)
		sei

;***********************************************************
;*	Main Program
;***********************************************************
MAIN:
		rjmp	MAIN					; return to top of MAIN

;***********************************************************
;*	Functions and Subroutines
;***********************************************************

;-----------------------------------------------------------
; Func: SPEED_UP
; Desc: This subroutine will increment the speed by 1 of the
;		timer/counter.
;-----------------------------------------------------------
SPEED_UP:

		ldi		waitcnt, 30				; Account for wait if button bounce
		rcall	WAITING					; Wait for 30ms

		in		temp, OCR0				; Get the speed level
		cpi		temp, 255				; Compare if the speed is at MAX
		breq	CHECK_DONE				; If so, move to the label CHECK_DONE
		ldi		mpr, Speed				; Load value 17 into mpr
		add		temp, mpr				; If not, increment the speed by 17
		out		OCR0, temp				; Write out the value to OCR0 & OCR2
		out		OCR2, temp
		inc		led						; Increment the display to display the next speed
		out		PORTB, led				; Send it to PORTB as output

CHECK_DONE:
		ldi		mpr, 0b00001111			; Clear any queue interrupt
		out		EIFR, mpr				; Store clear values into EIFR
		ret								; Return the subroutine


;-----------------------------------------------------------
; Func: SPEED_DOWN
; Desc: This subroutine will decrement the speed by 1 of the
;		timer/counter.
;-----------------------------------------------------------
SPEED_DOWN:

		ldi		waitcnt, 30				; Account for wait if button bounce
		rcall	WAITING					; Wait for 30ms

		in		temp, OCR0				; Get the speed level
		cpi		temp, 0					; Compare if the speed is at MIN
		breq	CHECK_DONE1				; If so, move to the label CHECK_DONE1
		ldi		mpr, Speed				; Load value 17 into mpr
		sub		temp, mpr				; If not, decrement the speed by 17
		out		OCR0, temp				; Write out the value to OCR0 & OCR2
		out		OCR2, temp
		dec		led						; Decrement the display to display the next speed
		out		PORTB, led				; Send it to PORTB as output

CHECK_DONE1:
		ldi		mpr, 0b00001111			; Clear any queue interrupt
		out		EIFR, mpr				; Store clear values into EIFR
		ret								; Return the subroutine


;-----------------------------------------------------------
; Func: SPEED_MAX
; Desc: This subroutine will increment toward the MAX speed in
;		timer/counter.
;-----------------------------------------------------------
SPEED_MAX:

		ldi		waitcnt, 30				; Account for wait if button bounce
		rcall	WAITING					; Wait for 30ms

		in		temp, OCR0				; Get the speed level
		cpi		temp, 255				; Compare if the speed is at MAX
		ldi		mpr, 255				; Load into mpr with 255
		add		temp, mpr				; Add them together
		out		OCR0, temp				; Write out the value to OCR0 & OCR2
		out		OCR2, temp
		ldi		led, 0b01101111			; Display out the full speed 
		out		PORTB, led				; Send it to PORTB as output

		ldi		mpr, 0b00001111			; Clear any queue interrupt
		out		EIFR, mpr				; Store clear values into EIFR
		ret								; Return the subroutine


;-----------------------------------------------------------
; Func: SPEED_MIN
; Desc: This subroutine will decrement toward the MIN speed in
;		timer/counter.
;-----------------------------------------------------------
SPEED_MIN:

		ldi		waitcnt, 30				; Account for wait if button bounce
		rcall	WAITING					; Wait for 30ms

		in		temp, OCR0				; Get the speed level
		cpi		temp, 0					; Compare if the speed is at MIN
		ldi		mpr, 255				; Load into mpr with 255
		sub		temp, mpr				; Subtract them together
		out		OCR0, temp				; Write out the value to OCR0 & OCR2
		out		OCR2, temp
		ldi		led, 0b11110000			; Display out the full speed 
		out		PORTB, led				; Send it to PORTB as output

		ldi		mpr, 0b00001111			; Clear any queue interrupt
		out		EIFR, mpr				; Store clear values into EIFR
		ret								; Return the subroutine

;-----------------------------------------------------------
; Func: WAITING
; Desc: This function help the BumpBot to wait going through
;		a loop of 16 + 159975*waitcnt cycles.
;-----------------------------------------------------------
WAITING:
		push	waitcnt					; Push registers on the stack
		
OLOOP:
		ldi		olcnt, 224				; Load middle-loop with 224

MLOOP:
		ldi		ilcnt, 237				; Load the inner-loop with 237

ILOOP:
		dec		ilcnt					; Decrement the inner-loop
		brne	ILOOP					; Continue to loop inside inner-loop if not reach
		dec		olcnt					; Decrement the middle-loop
		brne	MLOOP					; Continue to loop inside middle-loop if not reach
		dec		waitcnt					; Decrement outer-loop
		brne	OLOOP					; Continue to loop inside outer-loop if not reach

		pop		waitcnt					; Pop & restore registers off of stac
		ret								; Return the subroutine


;***********************************************************
;*	Stored Program Data
;***********************************************************
		; Enter any stored data you might need here

;***********************************************************
;*	Additional Program Includes
;***********************************************************
		; There are no additional file includes for this program