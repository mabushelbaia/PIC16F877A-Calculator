
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
DIGIT6 EQU 0x50
DIGIT5 EQU 0x51
DIGIT4 EQU 0x52
DIGIT3 EQU 0x53
DIGIT2 EQU 0x54
DIGIT1 EQU 0x55
BCDvalH EQU 0x35
BCDvalM EQU 0x36
BCDvalL EQU 0x37
MCount  EQU 0x38
NUMHI EQU 0x3E
NUMLO EQU 0x3F
TIMER_INDEX EQU 0x3B
Temp EQU 0x3C
NEXT_STATE EQU 0x2E
OPERATION EQU 0x2F
E EQU 5
RS EQU 4
R1_C1 EQU 0x40
R1_C2 EQU 0x41
R1_C3 EQU 0x42
R1_C4 EQU 0x43
R1_C5 EQU 0x44
R2_C1 EQU 0x45
R2_C2 EQU 0x46
R2_C3 EQU 0x47
R2_C4 EQU 0x48
R2_C5 EQU 0x49
CARRY_SAVED EQU 0x4B
TEMP_W EQU 0x28       ; Define the memory location for unused temporary storage (not used in this code)
; ---------------------------------------------------
; ----------- 			Code Area 		  -----------
; ---------------------------------------------------

ORG 0x00              ; Set the program counter to address 0x00 (start of program)
NOP                   ; No operation (dummy instruction)
	GOTO INIT             ; Jump to the initialization code

ORG 0x04              ; Set the program counter to address 0x04 (interrupt service routine)
	NOP

	BTFSS	INTCON, INTF	; based on INTCON INTF Bit
	GOTO 	TIMER_INTERUPT
	GOTO 	BUTTON_INTERUPT


TIMER_INTERUPT:
	BANKSEL INTCON
	BCF INTCON, GIE
	BANKSEL PORTA
	DECFSZ	TIMER_INDEX
	GOTO	SKIP
	NOP
	BTFSC NEXT_STATE, 0
	GOTO SECOND_MESSAGE
	BTFSC NEXT_STATE, 2
	GOTO DISPLAY_RESULT_WITHOUT_SAVING
	GOTO INCREMENT_DISPLAY
INCREMENT_DISPLAY:
	INCF CURSOR
	MOVF CURSOR, 0
	SUBLW 0xCB
	BTFSC STATUS, Z
	GOTO DISPLAY_RESULT
	MOVF CURSOR, 0
	SUBLW 0xC5
	BTFSC STATUS, Z
	CALL SAVE_NUMBER_1
	MOVF CURSOR, 0
	CALL SEND_LCD_COMMAND
	MOVLW D'30'
	MOVWF TIMER_INDEX
	GOTO SKIP
SECOND_MESSAGE:
	BTFSC NEXT_STATE, 1
	GOTO SKIP
	GOTO KEEP_MESSAGE
KEEP_MESSAGE:
	MOVLW 0x80
	MOVWF CURSOR
	CALL SEND_LCD_COMMAND
	MOVLW 'K'
	CALL SEND_LCD_DATA
	MOVLW 'E'
	CALL SEND_LCD_DATA
	MOVLW 'E'
	CALL SEND_LCD_DATA
	MOVLW 'P'
	CALL SEND_LCD_DATA
	MOVLW '?'
	CALL SEND_LCD_DATA
	MOVLW ' '
	CALL SEND_LCD_DATA
	MOVLW '['
	CALL SEND_LCD_DATA
	MOVLW '1'
	CALL SEND_LCD_DATA
	MOVLW ':'
	CALL SEND_LCD_DATA
	MOVLW 'Y'
	CALL SEND_LCD_DATA
	MOVLW ','
	CALL SEND_LCD_DATA
	MOVLW '2'
	CALL SEND_LCD_DATA
	MOVLW ':'
	CALL SEND_LCD_DATA
	MOVLW 'N'
	CALL SEND_LCD_DATA
	MOVLW ']'
	CALL SEND_LCD_DATA
	MOVLW ' '
	CALL SEND_LCD_DATA
	MOVLW 0x8E
	MOVWF CURSOR
	CALL SEND_LCD_COMMAND
	BSF NEXT_STATE, 1
	GOTO SKIP
