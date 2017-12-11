;
; project.asm
;
; Created: 2017/10/15 20:11:06
; Author : LI JINGCHENG
;


; Replace with your application code



.include "m2560def.inc"
.def to_stop = r2
.def rolling = r3
.def speed = r4
.def to_stop2 = r5
.def need_stop = r6
.def index = r7
.def trans_time = r8
.def stop_time = r9
.def keys_entered = r10
.def stat_num = r11
.def stat_count = r12
.def step = r13
.def lcd_temp = r14
.def flag = r15				;use flag to store the result
.def temp = r16
.def row =r17
.def col =r18
.def mask =r19
.def temp2 =r20
.def stop_now = r21
.def Timertemp = r22
.def shift = r23

.equ PORTLDIR = 0xF0
.equ INITCOLMASK = 0xEF
.equ INITROWMASK = 0x01
.equ ROWMASK = 0x0F

.equ LCD_RS = 7
.equ LCD_E = 6
.equ LCD_RW = 5
.equ LCD_BE = 4
.equ HOB_LABEL = 0b00100000		;high order bit for symbols
.equ HOB_NUM = 0b00110000		;high order bit for numbers
.equ HOB_CHAR = 0b01000000		;high order bit for characters


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

.macro do_lcd_data_r
mov r16, @0
rcall lcd_data
rcall lcd_wait
.endmacro

.macro do_lcd_data_k
ldi r16, @0
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

name_list: .byte 100				;use 100 bytes to store the station names, 10 bytes for each one
time_list: .byte 10					;use 10 bytes to store the transfer time, 1 byte for each one
TempCounter: .byte 2





.cseg
jmp RESET
.org INT0addr     
jmp EXT_INT0 
.org INT1addr    
jmp EXT_INT1 
.org OVF0addr
jmp Timer0OVF						; jump to the interrupt handler for Timer0 overflow

;.org 0x72
RESET:
ldi temp, low(RAMEND)
out SPL, temp
ldi temp, high(RAMEND)
out SPH, temp
ldi temp, PORTLDIR 					; columns are outputs, rows are inputs
STS DDRL, temp     					; cannot use out
ser temp
out DDRC, temp 						; Make PORTC all outputs
clr temp
out PORTC, temp 					; Turn off all the LEDs

ser temp
out DDRF, temp						;set F&A as output
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
;set external interput
clr temp 
out DDRD, temp 
out PORTD, temp 
ldi temp, (2 << ISC10) | (2 << ISC00);set for falling edge 
sts EICRA, temp 
in temp, EIMSK 
ori temp, (1<<INT0) | (1<<INT1) 
out EIMSK, temp 
sei 




clr stat_num
clr stat_count
clr stop_time
clr need_stop
clr stop_now

clr step

ldi r30, low(name_list)
ldi r31, high(name_list)
ldi r26, low(time_list)
ldi r27, high(time_list)


rcall step0
rjmp main



;read the number of stations
step0:
do_lcd_command 0b00000001

do_lcd_data_k 'S'
do_lcd_data_k 'T'
do_lcd_data_k 'A'
do_lcd_data_k 'T'
do_lcd_data_k ' '
do_lcd_data_k 'N'
do_lcd_data_k 'U'
do_lcd_data_k 'M'
do_lcd_data_k ':'

ret

;external interupt0
EXT_INT0: 
push temp 
in temp, SREG 
push temp 
ldi temp2,1
mov to_stop,temp2
pop temp 
out SREG, temp 
pop temp 
reti 

;external interupt1
EXT_INT1: 
push temp 
in temp, SREG 
push temp 
ldi temp2,1
mov to_stop,temp2
pop temp 
out SREG, temp 
pop temp 
reti 




;read names of each station
step1:
inc stat_count

do_lcd_command 0b00000001

/*ld lcd_temp, Z+
do_lcd_data_r lcd_temp
ld lcd_temp, Z+
do_lcd_data_r lcd_temp
ld lcd_temp, Z+
do_lcd_data_r lcd_temp
ld lcd_temp, Z+
do_lcd_data_r lcd_temp
ld lcd_temp, Z+
do_lcd_data_r lcd_temp

ld lcd_temp, Z+
do_lcd_data_r lcd_temp
ld lcd_temp, Z+
do_lcd_data_r lcd_temp
ld lcd_temp, Z+
do_lcd_data_r lcd_temp
ld lcd_temp, Z+
do_lcd_data_r lcd_temp
ld lcd_temp, Z+
do_lcd_data_r lcd_temp
*/
/*dec index
mov lcd_temp, index
ldi temp2, HOB_NUM
or lcd_temp, temp2						
do_lcd_data_r lcd_temp*/

