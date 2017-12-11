;
; lab03C.asm
;
; Created: 2017/9/13 1:58:39
; Author : LI JINGCHENG
;

 .include "m2560def.inc"

 .def time = r16
 .def i = r17
 .def j = r18
 .def k = r19
 .def n = r20
 .def second = r21
 .def minute = r22

 .cseg


clr time; 
out PORTC, time		; Write zeros to all the LEDs
out DDRC, time		; PORTC is all outputs

clr second
clr minute

main:
	
clr i
clr j
clr k
clr n
;use software delay to count seconds
first_delay:

clr j
inc i
cpi i, 100
breq increment

second_delay:

clr k
inc j
cpi j, 100
breq first_delay

third_delay:

clr n
inc k
cpi k, 80
breq second_delay

fourth_delay:

cpi n, 2
breq third_delay
nop
inc n
rjmp fourth_delay

increment:		;plus one second after 16,000,000 cycles

inc second
cpi second, 60
breq increminute
rjmp timeset

increminute:	;plus one minute after 60 seconds

clr second
inc minute
cpi minute, 4
breq reset
rjmp timeset

reset:			;reset the clock if 4 minutes pass

clr minute
rjmp timeset


timeset:		;set time to output

mov time, minute
lsl time        ;shift minute 6 times, LED 7&8 represent minutes
lsl time
lsl time
lsl time
lsl time
lsl time
or time, second ;use bit or to add minute and second together

out PORTC, time ;write time to all LEDs
rjmp main