SKIP:
	BANKSEL TMR0
	CLRF TMR0
	BANKSEL INTCON
	BCF INTCON, T0IF ; Clear the TMR0 ov flag
	BSF INTCON, GIE	; ENABLE GLOBAL INTERUPTS
	BANKSEL PORTA
    RETFIE

DISPLAY_RESULT:
	CALL SAVE_NUMBER_2
DISPLAY_RESULT_WITHOUT_SAVING:
	CLRF NEXT_STATE
	BSF NEXT_STATE, 0
	MOVLW 0x0C
	CALL SEND_LCD_COMMAND
	MOVF OPERATION, 0
	SUBLW '+'
	BTFSC STATUS, Z
	GOTO ADDITION
	MOVF OPERATION, 0
	SUBLW '/'
	BTFSC STATUS, Z
	GOTO DIVISION
	MOVF OPERATION, 0
	SUBLW '%'
	BTFSC STATUS, Z
	GOTO MODULO
	GOTO SKIP
ADDITION:
	BCF STATUS, C
	BCF STATUS, Z
	CALL ADD
	CALL HexBCD
	GOTO DISPLAY_RESULT_END
DIVISION:
	BCF STATUS, C
	BCF STATUS, Z
	CALL DIVIDE
	CALL HexBCD
	GOTO DISPLAY_RESULT_END
MODULO:
	BCF STATUS, C
	BCF STATUS, Z
	CALL MOD
	CALL HexBCD
	GOTO DISPLAY_RESULT_END
DISPLAY_RESULT_END:
	SWAPF BCDvalH, 1
	MOVF BCDvalH, 0
	ANDLW 0x0F
	ADDLW '0'
	MOVWF DIGIT6
	SWAPF BCDvalH, 1
	MOVF BCDvalH, 0
	ANDLW 0x0F
	ADDLW '0'
	MOVWF DIGIT5
	SWAPF BCDvalM, 1
	MOVF BCDvalM, 0
	ANDLW 0x0F
	ADDLW '0'
	MOVWF DIGIT4
	SWAPF BCDvalM, 1
	MOVF BCDvalM, 0
	ANDLW 0x0F
	ADDLW '0'
	MOVWF DIGIT3
	SWAPF BCDvalL, 1
	MOVF BCDvalL, 0
	ANDLW 0x0F
	ADDLW '0'
	MOVWF DIGIT2
	SWAPF BCDvalL, 1
	MOVF BCDvalL, 0
	ANDLW 0x0F
	ADDLW '0'
	MOVWF DIGIT1
	BTFSC CARRY_SAVED, 0
	CALL  NORMALIZE_NUMBER
	MOVLW 0x80
	MOVWF CURSOR
	CALL SEND_LCD_COMMAND
	MOVLW 0x01
	CALL SEND_LCD_COMMAND
	MOVLW 'R'
	CALL SEND_LCD_DATA
	MOVLW 'E'
	CALL SEND_LCD_DATA
	MOVLW 'S'
	CALL SEND_LCD_DATA
	MOVLW 'U'
	CALL SEND_LCD_DATA
	MOVLW 'L'
	CALL SEND_LCD_DATA
	MOVLW 'T'
	CALL SEND_LCD_DATA
	MOVLW 0xC0
	CALL SEND_LCD_COMMAND
	MOVLW '='
	CALL SEND_LCD_DATA
	MOVF DIGIT6, 0
	CALL SEND_LCD_DATA
	MOVF DIGIT5, 0
	CALL SEND_LCD_DATA
	MOVF DIGIT4, 0
	CALL SEND_LCD_DATA
	MOVF DIGIT3, 0
	CALL SEND_LCD_DATA
	MOVF DIGIT2, 0
	CALL SEND_LCD_DATA
	MOVF DIGIT1, 0
	CALL SEND_LCD_DATA
	MOVLW D'40'
	MOVWF TIMER_INDEX
	GOTO SKIP

