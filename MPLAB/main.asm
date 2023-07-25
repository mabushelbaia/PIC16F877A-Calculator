
PROCESSOR 16F877A
INCLUDE "p16f877a.inc"


__CONFIG 0x3731 ;
; ---------------------------------------------------
; ----------- 		Data Area 			  -----------
; ---------------------------------------------------
R1_LSB EQU 0x20       ; Define the memory location for R1's Least Significant Byte
R1_MSB EQU 0x21       ; Define the memory location for R1's Most Significant Byte
R2_LSB EQU 0x22       ; Define the memory location for R2's Least Significant Byte
R2_MSB EQU 0x23       ; Define the memory location for R2's Most Significant Byte
TEMP_LSB EQU 0x24     ; Define the memory location for temporary storage (Least Significant Byte)
TEMP_MSB EQU 0x25     ; Define the memory location for temporary storage (Most Significant Byte)
RESULT_LSB EQU 0x26   ; Define the memory location for the result (Least Significant Byte)
RESULT_MSB EQU 0x27   ; Define the memory location for the result (Most Significant Byte)
C1 EQU 0x29
C2 EQU 0x2A
C3 EQU 0x2B
C4 EQU 0x2C
C5 EQU 0x2D
CURSOR EQU 0x34
Timer1	EQU	70		
TimerX	EQU	71	
BCDvalH EQU 0x35
BCDvalM EQU 0x36
BCDvalL EQU 0x37
MCount  EQU 0x38
NumbHi  EQU 0x39
NumbLo  EQU 0x3A	
TIMER_INDEX EQU 0x3B
Temp EQU 0x3B
E EQU 5
RS EQU 4
TEMP_W EQU 0x28       ; Define the memory location for unused temporary storage (not used in this code)
; ---------------------------------------------------
; ----------- 			Code Area 		  -----------
; ---------------------------------------------------

ORG 0x00              ; Set the program counter to address 0x00 (start of program)
NOP                   ; No operation (dummy instruction)
	GOTO INIT             ; Jump to the initialization code

ORG 0x04              ; Set the program counter to address 0x04 (interrupt service routine)
	NOP
	BCF 	PIR1,TMR1IF
	BTFSS	INTCON, INTF	; based on INTCON INTF Bit
	GOTO 	TIMER_INTERUPT
	GOTO 	BUTTON_INTERUPT


TIMER_INTERUPT:
	BANKSEL	TIMER_INDEX
	DECFSZ	TIMER_INDEX
	GOTO	SKIP1
	INCF CURSOR
	MOVF CURSOR, 0
	CALL SEND_LCD_COMMAND
	MOVLW '0'
	CALL SEND_LCD_DATA
	MOVF CURSOR, 0
	CALL SEND_LCD_COMMAND
SKIP1
    BCF 	PIR1,TMR1IF     ; clear the TMR1 ov flag 
	BCF		INTCON,INTF		; clear the External Interrupt Flag bit
    RETFIE
BUTTON_INTERUPT:
	BANKSEL INTCON
	BCF INTCON, INTF
	BCF INTCON, INTE
	MOVF CURSOR, 0
	SUBLW 0xC0
	BTFSC STATUS, Z
	GOTO INC_C1
	MOVF CURSOR, 0
	SUBLW 0xC1
	BTFSC STATUS, Z
	GOTO INC_C2
	MOVF CURSOR, 0
	SUBLW 0xC2
	BTFSC STATUS, Z
	GOTO INC_C3
	MOVF CURSOR, 0
	SUBLW 0xC3
	BTFSC STATUS, Z
	GOTO INC_C4
	MOVF CURSOR, 0
	SUBLW 0xC4
	BTFSC STATUS, Z
	GOTO INC_C5
INC_C1:
	INCF C1 			; INCREMENT THE DIGIT
	MOVF C1, 0			; LOAD IT TO W
	SUBLW 0x3A			; CHECK IF IT HAS EXCEEDED '9'
	BTFSC STATUS, Z		; IF IT HAS RESET THE COUNTER
	CALL RESET_COUNTER_C1
	MOVF C1, 0			; MOVE THE NEW COUNTER VALUE TO W
	call SEND_LCD_DATA	
	MOVF CURSOR, 0	
	call SEND_LCD_COMMAND
	goto INTERUPT_END
