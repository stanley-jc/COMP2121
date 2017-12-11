;
; lab03B.asm
;
; Created: 2017/9/15 14:24:50
; Author : LI JINGCHENG
;


; Replace with your application code



.include "m2560def.inc" 
.def temp = r16
.def i = r17
.def j = r18
.def k = r19
.def n = r20

.cseg 
.org 0x0 
jmp RESET 
.org INT0addr    ; INT0addr is the address of EXT_INT0  
jmp EXT_INT0 
.org INT1addr    ; INT1addr is the address of EXT_INT1 
jmp EXT_INT1 
 
RESET: 

ldi temp, low(RAMEND) ;let the stack pointer point to the starting address
out SPL, temp 
ldi temp, high(RAMEND) 
out SPH, temp
 
ser temp 
out PORTC, temp 
out DDRC, temp	; Write ones to all the LEDs

out PORTD, temp ;PORTD isall inputs
clr temp 
out DDRD, temp 



ldi temp, (1 << ISC01) | (1 << ISC11); set the falling edge mode 
sts EICRA, temp 

in temp, EIMSK ;choose the right INT
ori temp, (1<<INT0) | (1<<INT1) 
out EIMSK, temp 
sei				;enable global interrupt
jmp main 
 
EXT_INT0: 
push temp 
in temp, SREG	;get value from the status register
push temp 

in temp, PORTC; 
dec temp;
out PORTC, temp 

pop temp 
out SREG, temp	;set value
pop temp 

rjmp first_delay0
 
EXT_INT1: 

push temp 
in temp, SREG	;get value from the status register
push temp 

in temp, PORTC
inc temp		;set value
out PORTC, temp 

pop temp 
out SREG, temp 
pop temp 

rjmp first_delay0
 
 
main:                   
	rjmp main 

first_delay0: 
	clr j;
	inc i; 
	cpi i, 100;
	breq finish_delay0
second_delay0:
	clr k;
	inc j;
	cpi j, 100;
	breq first_delay0;
third_delay0:
	clr n;
	inc k;
	cpi k, 100;
	breq second_delay0
fourth_delay0:
	cpi n, 8;
	breq third_delay0
	nop;
	inc n;
	rjmp fourth_delay0;
finish_delay0:
clr i;
clr j;
clr k;
clr n;
reti