BUTTON_INTERUPT:
	CALL RESET_TIMER
	BANKSEL INTCON
	BCF INTCON, INTF
	BCF INTCON, INTE
	BTFSC NEXT_STATE, 0
	GOTO DOUBLE_CLICK_CHECK
	BTFSC NEXT_STATE, 2
	GOTO CHANGE_OPERATION
	MOVLW 0x0E
	CALL SEND_LCD_COMMAND
	MOVF CURSOR, 0
	SUBLW 0xC5
	BTFSC STATUS, Z
	GOTO CHANGE_OPERATION_WITH_INCREMENT
	GOTO NUMBERS_IN

DOUBLE_CLICK_CHECK:
	MOVLW D'255'
	call xms
	MOVLW D'150'
	call xms
	BANKSEL PORTB
	BTFSC PORTB, 0
	GOTO DOUBLE_CLICK
	GOTO SINGLE_CLICK

DOUBLE_CLICK:
	CLRF NEXT_STATE
	BSF NEXT_STATE, 2
	CALL RESET_TIMER
	MOVLW '+'
	MOVWF OPERATION
	MOVLW 0x01
	CALL SEND_LCD_COMMAND
	GOTO KEEP_NUMBERS
SINGLE_CLICK:
	CLRF NEXT_STATE
	CALL INTITIAL_MESSAGE
	CLRF NUMHI
	CLRF NUMLO
	MOVLW '+'
	MOVWF OPERATION
	GOTO INTERUPT_END

SAVE_NUMBER_1:
	MOVF C1, 0
	MOVWF R1_C1
	MOVF C2, 0
	MOVWF R1_C2
	MOVF C3, 0
	MOVWF R1_C3
	MOVF C4, 0
	MOVWF R1_C4
	MOVF C5, 0
	MOVWF R1_C5
	MOVLW '0'
	SUBWF C1, 1
	MOVLW '0'
	SUBWF C2, 1
	MOVLW '0'
	SUBWF C3, 1
	MOVLW '0'
	SUBWF C4, 1
	MOVLW '0'
	SUBWF C5, 1

	CALL dec2bin16
	MOVF NUMHI, 0
	MOVWF R1_MSB
	MOVF NUMLO, 0
	MOVWF R1_LSB
	MOVLW '0'
	MOVWF C1
	MOVWF C2
	MOVWF C3
	MOVWF C4
	MOVWF C5
	RETURN
SAVE_NUMBER_2:
	MOVF C1, 0
	MOVWF R2_C1
	MOVF C2, 0
	MOVWF R2_C2
	MOVF C3, 0
	MOVWF R2_C3
	MOVF C4, 0
	MOVWF R2_C4
	MOVF C5, 0
	MOVWF R2_C5
	MOVLW '0'
	SUBWF C1, 1
	MOVLW '0'
	SUBWF C2, 1
	MOVLW '0'
	SUBWF C3, 1
	MOVLW '0'
	SUBWF C4, 1
	MOVLW '0'
	SUBWF C5, 1

	CALL dec2bin16
	MOVF NUMHI, 0
	MOVWF R2_MSB
	MOVF NUMLO, 0
	MOVWF R2_LSB
	MOVLW '0'
	MOVWF C1
	MOVWF C2
	MOVWF C3
	MOVWF C4
	MOVWF C5
	RETURN
