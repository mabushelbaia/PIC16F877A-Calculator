
PROCESSOR 16F877A
INCLUDE "p16f877a.inc"


__CONFIG 0x3731 ;
; ---------------------------------------------------
; ----------- Data Area -----------
; ---------------------------------------------------
R1_LSB EQU 0x20       ; Define the memory location for R1's Least Significant Byte
R1_MSB EQU 0x21       ; Define the memory location for R1's Most Significant Byte
R2_LSB EQU 0x22       ; Define the memory location for R2's Least Significant Byte
R2_MSB EQU 0x23       ; Define the memory location for R2's Most Significant Byte
TEMP_LSB EQU 0x24     ; Define the memory location for temporary storage (Least Significant Byte)
TEMP_MSB EQU 0x25     ; Define the memory location for temporary storage (Most Significant Byte)
RESULT_LSB EQU 0x26   ; Define the memory location for the result (Least Significant Byte)
RESULT_MSB EQU 0x27   ; Define the memory location for the result (Most Significant Byte)

TEMP_W EQU 0x28       ; Define the memory location for unused temporary storage (not used in this code)
; ---------------------------------------------------
; ----------- Code Area -----------
; ---------------------------------------------------

ORG 0x00              ; Set the program counter to address 0x00 (start of program)
NOP                   ; No operation (dummy instruction)
GOTO INIT             ; Jump to the initialization code

ORG 0x04              ; Set the program counter to address 0x04 (interrupt service routine)
GOTO ISR              ; Jump to the interrupt service routine

ISR: 
	NOP                   ; Interrupt service routine: No operation
	retfie                ; Return from interrupt

INIT:
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
	GOTO loop              ; Jump to the loop label

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
	CLRF RESULT_MSB       
	CLRF RESULT_LSB       
	MOVF R1_LSB, 0        
	MOVWF TEMP_LSB
	MOVF R1_MSB, 0        
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

	RETURN                ; Return from the MOD subroutine              

loop:
	END                  ; End of the program