INC_C2:
	MOVF C1, 0
	SUBLW '6'		
	BTFSC STATUS, Z ; CHECK IF C1 == 6
	GOTO c2_to_five
c2_to_nine:
	INCF C2 			; INCREMENT THE DIGIT
	MOVF C2, 0			; LOAD IT TO W
	SUBLW 0x3A			; CHECK IF IT HAS EXCEEDED '9'
	BTFSC STATUS, Z		; IF IT HAS RESET THE COUNTER
	CALL RESET_COUNTER_C2
	MOVF C2, 0			; MOVE THE NEW COUNTER VALUE TO W
	call SEND_LCD_DATA	
	MOVF CURSOR, 0	
	call SEND_LCD_COMMAND
	goto INTERUPT_END
c2_to_five:
	INCF C2				; INCREMENT THE DIGIT
	MOVF C2, 0			; LOAD IT TO W
	SUBLW '6'			; CHECK IF IT HAS EXCEEDED '5'
	BTFSC STATUS, Z		; IF IT HAS RESET THE COUNTER
	CALL RESET_COUNTER_C2
	MOVF C2, 0			; MOVE THE NEW COUNTER VALUE TO W
	call SEND_LCD_DATA	
	MOVF CURSOR, 0	
	call SEND_LCD_COMMAND
	goto INTERUPT_END	
INC_C3:
	MOVF C2, 0
	SUBLW '5' 		; Check if the last digit is 5
	BTFSC STATUS, Z
	goto check_c1_c3
c3_to_nine:
	INCF C3 			; INCREMENT THE DIGIT
	MOVF C3, 0			; LOAD IT TO W
	SUBLW 0x3A			; CHECK IF IT HAS EXCEEDED '9'
	BTFSC STATUS, Z		; IF IT HAS RESET THE COUNTER
	CALL RESET_COUNTER_C3
	MOVF C3, 0			; MOVE THE NEW COUNTER VALUE TO W
	call SEND_LCD_DATA	
	MOVF CURSOR, 0	
	call SEND_LCD_COMMAND
	goto INTERUPT_END
c3_to_five:
	INCF C3 			; INCREMENT THE DIGIT
	MOVF C3, 0			; LOAD IT TO W
	SUBLW '6'			; CHECK IF IT HAS EXCEEDED '9'
	BTFSC STATUS, Z		; IF IT HAS RESET THE COUNTER
	CALL RESET_COUNTER_C3
	MOVF C3, 0			; MOVE THE NEW COUNTER VALUE TO W
	call SEND_LCD_DATA	
	MOVF CURSOR, 0	
	call SEND_LCD_COMMAND
	goto INTERUPT_END
	
INC_C4:
	MOVF C3, 0
	SUBLW '5'
	BTFSC STATUS, Z
	goto check_c2_c4
c4_to_nine:
	INCF C4			; INCREMENT THE DIGIT
	MOVF C4, 0			; LOAD IT TO W
	SUBLW 0x3A			; CHECK IF IT HAS EXCEEDED '9'
	BTFSC STATUS, Z		; IF IT HAS RESET THE COUNTER
	CALL RESET_COUNTER_C4
	MOVF C4, 0			; MOVE THE NEW COUNTER VALUE TO W
	call SEND_LCD_DATA	
	MOVF CURSOR, 0	
	call SEND_LCD_COMMAND
	goto INTERUPT_END
c4_to_three:
	INCF C4			; INCREMENT THE DIGIT
	MOVF C4, 0			; LOAD IT TO W
	SUBLW '4'			; CHECK IF IT HAS EXCEEDED '9'
	BTFSC STATUS, Z		; IF IT HAS RESET THE COUNTER
	CALL RESET_COUNTER_C4
	MOVF C4, 0			; MOVE THE NEW COUNTER VALUE TO W
	call SEND_LCD_DATA	
	MOVF CURSOR, 0	
	call SEND_LCD_COMMAND
	goto INTERUPT_END