CHANGE_OPERATION_WITH_INCREMENT:
CHANGE_OPERATION:
	MOVF OPERATION, 0
	SUBLW '+'
	BTFSC STATUS, Z
	goto plus_digit
	MOVF OPERATION, 0
	SUBLW '/'
	BTFSC STATUS, Z
	goto div_digit
	MOVF OPERATION, 0
	SUBLW '%'
	BTFSC STATUS, Z
	goto mod_digit
plus_digit:
	MOVLW '/'
	MOVWF OPERATION
	CALL SEND_LCD_DATA
	MOVF CURSOR, 0
	CALL SEND_LCD_COMMAND
	goto INTERUPT_END
mod_digit:
	MOVLW '+'
	MOVWF OPERATION
	CALL SEND_LCD_DATA
	MOVF CURSOR, 0
	CALL SEND_LCD_COMMAND
	goto INTERUPT_END
div_digit:
	MOVLW '%'
	MOVWF OPERATION
	CALL SEND_LCD_DATA
	MOVF CURSOR, 0
	CALL SEND_LCD_COMMAND
	goto INTERUPT_END 
	
	
NUMBERS_IN:
	MOVF CURSOR, 0
	SUBLW 0xC5
	BTFSS STATUS, 0 
	GOTO NUMBERS_IN_2
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
NUMBERS_IN_2:
	MOVF CURSOR, 0
	SUBLW 0xC6
	BTFSC STATUS, Z
	GOTO INC_C1
	MOVF CURSOR, 0
	SUBLW 0xC7
	BTFSC STATUS, Z
	GOTO INC_C2
	MOVF CURSOR, 0
	SUBLW 0xC8
	BTFSC STATUS, Z
	GOTO INC_C3
	MOVF CURSOR, 0
	SUBLW 0xC9
	BTFSC STATUS, Z
	GOTO INC_C4
	MOVF CURSOR, 0
	SUBLW 0xCA
	BTFSC STATUS, Z
	GOTO INC_C5
INC_C1:
	INCF C1 			; INCREMENT THE DIGIT
	MOVF C1, 0			; LOAD IT TO W
	SUBLW '7'			; CHECK IF IT HAS EXCEEDED '7'
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
	CLRF R1_C1
	CLRF R1_C2
	CLRF R1_C3
	CLRF R1_C4
	CLRF R1_C5
	CLRF R2_C1
	CLRF R2_C2
	CLRF R2_C3
	CLRF R2_C4
	CLRF R2_C5
	CLRF RESULT_LSB
	CLRF RESULT_MSB
	CLRF R1_LSB
	CLRF R2_LSB
	CLRF R1_MSB
	CLRF R2_MSB
	CLRF TEMP_LSB
	CLRF TEMP_MSB
	CLRF NEXT_STATE
	MOVLW '0'
	MOVWF C1
	MOVWF C2
	MOVWF C3
	MOVWF C4
	MOVWF C5
	MOVLW '+'				; SET THE OPERATION TO ADDITION
	MOVWF OPERATION
	MOVLW 0xC0
	MOVWF CURSOR
	MOVLW D'30'
	MOVWF TIMER_INDEX
	CALL INTERUPT_INIT
	CALL PORTS_INIT
	CALL INIT_DISPLAY
	CALL INTITIAL_MESSAGE
START: 
	GOTO loop

; ==========================================================================
;						INTERUPTS & PORTS
;											  
; ===========================================================================
INTERUPT_INIT: 
	BANKSEL INTCON
	BSF INTCON, GIE			; ENABLE GLOBAL INTERUPTS
	BSF INTCON, INTE		; ENABLE RB0 INTERUPT BIT
	BSF INTCON, T0IE        ; Enable Timer0 Interrupts
	BANKSEL OPTION_REG
	MOVLW 07h
	MOVWF OPTION_REG ;Prescaler set to maximum
	BCF INTCON, T0IF ; Clear the TMR0 ov flag
	BANKSEL PORTA
	RETURN
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
	CLRF PORTB
	BSF TRISB, 0
	BANKSEL PORTA
	RETURN
