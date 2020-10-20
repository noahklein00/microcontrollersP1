; CLASS: 3150
; ASSIGNMENT: Project 1
; NAMES: Noah Klein, Jacob Kaufman, Andrew Duke, Nick Lambert

.ORG 0

		LDI R16, HIGH(RAMEND) ; Set the high and low bits of the stack pointer
		OUT SPH, R16
		LDI R16, LOW(RAMEND)
		OUT SPL, R16

		CBI DDRD, 4 ; Port D,4 is input (LEFT BUTTON)
		SBI PORTD, 4 ; Port D,4 has pull-up resistor enabled
		CBI DDRF, 6 ; Port F,6 is input (RIGHT BUTTON)
		SBI PORTF, 6 ; Port F,6 has pull-up resistor enabled
		SBI DDRC, 6 ; Port C,6 is output (SPEAKER)

		LDI R21, 0 ; Counter register
		LDI R22, 0 ; Temporary register used for MOV instructions
		LDI R23, 20 ; CONSTANT 20
		LDI R24, 1 ; CONSTANT 1

;////////////// MAIN LOOP ////////////////////
; MAIN loop checks for active buttons and calls increment or decrement functions
MAIN:	SBIC PIND, 4
		CALL LEFT_DEC
		SBIC PINF, 6
		CALL RIGHT_INC
		RJMP MAIN

;////////////// BUTTON CHECKING FUNCTIONS ///////////////////
; Waits for the depress of the left button
WAIT_FOR_INACTIVE_LEFT:
	SBIS PIND, 4
	RET
	RJMP WAIT_FOR_INACTIVE_LEFT

; Waits for the depress of the right button
WAIT_FOR_INACTIVE_RIGHT:
	SBIS PINF, 6
	RET
	RJMP WAIT_FOR_INACTIVE_RIGHT

;//////////////// COUNTER ADJUSTMENT FUNCTIONS /////////////////
; Increments the count by one. Calls SET_TO_ZERO if the count gets to 20
RIGHT_INC:
	INC R21	
	MOV R22, R21 ;COPIES THE DATA OF R21 INTO R23 for non-destructive checking
	SUB R22, R23 ; Subtracts constant 20 from the temporary counter
	BREQ SET_TO_ZERO ; Sets the counter to 0 if it is at 20
	CALL WAIT_FOR_INACTIVE_RIGHT ; Waits for the depress of the button
	RET

LEFT_DEC:
	DEC R21
	MOV R22, R21 ; Copies the data of R21 into R22 for non-destructive checking
	ADD R22, R24 ;R24 = 1, so if R23 = -1 This equals 0
	BREQ SET_TO_TWENTY ; and if it equals zero, it resets the counter to 19
	CALL WAIT_FOR_INACTIVE_LEFT
	RET


SET_TO_ZERO:
	SUB R21, R23 ; Add 20 to the counter
	CALL PLAYLOWSOUND
	RET

SET_TO_TWENTY:
	ADD R21, R23 ;R23 = 20, R21 = -1, now R21 = 19
	CALL PLAYHIGHSOUND
	RET

;////////// SOUND FUNCTIONS ////////////////

;Play 1.5k frequency for .3 seconds
PLAYHIGHSOUND: LDI R19, 112
HIGHDELAY1: LDI R20, 4
HIGHDELAY2: SBI PORTC, 6
RCALL HIGHFREQ
NOP
NOP
CBI PORTC, 6
RCALL HIGHFREQ
DEC R20
BRNE HIGHDELAY2
DEC R19
BRNE HIGHDELAY1
RET

;Delay between switches to speaker port bit
HIGHFREQ: LDI R17, 116
HIGHFREQ1: LDI R18, 6
NOP
NOP
HIGHFREQ2: DEC R18
BRNE HIGHFREQ2
DEC R17
BRNE HIGHFREQ1
RET

;Play 1k frequency for .3 seconds
PLAYLOWSOUND: LDI R19, 23
LOWDELAY1: LDI R20, 14
LOWDELAY2: SBI PORTC, 6
RCALL LOWFREQ
NOP
NOP
CBI PORTC, 6
RCALL LOWFREQ
DEC R20
BRNE LOWDELAY2
DEC R19
BRNE LOWDELAY1
RET

;Delay between switches to speaker port bit
LOWFREQ: LDI R17, 200
LOWFREQ1: LDI R18, 5
NOP
NOP
LOWFREQ2: DEC R18
BRNE LOWFREQ2
DEC R17
BRNE LOWFREQ1
RET

		