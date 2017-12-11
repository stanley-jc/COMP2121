;
; lab04A.asm
;
; Created: 9/18/2017 10:50:28 AM
; Author : LI JINGCHENG
;


.include "m2560def.inc"


.def temp =r16
.def second1 = r17			
.def second2 = r18
.def minute1 = r19
.def minute2 = r20
.def colon = r22
.equ LCD_RS = 7
.equ LCD_E = 6
.equ LCD_RW = 5
.equ LCD_BE = 4
;.equ HOB_NUM = 0b00110000		;high order bit for numbers


.macro clear
ldi YL, low(@0)						; load the memory address to Y pointer
ldi YH, high(@0)
clr temp							; set temp to 0
st Y+, temp							; clear the two bytes at @0 in SRAM
st Y, temp
.endmacro 

.macro do_lcd_command
ldi r16, @0
rcall lcd_command
rcall lcd_wait
.endmacro

.macro do_lcd_data
mov r16, @0
rcall lcd_data
rcall lcd_wait
.endmacro

.macro lcd_set
sbi PORTA, @0
.endmacro

.macro lcd_clr
cbi PORTA, @0
.endmacro

.dseg


TempCounter: .byte 2				; temporary counter used to determine if one second has passed

.cseg
.org 0x0000
ldi colon,0b00111010
ldi second1,0b00110000
ldi second2,0b00110000
ldi minute1,0b00110000
ldi minute2,0b00110000
jmp RESET
.org OVF0addr						; OVF0addr is the address of Timer0 Overflow Interrupt Vector
jmp Timer0OVF						; jump to the intterupt handler for Timer0 overflow

RESET:
ldi temp, low(RAMEND)				; initialize the stack pointer SP
out SPL, temp
ldi temp, high(RAMEND)
out SPH, temp


ser temp
out DDRF, temp			;set A&F as outputs
out DDRA, temp
clr temp
out PORTF, temp
out PORTA, temp

do_lcd_command 0b00111000 ; 2x5x7
rcall sleep_5ms
do_lcd_command 0b00111000 ; 2x5x7
rcall sleep_1ms
do_lcd_command 0b00111000 ; 2x5x7
do_lcd_command 0b00111000 ; 2x5x7
do_lcd_command 0b00001000 ; display off?
do_lcd_command 0b00000001 ; clear display
do_lcd_command 0b00000110 ; increment, no display shift
do_lcd_command 0b00001110 ; Cursor on, bar, no blink
do_lcd_command 0b00110000 ; sets a one line display.

do_lcd_data minute1
do_lcd_data minute2
do_lcd_data colon
do_lcd_data second1
do_lcd_data second2


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
cpi r24, low(781)					; check if r25:r24 = 7812
ldi temp, high(781)				; 7812 = 106/128
cpc r25, temp
brne NotSecond

inc second1							; one second has passed, plus one second
cpi second1, 0b00111010
breq incsec2
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
do_lcd_command 0b00000001			; clear display

do_lcd_data minute2
do_lcd_data minute1

do_lcd_data colon

do_lcd_data second2

do_lcd_data second1

clear TempCounter				; reset the temporary counter
rjmp EndIF

incsec2:						; ten seconds have passed
ldi second1,0b00110000
inc second2
cpi second2, 0b00110110
breq incmin1
rjmp timeset

incmin1:							;plus one minute after 60 seconds
ldi second2,0b00110000
inc minute1
cpi minute1, 0b00111010
breq incmin2
rjmp timeset

incmin2:	
									;plus one after 10 minutes passed
ldi minute1, 0b00110000
inc minute2
cpi minute2, 0b00110110
breq timereset
rjmp timeset

timereset:							;reset the clock if 60 minutes passed
ldi minute2,0b00110000

rjmp timeset

main:



clear TempCounter					; initialise counter to 0;

ldi temp, 0b00000000
out TCCR0A, temp
ldi temp, 0b00000010
out TCCR0B, temp					; set prescalar value to 8;
ldi temp, 1<<TOIE0					; TOIE0 is the bit number of TOIE which is 0
sts TIMSK0, temp					; enable Timer0 Overfflow interrupt
sei									; enable global interrupt


end:
rjmp end		



;
; Send a command to the LCD (r16)
;

lcd_command:
out PORTF, r16
nop
lcd_set LCD_E
nop
nop
nop
lcd_clr LCD_E
nop
nop
nop
ret

lcd_data:
out PORTF, r16
lcd_set LCD_RS
nop
nop
nop
lcd_set LCD_E
nop
nop
nop
lcd_clr LCD_E
nop
nop
nop
lcd_clr LCD_RS
ret

lcd_wait:
push r16
clr r16
out DDRF, r16
out PORTF, r16
lcd_set LCD_RW

lcd_wait_loop:
nop
lcd_set LCD_E
nop
nop
nop
in r16, PINF
lcd_clr LCD_E
sbrc r16, 7
rjmp lcd_wait_loop
lcd_clr LCD_RW
ser r16
out DDRF, r16
pop r16
ret

.equ F_CPU = 16000000
.equ DELAY_1MS = F_CPU / 4 / 1000 - 4
; 4 cycles per iteration - setup/call-return overhead

sleep_1ms:
push r24
push r25
ldi r25, high(DELAY_1MS)
ldi r24, low(DELAY_1MS)
delayloop_1ms:
sbiw r25:r24, 1
brne delayloop_1ms
pop r25
pop r24
ret

sleep_5ms:
rcall sleep_1ms
rcall sleep_1ms
rcall sleep_1ms
rcall sleep_1ms
rcall sleep_1ms
ret