RESET_TIMER:
	BANKSEL PORTA
	MOVLW D'30'
	MOVWF TIMER_INDEX
	BSF INTCON, T0IF ; Clear the TMR0 ov flag
	RETURN
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
	MOVLW 0x0C
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
KEEP_NUMBERS:
	MOVLW 0x80
	CALL SEND_LCD_COMMAND
	MOVLW 'P'
	CALL SEND_LCD_DATA
	MOVLW 'I'
	CALL SEND_LCD_DATA
	MOVLW 'C'
	CALL SEND_LCD_DATA
	MOVLW 'K'
	CALL SEND_LCD_DATA
	MOVLW ' '
	CALL SEND_LCD_DATA
	MOVLW 'O'
	CALL SEND_LCD_DATA
	MOVLW 'P'
	CALL SEND_LCD_DATA
	MOVLW 'E'
	CALL SEND_LCD_DATA
	MOVLW 'R'
	CALL SEND_LCD_DATA
	MOVLW 'A'
	CALL SEND_LCD_DATA
	MOVLW 'T'
	CALL SEND_LCD_DATA
	MOVLW 'I'
	CALL SEND_LCD_DATA
	MOVLW 'O'
	CALL SEND_LCD_DATA
	MOVLW 'N'
	CALL SEND_LCD_DATA
	MOVLW ':'
	CALL SEND_LCD_DATA
	MOVLW 0xC0
	MOVWF CURSOR
	CALL SEND_LCD_COMMAND
	MOVF R1_C1, 0
	CALL SEND_LCD_DATA
	MOVF R1_C2, 0
	CALL SEND_LCD_DATA
	MOVF R1_C3, 0
	CALL SEND_LCD_DATA
	MOVF R1_C4, 0
	CALL SEND_LCD_DATA
	MOVF R1_C5, 0
	CALL SEND_LCD_DATA
	MOVLW '+'
	CALL SEND_LCD_DATA
	MOVF R2_C1, 0
	CALL SEND_LCD_DATA
	MOVF R2_C2, 0
	CALL SEND_LCD_DATA
	MOVF R2_C3, 0
	CALL SEND_LCD_DATA
	MOVF R2_C4, 0
	CALL SEND_LCD_DATA
	MOVF R2_C5, 0
	CALL SEND_LCD_DATA
	MOVLW 0x0E
	CALL SEND_LCD_COMMAND
	MOVLW 0xC5
	MOVWF CURSOR
	CALL SEND_LCD_COMMAND
	CALL RESET_TIMER
	GOTO INTERUPT_END
INTITIAL_MESSAGE:
	BANKSEL INTCON
	BCF INTCON, GIE
	BANKSEL PORTA
	MOVLW 0x01
	CALL SEND_LCD_COMMAND
	MOVLW 0x80
	CALL SEND_LCD_COMMAND
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
	MOVLW 'O'
	CALL SEND_LCD_DATA
	MOVLW 'P'
	CALL SEND_LCD_DATA
	MOVLW 'E'
	CALL SEND_LCD_DATA
	MOVLW 'R'
	CALL SEND_LCD_DATA
	MOVLW 'A'
	CALL SEND_LCD_DATA
	MOVLW 'T'
	CALL SEND_LCD_DATA
	MOVLW 'I'
	CALL SEND_LCD_DATA
	MOVLW 'O'
	CALL SEND_LCD_DATA
	MOVLW 'N'
	CALL SEND_LCD_DATA
	MOVLW ':'
	CALL SEND_LCD_DATA
	MOVLW 0xC0
	MOVWF CURSOR
	CALL SEND_LCD_COMMAND
	MOVLW '0'
	CALL SEND_LCD_DATA
	MOVLW '0'
	CALL SEND_LCD_DATA
	MOVLW '0'
	CALL SEND_LCD_DATA
	MOVLW '0'
	CALL SEND_LCD_DATA
	MOVLW '0'
	CALL SEND_LCD_DATA
	MOVLW '+'
	CALL SEND_LCD_DATA
	MOVLW '0'
	CALL SEND_LCD_DATA
	MOVLW '0'
	CALL SEND_LCD_DATA
	MOVLW '0'
	CALL SEND_LCD_DATA
	MOVLW '0'
	CALL SEND_LCD_DATA
	MOVLW '0'
	CALL SEND_LCD_DATA
	MOVF CURSOR, 0
	CALL SEND_LCD_COMMAND
	MOVLW 0x0E
	CALL SEND_LCD_COMMAND
	BANKSEL INTCON
	BSF INTCON, GIE
	BANKSEL PORTA
	RETURN
