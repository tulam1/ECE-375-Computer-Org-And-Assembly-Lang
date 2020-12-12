/******************************************************************
 * BumpBot.c
 *
 * This code will cause a TekBot connected to the AVR board to
 * move forward and when it touches an obstacle, it will reverse
 * and turn away from the obstacle and resume forward motion.

 * PORT MAP
 * Port B, Pin 4 -> Output -> Right Motor Enable
 * Port B, Pin 5 -> Output -> Right Motor Direction
 * Port B, Pin 7 -> Output -> Left Motor Enable
 * Port B, Pin 6 -> Output -> Left Motor Direction
 * Port D, Pin 1 -> Input -> Left Whisker
 * Port D, Pin 0 -> Input -> Right Whisker
 ******************************************************************
 *
 * Author: Tu Lam
 * Date: October 11, 2020
 * 
 ******************************************************************/

#define F_CPU 16000000											//This include all the definition files
#include <avr/io.h>
#include <util/delay.h>
#include <stdio.h>

int main(void)
{
	DDRB = 0b11110000;											//This configure Port B[Pin 4 - 7] to be the outputs
	PORTB = 0b11110000;											//Set up the Pin 4 - 7 to turn on it LED

	while (1) // loop forever
	{
		PORTB = 0b01100000;										//This set the BumpBot to move forward forever until a trigger is hit
		_delay_ms(500);											//Wait for 500 ms
		
		
		if (PIND == 0b11111110) {								//Look if the right whisker hit
			RightWhisker();
		}
		
		else if (PIND == 0b11111101) {							//Look if the left whisker hit
			LeftWhisker();
		}
		
		else if (PIND == 0b11111100) {						    //Look if the left & right whisker hit
			BothWhiskers();
		}
	}
}

/************************************************************
* Function: RightWhisker
* Description: If the right whisker hit on PIN 0 in PORTD,
               The BumpBot will turn left and move forward.
************************************************************/
void RightWhisker() {
	
	PORTB = 0b00000000;										    //Move backward
	_delay_ms(500);												//Wait for 500ms
	PORTB = 0b00100000;											//Turn left for a second
	_delay_ms(1000);											//Wait for 1s
	PORTB = 0b01100000;											//Continue forward
	_delay_ms(500);												//Wait for 500ms
}

/************************************************************
* Function: LeftWhisker
* Description: If the right whisker hit on PIN 1 in PORTD,
               The BumpBot will turn right and move forward.
************************************************************/
void LeftWhisker() {
	
	PORTB = 0b00000000;										    //Move backward
	_delay_ms(500);												//Wait for 500ms
	PORTB = 0b01000000;											//Turn right for a second
	_delay_ms(1000);											//Wait for 1s
	PORTB = 0b01100000;											//Continue forward
	_delay_ms(500);												//Wait for 500ms
}

/************************************************************
* Function: BothWhiskers
* Description: If the both whiskers hit on PIN 1 & 0 in PORTD,
               The BumpBot will turn left and move forward.
************************************************************/
void BothWhiskers() {
	
	PORTB = 0b00000000;										    //Move backward
	_delay_ms(500);												//Wait for 500ms
	PORTB = 0b00100000;											//Turn left for a second
	_delay_ms(1000);											//Wait for 1s
	PORTB = 0b01100000;											//Continue forward
	_delay_ms(500);												//Wait for 500ms
}
