;
; lab05B.asm
;
; Created: 2017/10/10 12:48:13
; Author : LI JINGCHENG
;


; Replace with your application code

.def temp = r16
.def speed = r17
.def five = r18
.def flag = r19
.def a = r20
.def b = r21
.def c = r22

.dseg

.cseg 

.org 0x00 
jmp RESET 
.org INT0addr     
jmp EXT_INT0 
.org INT1addr    
jmp EXT_INT1 
.org 0x72


.macro delay

delay1: 
clr b
inc a
cpi a, 200
breq finish_delay
delay2:
clr c
inc b
cpi b, 100
breq delay1
delay3:
cpi c, 50
breq delay2
nop
inc c
rjmp delay3
finish_delay:
clr a
clr b
clr c

.endmacro

RESET:
ldi r16, low(RAMEND)
out SPL, r16
ldi r16, high(RAMEND)
out SPH, r16
	
	
ser temp
out DDRE, temp; set PORTE as output
;ldi temp, 0b00000100; this value and the operation mode determines the PWM duty cycle
ldi temp,0
sts OCR3BL, temp;OC3B low register
clr temp
sts OCR3BH, temp;0C3B high register
ldi temp, (1<<CS30) ; CS30 = 1: no prescaling
sts TCCR3B, temp; set the prescaling value
ldi temp, (1<<WGM30)|(1<<COM3B1)
; WGM30=1: phase correct PWM, 8 bits
;COM3B1=1: make OC3B override the normal port functionality of the I/O pin PE2
sts TCCR3A, temp
sei

ser temp 
out DDRC, temp 
clr temp 
out DDRD, temp 
out PORTD, temp 
ldi temp, (2 << ISC10) | (2 << ISC00);set for falling edge 
sts EICRA, temp 
in temp, EIMSK 
ori temp, (1<<INT0) | (1<<INT1) 
out EIMSK, temp 
sei 
ldi five,5
clr a
clr b
clr c
clr speed
ldi flag,200
	
jmp main 

EXT_INT0: 
push temp 
in temp, SREG 
push temp 
delay 

	
cpi speed, 100							; check if speed is already the max speed
breq max_speed

cp speed,flag
breq skip

add speed, five

out PORTC,speed
sts OCR3BL, speed						; OC3B low register
clr temp
sts OCR3BH, temp						; 0C3B high register 
add speed, five

out PORTC,speed
sts OCR3BL, speed						; OC3B low register
clr temp
sts OCR3BH, temp
add speed, five

out PORTC,speed
sts OCR3BL, speed						; OC3B low register
clr temp
sts OCR3BH, temp
add speed, five

out PORTC,speed
sts OCR3BL, speed						; OC3B low register
clr temp
sts OCR3BH, temp
mov flag,speed

ret_maxmin:
pop temp 
out SREG, temp 
pop temp 
reti 

max_speed:
ldi speed, 100
sts OCR3BL, speed						; this is the OC3B low register
clr temp
sts OCR3BH, temp						; this is the 0C3B high register
rjmp ret_maxmin




end:
ldi flag,200
rjmp main

skip:
ldi flag,200
rjmp ret_maxmin


main:
rjmp main

EXT_INT1: 
push temp 
in temp, SREG 
push temp 
delay


	
cpi speed, 0						; check if speed is already <20
breq min_speed
cp speed,flag
breq skip

sub speed, five
out PORTC,speed
sts OCR3BL, speed					; this is the OC3B low register
clr temp;
sts OCR3BH, temp					; this is the 0C3B high register

sub speed, five
out PORTC,speed
sts OCR3BL, speed					; this is the OC3B low register
clr temp;
sts OCR3BH, temp					; this is the 0C3B high register
sub speed, five
out PORTC,speed
sts OCR3BL, speed					; this is the OC3B low register
clr temp;
sts OCR3BH, temp					; this is the 0C3B high register
sub speed, five
out PORTC,speed
sts OCR3BL, speed					; this is the OC3B low register
clr temp;
sts OCR3BH, temp					; this is the 0C3B high register
mov flag,speed
rjmp ret_maxmin	

min_speed:
clr speed
sts OCR3BL, speed					; this is the OC3B low register
clr temp
sts OCR3BH, temp					; this is the 0C3B high register
rjmp ret_maxmin
	