mov lcd_temp, stat_count
ldi temp2, HOB_NUM
or lcd_temp, temp2							; OR the high order bit with the value for outputting to lcd.
do_lcd_data_k 'S'
ldi temp2,10
cp stat_count,temp2
breq print_ten3
do_lcd_data_r lcd_temp
back_from_future:
do_lcd_data_k ' '
;do_lcd_data_k 'N'
;do_lcd_data_k 'A'
;do_lcd_data_k 'M'
;do_lcd_data_k 'E'
;do_lcd_data_k ':'
clr index
ret

print_ten3:
do_lcd_data_k '1'
do_lcd_data_k '0'
jmp back_from_future

;start to save the transfer time
step2:
inc stat_count
do_lcd_command 0b00000001
mov lcd_temp, stat_count
ldi temp2, HOB_NUM
or lcd_temp, temp2							; OR the high order bit with the value for outputting to lcd.
do_lcd_data_k 'S'
ldi temp2,10
cp stat_count,temp2
breq print_ten1
do_lcd_data_r lcd_temp
back_from_fir_arg:
do_lcd_data_k ' '
do_lcd_data_k 'T'
do_lcd_data_k 'O'
do_lcd_data_k ' '
do_lcd_data_k 'S'
ldi temp2,9
cp stat_count,temp2
breq print_ten2
cp stat_count,stat_num
breq back_to_one
inc lcd_temp
do_lcd_data_r lcd_temp
back_from_sec_arg:
do_lcd_data_k ' '
ret
back_to_one:
do_lcd_data_k '1'
do_lcd_data_k ' '
ret

print_ten1:
do_lcd_data_k '1'
do_lcd_data_k '0'
jmp back_from_fir_arg
print_ten2:
do_lcd_data_k '1'
do_lcd_data_k '0'
jmp back_from_sec_arg

;store the stop time
step3:

do_lcd_command 0b00000001
/*
ldi r26, low(time_list)
ldi r27, high(time_list)
ld lcd_temp,  X+
ldi temp2, HOB_NUM
or lcd_temp, temp2
do_lcd_data_r lcd_temp
ld lcd_temp,  X+
ldi temp2, HOB_NUM
or lcd_temp, temp2
do_lcd_data_r lcd_temp
ld lcd_temp,  X+
ldi temp2, HOB_NUM
or lcd_temp, temp2
do_lcd_data_r lcd_temp
ld lcd_temp,  X+
ldi temp2, HOB_NUM
or lcd_temp, temp2
do_lcd_data_r lcd_temp
ld lcd_temp,  X+
ldi temp2, HOB_NUM
or lcd_temp, temp2
do_lcd_data_r lcd_temp
ldi r26, low(time_list)
ldi r27, high(time_list)
*/
do_lcd_data_k 'S'
do_lcd_data_k 'T'
do_lcd_data_k 'O'
do_lcd_data_k 'P'
do_lcd_data_k ' '
do_lcd_data_k 'T'
do_lcd_data_k 'I'
do_lcd_data_k 'M'
do_lcd_data_k 'E'
do_lcd_data_k ':'
;mov lcd_temp, step
;ldi temp2, HOB_NUM
;or lcd_temp, temp2
;do_lcd_data_r lcd_temp
ret


step4:

do_lcd_command 0b00000001

mov lcd_temp, stop_time
ldi temp, HOB_NUM
or lcd_temp, temp
do_lcd_data_r lcd_temp
;mov lcd_temp, step
;ldi temp, HOB_NUM
;or lcd_temp, temp
;do_lcd_data_r lcd_temp
do_lcd_data_k 'O'
do_lcd_data_k 'K'
do_lcd_data_k ' '
do_lcd_data_k 'W'
do_lcd_data_k 'A'
do_lcd_data_k 'I'
do_lcd_data_k 'T'

ret
to_for_ten:
jmp for_ten
to_back_ten:
jmp back_ten

;show the name of the next station
step5:

do_lcd_command 0b00000001


cp stat_count,stat_num
breq to_back_ten

back_from_ten:
ld lcd_temp,Z+
do_lcd_data_r lcd_temp
ld lcd_temp,Z+
do_lcd_data_r lcd_temp
ld lcd_temp,Z+
do_lcd_data_r lcd_temp
ld lcd_temp,Z+
do_lcd_data_r lcd_temp
ld lcd_temp,Z+
do_lcd_data_r lcd_temp

