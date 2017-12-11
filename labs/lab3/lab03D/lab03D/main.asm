;
; lab03D.asm
;
; Created: 2017/9/14 23:15:41
; Author : LI JINGCHENG
;


; Replace with your application code
.include "m2560def.inc"

.def temp = r17
.def time = r18
.def second = r20					; stores an LED pattern
.def minute = r19


.macro clear
ldi YL, low(@0)						; load the memory address to Y pointer
ldi YH, high(@0)
clr temp							; set temp to 0
st Y+, temp							; clear the two bytes at @0 in SRAM
st Y, temp
.endmacro 


.dseg


TempCounter: .byte 2				; temporary counter used to determine if one second has passed

.cseg 


.org 0x0000
jmp RESET 
.org OVF0addr						; OVF0addr is the address of Timer0 Overflow Interrupt Vector
jmp Timer0OVF						; jump to the intterupt handler for Timer0 overflow
 
RESET: 

ldi temp, low(RAMEND)				; initialize the stack pointer SP
out SPL, temp 
ldi temp, high(RAMEND) 
out SPH, temp 
ser temp							; set Port C as output
out DDRC, temp 
clr minute
rjmp main							; jump to main program

Timer0OVF:							;intterupt subroutine to Timer0
in temp, SREG
push temp							; prologue starts
push YH								; save all conflicting registers
push YL
push r25
push r24							; prologue ends
									; Load the value of the temporary counter
lds r24, TempCounter
lds r25, TempCounter+1
adiw r25:r24, 1						; increase the temporary counter by 1
cpi r24, low(7812)					; check if r25:r24 = 7812
ldi temp, high(7812)				; 7812 = 106/128
cpc r25, temp
brne NotSecond

inc second							; one second has passed, plus one second
cpi second, 60
breq inceminute
rjmp timeset

NotSecond:							;store the new value of the temporary counter

sts TempCounter, r24
sts TempCounter+1, r25

EndIF:

pop r24								; epilogue starts
pop r25								; restore all conflicting registers from the stack
pop YL
pop YH
pop temp
out SREG, temp
reti								; return from the interrupt

timeset:							;set time to output

mov time, minute
lsl time							;shift minute 6 times, LED 6&7 represent minutes
lsl time
lsl time
lsl time
lsl time
lsl time
OR time, second						;use bit or to add minute and second together
out PORTC, time						;write time to all LEDs

clear TempCounter				; reset the temporary counter
rjmp EndIF


inceminute:							;plus one minute after 60 seconds

clr second
inc minute
cpi minute, 4
breq timereset
rjmp timeset

timereset:							;reset the clock if 4 minutes pass

clr minute
rjmp timeset


main:

ldi second, 0x00					; main program starts here
out PORTC, second					; set all LEDs off at the beginning
clear TempCounter				; initialise counter to 0;

ldi temp, 0b00000000
out TCCR0A, temp
ldi temp, 0b00000010
out TCCR0B, temp					; set prescalar value to 8;
ldi temp, 1<<TOIE0					; TOIE0 is the bit number of TOIE which is 0
sts TIMSK0, temp					; enable Timer0 Overfflow interrupt
sei									; enable global interrupt

end:
rjmp end			