; ==========================================================================
;							NUMBERS & CONVERSIONS
;											  
; ===========================================================================

HexBCD: 
	movlw d'16'			; Set the counter to 16
	movwf MCount 		; Move the counter to MCount
	clrf BCDvalH 		; Clear the BCD value's Most Significant Byte
	clrf BCDvalM		; Clear the BCD value's Middle Significant Byte
	clrf BCDvalL		; Clear the BCD value's Least Significant Byte
	bcf STATUS,C 		; Clear the carry bit

loop16:  
	rlf RESULT_LSB,F 	;
	rlf RESULT_MSB,F
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
	RETURN

dec2bin16
    movf  C4,W        ; (C4 + C2) * 2
    addwf C2,W
    movwf NUMLO
    rlf   NUMLO,F

    swapf C3,W        ; + C3 * 16 + C3
    addwf C3,W
    addwf NUMLO,F

    rlf   C1,W        ; + (C1 * 2 + C2) * 256
    addwf C2,W
    movwf NUMHI

    rlf   NUMLO,F     ; * 2
    rlf   NUMHI,F

    swapf C2,W        ; - C2 * 16
    subwf NUMLO,F
    skpc
    decf  NUMHI,F

    swapf C3,W        ; + C3 * 16 + C4
    addwf C4,W
    addwf NUMLO,F
    skpnc
    incf  NUMHI,F

    swapf C1,W        ; + C1 * 16 + C5
    addwf C5,W

    rlf   NUMLO,F     ; * 2
    rlf   NUMHI,F

    addwf NUMLO,F
    skpnc
    incf  NUMHI,F

    movf  C1,W        ; - C1 * 256
    subwf NUMHI,F

    swapf C1,W        ; + C1 * 16 * 256 * 2
    addwf NUMHI,F
    addwf NUMHI,F

    return            ; Q.E.D.


; ==========================================================================
;						ARETHMETIC OPERATIONS 
;											  
; ===========================================================================
ADD:
	CLRF RESULT_LSB       ; Clear the result's Least Significant Byte
	CLRF RESULT_MSB       ; Clear the result's Most Significant Byte
	CLRF CARRY_SAVED		;
	MOVF R1_LSB, 0        ; Move the value in R1_LSB to W register
	ADDWF R2_LSB, 0       ; Add the value in W to R2_LSB (result in R2_LSB with no carry)
	BTFSC STATUS, 0       ; Check if there was a carry from the previous addition
	INCF RESULT_MSB       ; If carry, increment the result's Most Significant Byte
	MOVWF RESULT_LSB      ; Move the result of addition to the result's Least Significant Byte
	MOVF R1_MSB, 0        ; Move the value in R1_MSB to W register
	ADDWF R2_MSB, 0       ; Add the value in W to R2_MSB (result in R2_MSB with carry)
	BTFSC STATUS, 0       ; Check if there was a carry from the previous addition
	BSF CARRY_SAVED, 0
	ADDWF RESULT_MSB      ; Add the result of addition to the result's Most Significant Byte
	BTFSC STATUS, 0       ; Check if there was a carry from the previous addition
	BSF CARRY_SAVED, 0
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
	CLRF RESULT_MSB      	; Clear the result's Most Significant Byte
	CLRF RESULT_LSB      	; Clear the result's Least Significant Byte
	CLRF CARRY_SAVED
	MOVF R1_LSB, 0       	; Move the value in R1_LSB to TEMP_LSB (temporary storage)
	MOVWF TEMP_LSB
	MOVF R1_MSB, 0       	; Move the value in R1_MSB to TEMP_MSB (temporary storage)
	MOVWF TEMP_MSB
	MOVF R2_LSB, 0        	; Move the value in R2_LSB to W register
	BTFSC STATUS, Z	   		; Check if the divisor is 0
	GOTO UPPER_BITS 	; If it is, check the upper bits
	GOTO DIVLOOP          	; If it isn't, continue the division loop
