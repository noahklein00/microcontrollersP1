; CLASS: 3150
; ASSIGNMENT: Project 1
; NAMES: Noah Klein, Jacob Kaufman, Andrew Duke, Nick Lambert

.ORG 0

;///////////////// INITIALIZATION ///////////////////
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
		LDI R29, 0 ; CONSTANT 0
		LDI R31, 30 ; CONSTANT 30

;////////////// MAIN LOOP ////////////////////
; MAIN loop checks for active buttons and calls increment or decrement functions
MAIN:	SBIC PIND, 4
		CALL LEFT_DEC
		SBIC PINF, 6
		CALL RIGHT_INC
		MOV R30, R21 ; copy counter
		SUB R30, R29 ; check if 0
		BREQ TURN_OFF
		MOV R30, R21 ; copy counter
		SUB R30, R23 ; check if 20
		ADD R30, R24 ; check if 0
		BREQ TURN_ON
		CALL FLASH_LED
		RJMP MAIN

;////////////// LED FUNCTIONS ////////////////////

TURN_ON:	SBI PORTC, 7 ; Activate LED
			RJMP MAIN

TURN_OFF:	CBI PORTC, 7 ; Deactivate LED
			RJMP MAIN

FLASH_LED: ;Called when 0 < count < 19
	SBI PORTC, 7
	CALL DELAY_LED
	CBI PORTC, 7
	CALL DELAY_LED
	RET


DELAY_LED:	MOV R25, R31 ; Sets registers with 30
			SUB R25, R21 ; Subtracts the value of the counter, the higher the counter, the lower the value, the shorter the loop
	LOOP1:	MOV R26, R31 ; same
			SUB R26, R21
	LOOP2:	MOV R27, R31 ; same
			SUB R27, R21
	LOOP3:  LDI R28, 15  ; constant delay spacing
	LOOP4:  SBIC PIND, 4 ; Checks the button presses during the delay loop so it doesn't miss presses while delaying
			CALL LEFT_DEC
			SBIC PINF, 6
			CALL RIGHT_INC
			DEC R28 ; if none of the buttons are pressed, it continues with the delay loop like normal
			BRNE LOOP4
			DEC R27
			BRNE LOOP3
			DEC R26
			BRNE LOOP2
			DEC R25
			BRNE LOOP1
			RET

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
	RJMP MAIN
	;RET

LEFT_DEC:
	DEC R21
	MOV R22, R21 ; Copies the data of R21 into R22 for non-destructive checking
	ADD R22, R24 ;R24 = 1, so if R23 = -1 This equals 0
	BREQ SET_TO_TWENTY ; and if it equals zero, it resets the counter to 19
	CALL WAIT_FOR_INACTIVE_LEFT
	RJMP MAIN
	;RET


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
	