PROCESSOR 16F877A
INCLUDE "p16f877a.inc"


__CONFIG 0x3731 ;
; ---------------------------------
; ----------- Data Area -----------
; ---------------------------------
R1_LSB EQU 0x20
R1_MSB EQU 0x21
R2_LSB EQU 0x22
R2_MSB EQU 0x23
TEMP_LSB EQU 0x24
TEMP_MSB EQU 0x25
RESULT_LSB EQU 0x26
RESULT_MSB EQU 0x27
TEMP_W EQU 0x28
; ---------------------------------
; ----------- Code Area -----------
; ---------------------------------
	ORG 0x00
	NOP
	GOTO INIT

	ORG 0x04
	GOTO ISR

ISR: 
	NOP
	retfie

INIT:
	CLRF  R1_LSB 
	CLRF R1_MSB 
	CLRF R2_LSB 
	CLRF R2_MSB 
	CLRF TEMP_LSB 
	CLRF TEMP_MSB 
	CLRF TEMP_W 
	CLRW
START: 
	MOVLW 0xff
	MOVWF R1_LSB
	MOVWF R2_LSB
	MOVLW 0x0f
	MOVWF R1_MSB
	MOVWF R2_MSB
	CALL ADD
	GOTO loop

ADD:
	CLRF RESULT_LSB
	CLRF RESULT_MSB
	MOVF R1_LSB, 0
	ADDWF R2_LSB, 0
	BTFSC STATUS, 0
	INCF RESULT_MSB
	MOVWF RESULT_LSB
	MOVF R1_MSB, 0
	ADDWF R2_MSB, 0
	ADDWF RESULT_MSB
	RETURN

loop:
	GOTO loop

	END