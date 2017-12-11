;
; lab03A.asm
;
; Created: 2017/9/13 14:24:50
; Author : LI JINGCHENG
;

; Replace with your application code


.include "m2560def.inc"

 .def temp = r16
 .def result = r17

 .equ PATTERN1 = 0x00
 .equ PATTERN2 = 0b00001111
 .def i = r21
 .def j = r18
 .def k = r19
 .def n = r20
 ldi result,PATTERN2

 .cseg

 ser temp
 out PORTC, temp	; Write ones to all the LEDs
 out DDRC, temp		; PORTC is all outputs
 out PORTF, temp	; Enable pull-up resistors on PORTF
  out PORTC, temp
 clr temp
 out DDRF, temp		; PORTF is all inputs

 
switch0:
sbic PINF,0			; Skip the next instruction if PB0 is pushed
rjmp switch1	
clr i
clr j
clr k
clr n
rjmp first_delay0

continue0:			;if result is 0x00, convert it to 0xff
cpi result,PATTERN1
breq less
dec result
out PORTC,result

rjmp switch1		; If not pushed, check the other switch

less:
ldi result,PATTERN2
out PORTC,result

switch1:
sbic PINF,1
rjmp switch0
clr i
clr j
clr k
clr n
rjmp first_delay1

continue1:		;if result is 0xff, convert it to 0x00
cpi result,PATTERN2
breq over
inc result
out PORTC,result
rjmp switch0		; If not pushed, check the other switch

over:
clr result
out PORTC,result
rjmp switch0		; Now check PB0 again



first_delay0: 
	clr j
	inc i
	cpi i, 100
	breq finish_delay0
second_delay0:
	clr k
	inc j
	cpi j, 50
	breq first_delay0
third_delay0:
	clr n
	inc k
	cpi k, 20
	breq second_delay0
fourth_delay0:
	cpi n, 8
	breq third_delay0
	nop
	inc n
	rjmp fourth_delay0
finish_delay0:
clr i
clr j
clr k
clr n
rjmp continue0


first_delay1: 
	clr j
	inc i;
	cpi i, 100
	breq finish_delay1
second_delay1:
	clr k
	inc j
	cpi j, 50
	breq first_delay1
third_delay1:
	clr n
	inc k
	cpi k, 20
	breq second_delay1
fourth_delay1:
	cpi n, 8
	breq third_delay1
	nop
	inc n
	rjmp fourth_delay1
finish_delay1:
clr i
clr j
clr k
clr n
rjmp continue1