ld lcd_temp,Z+
do_lcd_data_r lcd_temp
ld lcd_temp,Z+
do_lcd_data_r lcd_temp
ld lcd_temp,Z+
do_lcd_data_r lcd_temp
ld lcd_temp,Z+
do_lcd_data_r lcd_temp
ld lcd_temp,Z+
do_lcd_data_r lcd_temp
ld lcd_temp, -Z
ld lcd_temp, -Z
ld lcd_temp, -Z
ld lcd_temp, -Z
ld lcd_temp, -Z

ld lcd_temp, -Z
ld lcd_temp, -Z
ld lcd_temp, -Z
ld lcd_temp, -Z
ld lcd_temp, -Z



ret
for_ten:
ld lcd_temp,Z+
ld lcd_temp,Z+
ld lcd_temp,Z+
ld lcd_temp,Z+
ld lcd_temp,Z+

ld lcd_temp,Z+
ld lcd_temp,Z+
ld lcd_temp,Z+
ld lcd_temp,Z+
ld lcd_temp,Z+
jmp back_from_ten

back_ten:
ldi r30, low(name_list)
ldi r31, high(name_list)
jmp back_from_ten

to_step0:
jmp step0
to_step1:
jmp step1
to_step2:
jmp step2
to_step3:
jmp step2
to_step4:
jmp step2


clear_display:
rcall sleep_5ms

do_lcd_command 0b00000001 ; clear display

rjmp end_clear

; main keeps scanning the keypad to find which key is pressed.
main:
rcall sleep_100ms
rcall sleep_100ms
rcall sleep_100ms

end_clear:

scan_start:
ldi mask, INITCOLMASK ; initial column mask
clr col ; initial column

colloop:
STS PORTL, mask ; set column to mask value
; (sets column 0 off)
ldi temp, 0xFF ; implement a delay so the
; hardware can stabilize

delay:
dec temp
brne delay
LDS temp, PINL ; read PORTL. Cannot use in 
andi temp, ROWMASK ; read only the row bits
cpi temp, 0xF ; check if any rows are grounded
breq nextcol ; if not go to the next column
ldi mask, INITROWMASK ; initialise row check
clr row ; initial row

rowloop:      
mov temp2, temp
and temp2, mask ; check masked bit
brne skipconv ; if the result is non-zero,
; we need to look again
rcall convert ; if bit is clear, convert the bitcode
jmp main ; and start again



skipconv:
inc row ; else move to the next row
lsl mask ; shift the mask to the next bit
jmp rowloop          

nextcol:     
cpi col, 3 ; check if we are on the last column
breq main ; if so, no buttons were pushed,
; so start again.

sec ; else shift the column mask:
; We must set the carry bit
rol mask ; and then rotate left by a bit,
; shifting the carry into
; bit zero. We need this to make
; sure all the rows have
; pull-up resistors
inc col ; increment column value
jmp colloop ; and check the next column
; convert function converts the row and column given to a
; binary number and also outputs the value to PORTC.
; Inputs come from registers row and col and output is in
; temp.

convert:
cpi col, 3 ; if column is 3 we have a letter
breq letters
cpi row, 3 ; if row is 3 we have a symbol or 0
breq symbols

mov temp, row ; otherwise we have a number (1-9)
lsl temp ; temp = row * 2
add temp, row ; temp = row * 3
add temp, col ; add the column address
; to get the offset from 1
inc temp ; add 1. Value of switch is
; row*3 + col + 1.

;store time
ldi temp2,0
cp step,temp2
breq to_num_key
ldi temp2,2
cp step,temp2
breq to_num_key
ldi temp2,3
cp step,temp2
breq to_num_key

ldi temp2,4
cp step,temp2
breq to_skip_key

cpi shift,0
breq to_skip_key
cpi temp,1
breq to_skip_key

cpi temp,7
breq to_normal_key
cpi temp,9
breq to_more_key

cpi shift,4
breq to_skip_key
cpi temp,8
breq to_more_key

jmp to_normal_key

symbols:
cpi col, 0 ; check if we have a star
breq to_star
cpi col, 1 ; or if we have zero
breq to_zero

; we'll process for hash
jmp store_next

letters:
ldi temp2,0
cp step,temp2
breq to_skip_key
ldi temp2,2
cp step,temp2
breq to_skip_key
ldi temp2,3
cp step,temp2
breq to_skip_key
ldi temp, 0x1
add temp, row ; increment from 0xA by the row value
mov shift, temp
ret