INC_C5:
	MOVF C4, 0
	SUBLW '3'
	BTFSC STATUS, Z
	goto check_c3_c5
c5_to_nine:
	INCF C5 			; INCREMENT THE DIGIT
	MOVF C5, 0			; LOAD IT TO W
	SUBLW 0x3A			; CHECK IF IT HAS EXCEEDED '9'
	BTFSC STATUS, Z		; IF IT HAS RESET THE COUNTER
	CALL RESET_COUNTER_C5
	MOVF C5, 0			; MOVE THE NEW COUNTER VALUE TO W
	call SEND_LCD_DATA	
	MOVF CURSOR, 0	
	call SEND_LCD_COMMAND
	goto INTERUPT_END
c5_to_five:
	INCF C5 			; INCREMENT THE DIGIT
	MOVF C5, 0			; LOAD IT TO W
	SUBLW '6'			; CHECK IF IT HAS EXCEEDED '9'
	BTFSC STATUS, Z		; IF IT HAS RESET THE COUNTER
	CALL RESET_COUNTER_C5
	MOVF C5, 0			; MOVE THE NEW COUNTER VALUE TO W
	call SEND_LCD_DATA	
	MOVF CURSOR, 0	
	call SEND_LCD_COMMAND
	goto INTERUPT_END

INTERUPT_END:
	BANKSEL INTCON
	BCF INTCON, INTF
   	BCF 	PIR1,TMR1IF     ; clear the TMR1 ov flag 
	BSF INTCON, INTE	
	BANKSEL PORTA
	RETFIE

RESET_COUNTER_C1:
	MOVLW '0'
	MOVWF C1
	RETURN
RESET_COUNTER_C2:
	MOVLW '0'
	MOVWF C2
	RETURN
RESET_COUNTER_C3:
	MOVLW '0'
	MOVWF C3
	RETURN
RESET_COUNTER_C4:
	MOVLW '0'
	MOVWF C4
	RETURN
RESET_COUNTER_C5:
	MOVLW '0'
	MOVWF C5
	RETURN
; ==========================================================================
;						END INTERUPTS
;											  
; ===========================================================================
INIT:
	MOVLW '0'
	MOVWF C1
	MOVWF C2
	MOVWF C3
	MOVWF C4
	MOVWF C5
	MOVLW 0xC0
	MOVWF CURSOR
	CALL INTERUPT_INIT
	CALL INIT_DISPLAY
	CALL INTITIAL_MESSAGE
START: 
	MOVWF NumbHi
	MOVWF NumbLo
	CALL HexBCD
	GOTO loop
; ==========================================================================
;						INTERUPTS & PORTS
;											  
; ===========================================================================
INTERUPT_INIT: 
	BANKSEL INTCON
	BSF INTCON, GIE			; ENABLE GLOBAL INTERUPTS
	BSF INTCON, INTE		; ENABLE RB0 INTERUPT BIT
	BSF INTCON, PEIE        ; Enable Peripheral Interrupts

	BANKSEL T1CON
	MOVLW	b'00111001'		; TMR1 initialisation code
	MOVWF	T1CON			; Int clock, prescale128	
	MOVLW	b'00000000'		; MOVE VALUE TO LOWER TMR1 REGISTER
	MOVWF	TMR1L			; 
	MOVLW	b'00000000'		; MOVE VALUE TO HIGHER TMR1 REGISTER
	MOVWF	TMR1H			; CLEAR OVERFLOW FLAG
	
	BANKSEL PIE1            ; ENABLE TMR1 INTERRUPT FLAG
	BSF PIE1,TMR1IE

	BANKSEL PIR1
	BCF PIR1, TMR1IF ;clear TMR1 interrupt flag

	;Start the timer:
	BSF T1CON, TMR1ON ;set TMR1 on bit	
	BCF PIR1, TMR1IF

	MOVLW	0x7f
	MOVWF	TIMER_INDEX
	; CLEAR OVERFLOW FLAG
	BCF 	PIR1,TMR1IF
	BANKSEL PORTA
