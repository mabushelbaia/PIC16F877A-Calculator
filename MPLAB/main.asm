
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
C2 EQU 0x30
C3 EQU 0x31
C4 EQU 0x32
C5 EQU 0x33
Timer1	EQU	70		
TimerX	EQU	71		
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
GOTO ISR              ; Jump to the interrupt service routine
ISR: 
	BANKSEL INTCON
	BCF INTCON, INTF
	BCF INTCON, INTE
	; Interrupt Here

	BANKSEL INTCON
	BSF INTCON, INTE
	BANKSEL PORTA
	retfie                ; Return from interrupt

INIT:
	MOVLW 0xC0
	MOVWF C1
	MOVLW 0xC1
	MOVWF C2
	MOVLW 0xC2
	MOVWF C3
	MOVLW 0xC3
	MOVWF C4
	MOVLW 0xC4
	MOVWF C5
	
	CALL INIT_DISPLAY
	CALL INTITIAL_MESSAGE
	CLRF  R1_LSB          ; Clear R1's Least Significant Byte (initialize to 0)
	CLRF R1_MSB           ; Clear R1's Most Significant Byte (initialize to 0)
	CLRF R2_LSB           ; Clear R2's Least Significant Byte (initialize to 0)
	CLRF R2_MSB           ; Clear R2's Most Significant Byte (initialize to 0)
	CLRF TEMP_LSB         ; Clear temporary storage (Least Significant Byte) (initialize to 0)
	CLRF TEMP_MSB         ; Clear temporary storage (Most Significant Byte) (initialize to 0)
	CLRF TEMP_W           ; Clear unused temporary storage (initialize to 0)
	CLRW                  ; Clear W register (working register) (initialize to 0)

START: 
	MOVLW 0x49             ; Load W register with the value 0x40
	MOVWF R1_LSB           ; Move the value in W to R1's Least Significant Byte
	MOVLW 0x06             ; Load W register with the value 0x06
	MOVWF R1_MSB           ; Move the value in W to R1's Most Significant Byte
	MOVLW 0xA            ; Load W register with the value 0x90
	MOVWF R2_LSB           ; Move the value in W to R2's Least Significant Byte
	MOVLW 0x0             ; Load W register with the value 0x01
	MOVWF R2_MSB           ; Move the value in W to R2's Most Significant Byte
	CALL MOD            ; Call the DIVIDE subroutine to perform division
	GOTO loop
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

	; CLEARING AND CONVERTING PORTA TO DIGITAL
	BANKSEL TRISA
	CLRF TRISA
	BANKSEL PORTA
	CLRF PORTA
	BANKSEL ADCON1
	MOVLW 0x06
	MOVWF ADCON1
	BANKSEL PORTA
	; ---------------------------------------
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
	MOVLW 0xf	; ENABLE BLINKING
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
	MOVF C1, 0
	CALL SEND_LCD_COMMAND
	RETURN

loop:
	SLEEP
	END                  ; End of the program