;after entering a character, store it into name list
end_key:

ldi temp2,10
cp index,temp2
brsh to_skip_key
mov lcd_temp, temp; store the value into lcd output register
ldi temp, HOB_CHAR
or lcd_temp, temp; OR the high order bit with the value for outputting to lcd.
st Z+,lcd_temp
inc index
clr shift
jmp convert_end

name_full:
clr index
jmp skip_key

to_num_key:
jmp num_key
to_more_key:
jmp more_key
to_normal_key:
jmp normal_key
to_skip_key:
jmp skip_key

;when we want the number on the key
num_key:

mov lcd_temp, temp; store the value into lcd output register
ldi temp2,0
cp step,temp2
breq set_stat_num

ldi temp2,2
cp step,temp2
breq set_trans_time


ldi temp2,3
cp step,temp2
breq set_stop_time
jmp to_skip_key


to_zero:
jmp zero
to_star:
jmp star


;branch to store the transfer time
set_trans_time:
ldi temp2,8
cp index,temp2
brsh to_skip_key
mov trans_time,temp
inc index
jmp set_lcd_num


;branch to store the stop time
set_stop_time:
ldi temp2,7
cp index,temp2
brsh to_skip_key
mov stop_time,temp
inc index
jmp set_lcd_num

;branch to store the station number
set_stat_num:
ldi temp2,8
cp index,temp2
brsh to_skip_key
mov stat_num,temp
inc index
jmp set_lcd_num

;convert the value into ascii code
set_lcd_num:
ldi temp, HOB_NUM
or lcd_temp, temp; OR the high order bit with the value for outputting to lcd.
clr shift

inc keys_entered
jmp convert_end

skip_key:
ret




;keys 2-6 and 8, with 3 characters on the key
normal_key:
subi temp,2
mov temp2,temp
lsl temp2
add temp,temp2
add temp,shift
inc keys_entered
rjmp end_key

;keys 7 and 9,with 4 characters on the key
more_key:
subi temp,2
mov temp2,temp
lsl temp2
add temp,temp2
add temp,shift
inc temp
inc keys_entered
rjmp end_key

to_set_stop_time:
jmp set_stop_time

;if star is entered, then a whitespace is stored
star:
;ldi temp, 0xE ; we'll output 0xE for star
;ldi temp, 0b00100000 ; we'll output 0xE for star
ldi temp2,0
cp step,temp2
breq skip_key
ldi temp2,2
cp step,temp2
breq skip_key
ldi temp2,3
cp step,temp2
breq skip_key
ldi temp, 0b00100000 ; we'll output 0xE for star
mov lcd_temp, temp;
st Z+,lcd_temp
inc index
clr shift
inc keys_entered
jmp convert_end

to_to_skip_key:
jmp skip_key

to_set_trans_time:
jmp set_trans_time

;when zero is pressed, zero is stored
zero:
ldi temp,0
mov lcd_temp, temp; store the value into lcd output register
ldi temp2,1
cp step,temp2
breq skip_key

ldi temp2,0
cp step,temp2
breq set_stat_num

ldi temp2,2
cp step,temp2
breq to_set_trans_time


ldi temp2,3
cp step,temp2
breq to_set_stop_time
jmp to_skip_key



convert_end:
LDS temp, PINL ; read PORTL. Cannot use in 
mov flag, temp
;out PORTC, temp ; write value to PORTC
do_lcd_data_r lcd_temp; output the value to the LCD
	
preserve:
rcall sleep_5ms
LDS temp, PINL ; read PORTL. Cannot use in 
cp temp, flag
breq preserve
ret ; return to caller

;if hash is pressed, check the step and do the following work
store_next:
ldi temp2,0
cp step,temp2
breq store_step0
ldi temp2,1
cp step,temp2
breq store_step1
ldi temp2,2
cp step,temp2
breq store_step2
ldi temp2,3
cp step,temp2
breq to_store_step3
ldi temp2,4
cp step,temp2
breq end_store_next
ldi temp2,5
cp step,temp2
breq to_store_step5



end_store_next:
clr keys_entered
ret

;store the station number, handle the error input
store_step0:
;ldi temp2,2
;cp keys_entered,temp2
;brsh error_step0

ldi temp2,0
cp keys_entered,temp2
breq error_step0
ldi temp2,0
cp stat_num,temp2
breq error_step0
ldi temp2,1
cp stat_num,temp2
breq error_step0