PORTS_INIT:
	; Convert PORTA into a digital 
	BANKSEL TRISA
	CLRF TRISA	; SET ALL PINS AS OUTPUT
	BANKSEL PORTA
	CLRF PORTA
	BANKSEL ADCON1
	MOVLW 0x06
	MOVWF ADCON1
	; SET PORTB PIN0 AS AN INPUT
	BANKSEL TRISB
	CLRF TRISB
	BSF TRISB, 0
	BANKSEL PORTA
; ==========================================================================
;						DISPLAY AND DELAYS
;											  
; ===========================================================================
xms:
	MOVWF	TimerX			; Count for X ms
loopX:	
	CALL	onems			; Delay 1ms
	DECFSZ	TimerX			; Repeat X times 
	GOTO	loopX			; until Z
	RETURN					; and finish
onems:	
	MOVLW	D'249'			; Count for 1ms delay 
	MOVWF	Timer1			; Load count
loop1:
	NOP						; Pad for 4 cycle loop
	DECFSZ	Timer1			; Count
	GOTO	loop1			; until Z
	RETURN				; and finish
INIT_DISPLAY:
	MOVLW D'100'
	CALL xms
	MOVLW 0x03
	MOVWF PORTA ; SEND 0x03 
	CALL ENABLE_PULSE
	call onems
	call onems
	call onems
	call onems
	call onems
	CALL ENABLE_PULSE
	call onems
	CALL ENABLE_PULSE
	BCF PORTA, 0
	CALL ENABLE_PULSE
	MOVLW	0x2		; Set 4-bit mode, 2 lines 0x28
	MOVWF PORTA
	call ENABLE_PULSE
	call onems
	MOVLW 0x8
	CLRF PORTA
	MOVWF PORTA
	call ENABLE_PULSE
	call onems
	CLRF PORTA
	call ENABLE_PULSE
	call onems
	MOVLW 0xE	; ENABLE BLINKING
	MOVWF PORTA
	call ENABLE_PULSE
	call onems
	RETURN		

ENABLE_PULSE:
	BSF PORTA, E
	call onems
	call onems
	call onems
	call onems
	call onems
	BCF PORTA, E
	call onems
	call onems
	call onems
	call onems
	call onems
	RETURN

SEND_LCD_DATA:
	MOVWF TEMP_W		; SAVE A COPY OF W
	SWAPF  TEMP_W		; SWAP THE HIGHER NIBBLE WITH THE LOWER
	MOVF TEMP_W, 0		; RELOAD THE SWAPPED NIBBLES TO W
	ANDLW 0x0F			; GET RID OF THE "HIGHER NIBBLE" (LOWER ORIGINALY)
	MOVWF PORTA			; STORE THE "LOWER NIBBLE" (HIGHER ORIGINALY) IN PORTA
	BSF PORTA, RS		; SELECT DATA REGISTER
	call ENABLE_PULSE	; SEND PULSE
	call onems
	SWAPF TEMP_W		; RESWAP THE NIBBLES
	MOVF TEMP_W, 0		; STORE IT BACK IN W
	ANDLW 0x0F			; GET RID OF THE "HIGHER NIBBLE"
	MOVWF PORTA			; STORE THE LOWER NIBBLE IN W
	BSF PORTA, RS		; SELECT DATA REGISTER
	call ENABLE_PULSE 	; SEND PULSE
	call onems
	RETURN

SEND_LCD_COMMAND:
	MOVWF TEMP_W		; SAVE A COPY OF W
	SWAPF  TEMP_W		; SWAP THE HIGHER NIBBLE WITH THE LOWER
	MOVF TEMP_W, 0		; RELOAD THE SWAPPED NIBBLES TO W
	ANDLW 0x0F			; GET RID OF THE "HIGHER NIBBLE" (LOWER ORIGINALY)
	MOVWF PORTA			; STORE THE "LOWER NIBBLE" (HIGHER ORIGINALY) IN PORTA
	BCF PORTA, RS		; SELECT COMMAND REGISTER
	call ENABLE_PULSE	; SEND PULSE
	call onems
	SWAPF TEMP_W		; RESWAP THE NIBBLES
	MOVF TEMP_W, 0		; STORE IT BACK IN W
	ANDLW 0x0F			; GET RID OF THE "HIGHER NIBBLE"
	MOVWF PORTA			; STORE THE LOWER NIBBLE IN W
	BCF PORTA, RS		; SELECT COMMAND REGISTER
	call ENABLE_PULSE 	; SEND PULSE
	call onems
	RETURN