UPPER_BITS:
	MOVF R2_MSB, 0        ; Move the value in R2_MSB to W register
	BTFSC STATUS, Z       ; Check if the divisor is 0
	GOTO DIVEND           ; If it is, exit the loop (division complete)
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
	MOVF R2_LSB, 0        	; Move the value in R2_LSB to W register
	BTFSC STATUS, Z	   		; Check if the divisor is 0
	GOTO UPPER_BITS_M 	; If it is, check the upper bits
	GOTO MODLOOP          	; If it isn't, continue the division loop
UPPER_BITS_M:
	MOVF R2_MSB, 0        ; Move the value in R2_MSB to W register
	BTFSC STATUS, Z       ; Check if the divisor is 0
	GOTO MODEND           ; If it is, exit the loop (division complete)
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
NORMALIZE_NUMBER:
	MOVLW 6
	ADDWF DIGIT1, 0
	MOVWF DIGIT1
	SUBLW 0x39			; CHECK IF IT HAS EXCEEDED '9'
	BTFSC STATUS, 0		; NUMBER IS NEGATIVE
	GOTO NORMALIZE_NUMBER_2
	MOVLW D'10'
	SUBWF DIGIT1, 1
	INCF DIGIT2
NORMALIZE_NUMBER_2:
	MOVLW 3
	ADDWF DIGIT2, 0
	MOVWF DIGIT2
	SUBLW 0x39		; CHECK IF IT HAS EXCEEDED '9'
	BTFSC STATUS, 0		; NUMBER IS NEGATIVE
	GOTO NORMALIZE_NUMBER_3
	MOVLW D'10'
	SUBWF DIGIT2, 1
	INCF DIGIT3
NORMALIZE_NUMBER_3:
	MOVLW 5
	ADDWF DIGIT3, 0
	MOVWF DIGIT3
	SUBLW 0x39			; CHECK IF IT HAS EXCEEDED '9'
	BTFSC STATUS, 0		; NUMBER IS NEGATIVE
	GOTO NORMALIZE_NUMBER_4
	MOVLW D'10'
	SUBWF DIGIT3, 1
	INCF DIGIT4
NORMALIZE_NUMBER_4:
	MOVLW 5
	ADDWF DIGIT4, 0
	MOVWF DIGIT4
	SUBLW 0x39			; CHECK IF IT HAS EXCEEDED '9'
	BTFSC STATUS, 0		; NUMBER IS NEGATIVE
	GOTO NORMALIZE_NUMBER_5
	MOVLW D'10'
	SUBWF DIGIT4, 1
	INCF DIGIT5
NORMALIZE_NUMBER_5:
	MOVLW 6
	ADDWF DIGIT5, 0
	MOVWF DIGIT5
	SUBLW 0x39			; CHECK IF IT HAS EXCEEDED '9'
	BTFSC STATUS, 0		; NUMBER IS NEGATIVE
	GOTO NORMALIZE_NUMBER_6
	MOVLW D'10'	
	SUBWF DIGIT5, 1
	INCF DIGIT6
NORMALIZE_NUMBER_6:
	RETURN
loop:
	GOTO loop
	END                  ; End of the progra