end_store_step0:
inc step
clr index
;mov lcd_temp, step
;ldi temp, HOB_NUM
;or lcd_temp, temp

rcall step1
;jmp convert_end

jmp end_store_next
error_step0:
ldi temp2,10
mov stat_num,temp2
jmp end_store_step0

to_store_step3:
jmp store_step3
to_store_step5:
jmp store_step5

;store the name of each station, handle the error input
store_step1:
ldi temp, 0b00100000
ldi temp2,10
cp index,temp2
breq full_name2
st Z+,temp
inc index
jmp store_step1

full_name2:
clr index
breq end_store_step10

end_store_step10:
;inc stat_count
cp stat_count,stat_num
brlt end_store_step11
inc step
clr stat_count

rcall step2
jmp end_store_next
end_store_step11:
;ld lcd_temp, -Z
;ld lcd_temp, -Z
;ld lcd_temp, -Z
;ld lcd_temp, -Z
;ld lcd_temp, -Z

;ld lcd_temp, -Z
;ld lcd_temp, -Z
;ld lcd_temp, -Z
;ld lcd_temp, -Z
;ld lcd_temp, -Z
rcall step1
jmp end_store_next

;store the transfer time of each station, handle the error input
store_step2:
;ldi temp2,2
;cp keys_entered,temp2
;brsh error_step2
ldi temp2,0
cp keys_entered,temp2
breq error_step2
ldi temp2,0
cp trans_time,temp2
breq error_step2


end_store_step20:
st X+,trans_time
;inc stat_count
clr index
cp stat_count,stat_num
brlt end_store_step21
inc step
clr stat_count
rcall step3
jmp end_store_next
end_store_step21:

rcall step2
jmp end_store_next

error_step2:
ldi temp2,10
mov trans_time,temp2
jmp end_store_step20



;store the stop time of each station, handle the error input
store_step3:
;ldi temp2,2
;cp keys_entered,temp2
;brsh higher_error_step3
ldi temp2,0
cp keys_entered,temp2
breq lower_error_step3

ldi temp2,0
cp stop_time,temp2
breq lower_error_step3

ldi temp2,1
cp stop_time,temp2
breq lower_error_step3

ldi temp2,6
cp stop_time,temp2
brsh higher_error_step3

end_store_step3:
clr index
inc step
clr keys_entered
rcall step4
rcall timer0_start

jmp end_store_next
lower_error_step3:
ldi temp2,2
mov stop_time,temp2
jmp end_store_step3

higher_error_step3:
ldi temp2,5
mov stop_time,temp2
jmp end_store_step3

;when the monorail is traveling, press hash to change the flag of immediately stop
store_step5:
rcall sleep_100ms
rcall sleep_100ms
rcall sleep_100ms
rcall sleep_100ms
ldi temp2,1
cp stop_now,temp2
breq change_stop_now
mov stop_now,temp2
ret
change_stop_now:
clr stop_now
clr to_stop
clr to_stop2
clr need_stop
ret




timer0_start:
clr keys_entered
ldi temp, 0b00000000
out TCCR0A, temp
ldi temp, 0b00000010
out TCCR0B, temp					; set prescalar value to 8
ldi temp, 1<<TOIE0					; TOIE0 is the bit number of TOIE which is 0
sts TIMSK0, temp					; enable Timer0 Overflow interrupt
sei									; enable global interrupt

ret

;2 leds will blink if needed
light:
ldi temp,0b00000011
out PORTC, temp
rcall sleep_5ms
jmp back_from_light

Timer0OVF:						;interrupt subroutine to Timer0
in Timertemp, SREG;
push Timertemp					; prologue starts
push YH							; save all conflicting registers
push YL
push r25
push r24						; prologue ends 
								; Load the value of the temporary counter

lds r24, TempCounter
lds r25, TempCounter+1
adiw r25:r24, 1					; increase the temporary counter by 1
ldi temp2,1
cp stop_now,temp2
breq go_stop 
back_from_stop:

ldi temp2,1
cp rolling,temp2
breq back_from_light

cpi r24,low(1)					;if the monorail stops, 2 leds will blink 3 times/s
ldi Timertemp,high(1)
cpc r25, Timertemp
breq light
cpi r24,low(2605)
ldi Timertemp,high(2605)
cpc r25, Timertemp
breq light
cpi r24,low(5208)
ldi Timertemp,high(5208)
cpc r25, Timertemp
breq light