INTITIAL_MESSAGE:
	MOVLW 'E'
	CALL SEND_LCD_DATA
	MOVLW 'N'
	CALL SEND_LCD_DATA
	MOVLW 'T'
	CALL SEND_LCD_DATA
	MOVLW 'E'
	CALL SEND_LCD_DATA
	MOVLW 'R'
	CALL SEND_LCD_DATA
	MOVLW ' '
	CALL SEND_LCD_DATA
	MOVLW 'N'
	CALL SEND_LCD_DATA
	MOVLW 'U'
	CALL SEND_LCD_DATA
	MOVLW 'M'
	CALL SEND_LCD_DATA
	MOVLW '1'
	CALL SEND_LCD_DATA
	MOVLW ':'
	CALL SEND_LCD_DATA
	MOVLW 0xC0
	CALL SEND_LCD_COMMAND
	MOVLW '0'
	CALL SEND_LCD_DATA
	MOVF CURSOR, 0
	CALL SEND_LCD_COMMAND
	RETURN
; ==========================================================================
;							NUMBERS & CONVERSIONS
;											  
; ===========================================================================
HexBCD: 
	movlw d'16'
	movwf MCount
	clrf BCDvalH
	clrf BCDvalM
	clrf BCDvalL
	bcf STATUS,C

loop16:  
	rlf NumbLo,F
	rlf NumbHi,F
	rlf BCDvalL,F
	rlf BCDvalM,F
	rlf BCDvalH,F

 	decf MCount,F
 	btfsc STATUS,Z
 	return

adjDEC:   
	movlw BCDvalL
	movwf FSR
	call adjBCD
	movlw BCDvalM
	movwf FSR
	call adjBCD
	movlw BCDvalH
	movwf FSR
	call adjBCD
	goto loop16

adjBCD 
	movlw d'3'
	addwf INDF,W
	movwf Temp
	btfsc Temp,3
	movwf INDF
	movlw 30h
	addwf INDF,W
	movwf Temp
	btfsc Temp,7
	movwf INDF
	return
; ==========================================================================
;						ARETHMETIC OPERATIONS 
;											  
; ===========================================================================
ADD:
	CLRF RESULT_LSB       ; Clear the result's Least Significant Byte
	CLRF RESULT_MSB       ; Clear the result's Most Significant Byte
	MOVF R1_LSB, 0        ; Move the value in R1_LSB to W register
	ADDWF R2_LSB, 0       ; Add the value in W to R2_LSB (result in R2_LSB with no carry)
	BTFSC STATUS, 0       ; Check if there was a carry from the previous addition
	INCF RESULT_MSB       ; If carry, increment the result's Most Significant Byte
	MOVWF RESULT_LSB      ; Move the result of addition to the result's Least Significant Byte
	MOVF R1_MSB, 0        ; Move the value in R1_MSB to W register
	ADDWF R2_MSB, 0       ; Add the value in W to R2_MSB (result in R2_MSB with carry)
	ADDWF RESULT_MSB      ; Add the result of addition to the result's Most Significant Byte
	RETURN               ; Return from the subroutine

SUB:
	COMF R2_LSB, 0        ; Compute the two's complement of R2_LSB
	ADDWF TEMP_LSB, 0     ; Add 1 to get the two's complement
	BTFSC STATUS, 0       ; Check if there was a carry from the previous addition
	INCF TEMP_MSB         ; If there was a carry, increment TEMP_MSB
	ADDLW 0x01            ; Add 1 to W register
	BTFSC STATUS, 0       ; Check if there was a carry from the previous addition
	INCF TEMP_MSB         ; If there was a carry, increment TEMP_MSB
	MOVWF TEMP_LSB        ; Move the result of two's complement to TEMP_LSB
	COMF R2_MSB, 0        ; Compute the two's complement of R2_MSB
	ADDWF TEMP_MSB, 0     ; Add 1 to get the two's complement
	MOVWF TEMP_MSB        ; Move the result of two's complement to TEMP_MSB
	RETURN                ; Return from the subroutine

