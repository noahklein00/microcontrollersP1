;
; example setup
;

.ORG 0
		LDI R16, HIGH(RAMEND)
		OUT SPH, R16
		LDI R16, LOW(RAMEND)
		OUT SPL, R16

		;SET REGISTERS TO APPROPRIATE ACTIVE AND LOW VALUES
		LDI R16, 0b11101111 ;1110 1111
		OUT DDRD, R16 ;PORT D,4 IS INPUT (LEFT BUTTON)
		LDI R16, 0b10111111 ;1011 1111
		OUT DDRF, R16 ;PORT F,6 IS INPUT (RIGHT BUTTON)
		LDI R16, 0b01000000 ;0100 0000
		OUT DDRC, R16 ;PORT C,6 IS OUTPUT (SPEAKER)
		LDI R18, 0x00 ;0000 0000
		LDI R21, 0b00010000 ;0001 0000
		LDI R27, 0b01000000 ;0100 0000
		LDI R22, 0b00000000 ;0000 0000
		LDI R23, 0x00 ;STORAGE FOR COUNTER
		LDI R24, 0b00010100 ;20!
		LDI R26, 0b00000001 ;1!

HERE:	CALL WAIT_FOR_ACTIVE_RIGHT
		NOP ;INFINITE LOOP FOR PROGRAM
		CALL DELAY
		OUT PORTC, R16
		CALL DELAY
		OUT PORTC, R18
		RJMP HERE

		
DELAY:	LDI R17, 200
LOOP1:  LDI R18, 25
LOOP2:	DEC R18
		BRNE LOOP2
		DEC R17
		BRNE LOOP1
		RET

WAIT_FOR_ACTIVE_LEFT:  
	IN R20, PIND ;0001 0000
	SUB R20, R21
	BRNE WAIT_FOR_ACTIVE_LEFT
	RET

WAIT_FOR_INACTIVE_LEFT:
	IN R20, PIND
	ADD R20, R22
	BRNE WAIT_FOR_INACTIVE_LEFT
	RET

WAIT_FOR_ACTIVE_RIGHT:  
	IN R20, PINF ;0100 0000
	SUB R20, R27
	BRNE WAIT_FOR_ACTIVE_RIGHT
	RET

WAIT_FOR_INACTIVE_RIGHT:
	IN R20, PINF ;0100 0000
	ADD R20, R22
	BRNE WAIT_FOR_INACTIVE_RIGHT
	RET

RIGHT_INC:
	INC R23	
	MOV R25, R23 ;COPIES THE DATA OF R23 INTO R25
	SUB R25, R24
	BREQ SET_TO_ZERO
	CALL WAIT_FOR_INACTIVE_RIGHT
	RET

LEFT_DEC:
	DEC R23
	MOV R25, R23
	ADD R25, R26
	BREQ SET_TO_TWENTY
	CALL WAIT_FOR_INACTIVE_LEFT
	RET


SET_TO_ZERO:
	SUB R23, R24
	RET

SET_TO_TWENTY:
	ADD R23, R24
	RET

		