back_from_light:
clr temp
out PORTC,temp
cpi r24, low(7812)				; check if TempCounter(r25:r24) = 7812
ldi Timertemp, high(7812)		; about 1s
cpc r25, Timertemp
brne NotSecond

ldi temp2,1
cp stop_now,temp2
breq return_from_op 

ldi temp2,4						;wait five seconds
cp step,temp2
breq wait_five
;;;;;;;;;;;;;;;;;;;;;;;

ldi temp2,1						;check if we need to stop at the next station
cp to_stop2,temp2
breq go_stop_time

ldi temp2,5						;if the monorail is traveling, print the name of the next station

cp step,temp2
breq print_station

;;;;;;;;;;;;;;;;;;;;;;;
return_from_op:

clear TempCounter
rjmp End_Timer0OVF

NotSecond:

sts TempCounter, r24
sts TempCounter+1, r25
End_Timer0OVF:
pop r24
pop r25
pop YL
pop YH
pop Timertemp
out SREG, Timertemp
reti								; return from the interrupt


go_stop_time:						;count the time when the monorail stops at the next station
rcall stop_rolling
inc keys_entered
cp keys_entered,stop_time
brlt return_from_op
clr to_stop
clr to_stop2
clr keys_entered
clr need_stop

go_stop:							;stop the motor
rcall stop_rolling
jmp back_from_stop

wait_five:
inc keys_entered
ldi temp2,4
cp keys_entered,temp2
brlt print_step4
inc step 
ldi r30, low(name_list)
ldi r31, high(name_list)
ldi r26, low(time_list)
ldi r27, high(time_list)
ld lcd_temp,Z+
ld lcd_temp,Z+
ld lcd_temp,Z+
ld lcd_temp,Z+
ld lcd_temp,Z+

ld lcd_temp,Z+
ld lcd_temp,Z+
ld lcd_temp,Z+
ld lcd_temp,Z+
ld lcd_temp,Z+
clr stat_count
clr keys_entered
ld trans_time, X+
;inc trans_time
inc stat_count
clr need_stop

jmp return_from_op

print_step4:
rcall step4
jmp return_from_op

print_station:
ldi temp2,1
cp stop_now,temp2
breq return_from_op
ldi temp2,1
cp need_stop,temp2
breq go_print
rcall start_rolling

go_print:
inc keys_entered
cp keys_entered,trans_time
brlt print_step5

										;check if we have got to the last station
cp stat_count,stat_num
brlt name_loop
CP stat_count,stat_num
breq reset_stat
reset_stat:

ldi r30, low(name_list)
ldi r31, high(name_list)
ldi r26, low(time_list)
ldi r27, high(time_list)
ld lcd_temp,Z+
ld lcd_temp,Z+
ld lcd_temp,Z+
ld lcd_temp,Z+
ld lcd_temp,Z+

ld lcd_temp,Z+
ld lcd_temp,Z+
ld lcd_temp,Z+
ld lcd_temp,Z+
ld lcd_temp,Z+
clr stat_count
inc stat_count
clr keys_entered
ld trans_time, X+
;inc trans_time
ldi temp2,1
cp to_stop,temp2
breq set_next_stop

jmp return_from_op

set_next_stop:
ldi temp2,1
mov to_stop2,temp2
jmp return_from_op


										;move to the next station
name_loop:
inc stat_count
clr keys_entered
ld trans_time, X+
rcall step5

ld lcd_temp,Z+
ld lcd_temp,Z+
ld lcd_temp,Z+
ld lcd_temp,Z+
ld lcd_temp,Z+

ld lcd_temp,Z+
ld lcd_temp,Z+
ld lcd_temp,Z+
ld lcd_temp,Z+
ld lcd_temp,Z+

ldi temp2,1
cp to_stop,temp2
breq set_next_stop
jmp return_from_op

print_step5:
rcall step5


jmp return_from_op

	
start_rolling:						;starts the motor

ldi temp2,1
mov need_stop,temp2
mov rolling,temp2
ldi temp2,60
mov speed, temp2
sts OCR3BL, speed

ret

stop_rolling:
ldi temp2,0
mov rolling,temp2
ldi temp2,0
mov speed, temp2
sts OCR3BL, speed
ret
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

sleep_20ms:
rcall sleep_5ms
rcall sleep_5ms
rcall sleep_5ms
rcall sleep_5ms
ret

sleep_100ms:
rcall sleep_20ms
rcall sleep_20ms
rcall sleep_20ms
rcall sleep_20ms
rcall sleep_20ms
ret