DIVIDE:
	CLRF RESULT_MSB       ; Clear the result's Most Significant Byte
	CLRF RESULT_LSB       ; Clear the result's Least Significant Byte
	MOVF R1_LSB, 0        ; Move the value in R1_LSB to TEMP_LSB (temporary storage)
	MOVWF TEMP_LSB
	MOVF R1_MSB, 0        ; Move the value in R1_MSB to TEMP_MSB (temporary storage)
	MOVWF TEMP_MSB
DIVLOOP:
	CALL SUB              ; Call the SUB subroutine to perform subtraction
	BTFSS STATUS, 0       ; Check if there was a borrow (no carry) from the previous subtraction
	GOTO DIVEND           ; If no borrow, exit the loop (division complete)
	INCF RESULT_LSB       ; Increment the result's Least Significant Byte
	BTFSC STATUS, 2       ; Check if the register is overflown
	INCF RESULT_MSB       ; If it is, increment the result's Most Significant Byte
	GOTO DIVLOOP          ; Continue the division loop
DIVEND:
	RETURN                ; Return from the DIVIDE subroutine
MOD:
	CLRF RESULT_MSB       ; Clear the result's Most Significant Byte (initialize to 0)
	CLRF RESULT_LSB       ; Clear the result's Least Significant Byte (initialize to 0)
	MOVF R1_LSB, 0        ; Move the value in R1_LSB to TEMP_LSB (temporary storage)
	MOVWF TEMP_LSB
	MOVF R1_MSB, 0        ; Move the value in R1_MSB to TEMP_MSB (temporary storage)
	MOVWF TEMP_MSB
MODLOOP:
	CALL SUB              ; Call the SUB subroutine to perform subtraction
	BTFSS STATUS, 0       ; Check if there was a borrow (no carry) from the previous subtraction
	GOTO MODEND           ; If no borrow, exit the loop (modulo operation complete)
	GOTO MODLOOP          ; Continue the modulo loop

MODEND:
	MOVF R2_LSB, 0        ; Move the value in R2_LSB to W register
	ADDWF TEMP_LSB, 0     ; Add the value in W to TEMP_LSB (carry ignored as it's not needed)
	BTFSC STATUS, 0       ; Check if there was a carry from the addition
	INCF RESULT_MSB       ; If carry, increment the result's Most Significant Byte
	MOVWF RESULT_LSB      ; Move the result of the addition to the result's Least Significant Byte

	MOVF R2_MSB, 0        ; Move the value in R2_MSB to W register
	ADDWF TEMP_MSB, 0     ; Add the value in W to TEMP_MSB (carry ignored as it's not needed)
	ADDWF RESULT_MSB      ; Add the result of the addition to the result's Most Significant Byte

	RETURN               	; Return from the MOD subroutine              

; ==========================================================================
;						INCREMENTS
;											  
; ===========================================================================
check_c1_c3:
	MOVF C1, 0
	SUBLW '6'
	BTFSC STATUS, Z
	goto c3_to_five
	goto c3_to_nine
check_c2_c4:
	MOVF C2, 0
	SUBLW '5'
	BTFSC STATUS, Z
	goto check_c1_c4
	goto c4_to_nine
check_c1_c4:
	MOVF C1, 0
	SUBLW '6'
	BTFSC STATUS, Z
	goto c4_to_three
	goto c4_to_nine
check_c3_c5:
	MOVF C3, 0
	SUBLW '5'
	BTFSC STATUS, Z
	goto check_c2_c5
	goto c5_to_nine
check_c2_c5:
	MOVF C2, 0
	SUBLW '5'
	BTFSC STATUS, Z
	goto check_c1_c5
	goto c5_to_nine
check_c1_c5:
	MOVF C1, 0
	SUBLW '6'
	BTFSC STATUS, Z
	goto c5_to_five
	goto c5_to_nine

loop:
	GOTO loop
	END                  ; End of the progra