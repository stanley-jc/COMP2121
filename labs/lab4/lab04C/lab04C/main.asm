;
; lab04C.asm
;
; Created: 2017/10/3 0:06:00
; Author : LI JINGCHENG
;


; Replace with your application code

.include "m2560def.inc"


.def nletters = r3
.def flag = r4
.def next_state = r5
.def i = r6
.def j = r7
.def k = r8
.def a = r9
.def b = r10
.def c = r11
.def d = r12
.def e = r13
.def operator = r14
.def inv = r15
.def temp = r16
.def row =r17
.def col =r18
.def mask =r19
.def temp2 =r20
.def high_order_bit = r21
.def num2 = r22
.def lcd_result = r23
.equ PORTLDIR = 0xF0
.equ INITCOLMASK = 0xEF
.equ INITROWMASK = 0x01
.equ ROWMASK = 0x0F

.equ HOB_LABEL = 0b00100000		;high order bit for symbols
.equ HOB_NUM = 0b00110000		;high order bit for numbers

.dseg 
fir_num: .byte 2
sec_num: .byte 2
result: .byte 2

.cseg
.org 0x00
jmp RESET
.org 0x72


.macro do_lcd_command
	ldi r16, @0
	rcall lcd_command
	rcall lcd_wait
.endmacro


.macro do_lcd_data_k
	ldi r16, @0
	rcall lcd_data
	rcall lcd_wait
.endmacro

.macro do_lcd_data_r
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

.macro x10_add
ldi r30,low(@0)
ldi r31,high(@0)
ld a,Z
ldd b,Z+1
ldi temp2,10
mul a,c
mov i,r0
mov j,r1
mul b,c
adc j,r0

clr temp2
add i,@1
adc j,c
st Z,i
std Z+1,j 
.endmacro

.macro print_reg
jmp start_print
no_skip1:
rcall print_num
jmp start_loop2

no_skip2:
rcall print_num
jmp loop3
start_print:
ldi temp2,100
mov d,temp2
ldi temp2,0
mov c,@0

loop1:
sub c,d
inc temp2
cp c,d
brge loop1 

cpi temp2,0
brne no_skip1
mov c,@0

start_loop2:
ldi temp2,10
mov d,temp2
ldi temp2,0
loop2:
sub c,d
inc temp2
cp c,d
brge loop2

cpi temp2,0
brne no_skip2
mov c,@0

loop3:
mov temp2,c
rcall print_num
.endmacro



RESET:
;reset keypad
ldi temp, low(RAMEND)
out SPL, temp
ldi temp, high(RAMEND)
out SPH, temp
ldi temp, PORTLDIR ; columns are outputs, rows are inputs
STS DDRL, temp     ; cannot use out
ser temp
out DDRC, temp ; Make PORTC all outputs
clr temp;
out PORTC, temp ; Turn on all the LEDs
;reset lcd
ser temp
out DDRF, temp
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

clr nletters
clr lcd_result
clr i
clr j
clr k
clr num2
;clr overflow_flag;
;Setup the parameters for the debouncing sleep as [250, 150, 10].

rjmp main

main:
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
;jmp Initialise_keypad
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
	push r24
	push r25
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
	mov lcd_result, temp; store the value into lcd output register
	ldi high_order_bit, HOB_NUM;
	or lcd_result, high_order_bit; OR the high order bit with the value for outputting to lcd.
	cpi num2, 0; check if we have a current operator, if so, use exp2
	ldi temp2,0
	mov inv,temp2
	brne second_number
	x10_add fir_num, temp
	
	jmp convert_end

second_number:
	x10_add sec_num, temp
	jmp convert_end
symbols:
	
	cpi col, 1 ;if we have zero
	breq zero
	ret
letters:
	
	ldi temp, 0xA
	add temp, row
	cpi temp, 0xA
	breq a_plus
	cpi temp, 0xB
	breq b_minus
	cpi temp, 0xC
	breq c_equal
	ret

	a_plus:
	ldi temp2,1
	mov inv,temp2
	ldi lcd_result, 13; else if A, load with 13 to make it '-' 
	mov operator,lcd_result
	ldi high_order_bit, HOB_LABEL
	or lcd_result, high_order_bit
	ldi num2,1
	jmp convert_end

	b_minus:
	ldi temp2,1
	mov inv,temp2
	ldi lcd_result, 11
	mov operator,lcd_result
	ldi high_order_bit, HOB_LABEL; need 0010 high nibble for '+'
	or lcd_result, high_order_bit; OR the high order bit with the value for outputting to lcd.
	ldi num2,1
	jmp convert_end


	c_equal:
	ldi lcd_result, 13
	ldi high_order_bit, HOB_NUM; need 0011 high nibble for '='
	or lcd_result, high_order_bit; OR the high order bit with the value for outputting to lcd.
	ldi num2,1
	jmp calculation
	

	zero:
	ldi temp2,0
	mov inv,temp2
	clr temp ; set to zero
	mov lcd_result, temp;
	ldi high_order_bit, HOB_NUM;
	or lcd_result, high_order_bit;
	cpi num2,0; check if we have a current operator, if so, use exp2

	brne second_number
	x10_add fir_num, temp
	jmp convert_end



convert_end:
	LDS flag, PINL
	rcall next_line
	do_lcd_data_r lcd_result; output the value to the LCD
	inc nletters; increment the counter for how many chars have been written
preserve:
	LDS temp, PINL ; read PORTL. Cannot use in 
	cp temp, flag
	breq preserve
	pop r25
	pop r24
	ret ; return to caller

calculation:
ldi temp2,1
cp inv,temp2
breq invalid
ldi temp2,11
cp operator,temp2
breq plus
ldi temp2,13
cp operator,temp2
breq minus
jmp convert_end
plus:
ldi r28, low(fir_num)
ldi r29, high(fir_num)
ldi r30, low(sec_num)
ldi r31, high(sec_num)

ld a, Z
ldd b, Z+1
ld i, Y
ldd j, Y+1
add i,a
adc j,b
st Y,i
std Y+1,j
ldi r30, low(result)
ldi r31, high(result)
st Z,i
std Z+1,j
rjmp end_calculation

minus:
ldi r28, low(fir_num)
ldi r29, high(fir_num)
ldi r30, low(sec_num)
ldi r31, high(sec_num)

ld a, Z
ldd b, Z+1
ld i, Y
ldd j, Y+1
sub i,a
sbc j,b
st Y,i
std Y+1,j
ldi r30, low(result)
ldi r31, high(result)
st Z,i
std Z+1,j
rjmp end_calculation
invalid:
rcall next_line
do_lcd_data_k '='
inc nletters
rcall next_line
do_lcd_data_k 'i'
inc nletters
rcall next_line
do_lcd_data_k 'c'
inc nletters
rcall next_line
do_lcd_data_k 'o'
inc nletters
rcall next_line
do_lcd_data_k 'r'
inc nletters
rcall next_line
do_lcd_data_k 'r'
inc nletters
rcall next_line
do_lcd_data_k 'e'
inc nletters
rcall next_line
do_lcd_data_k 'c'
inc nletters
rcall next_line
do_lcd_data_k 't'
inc nletters
rcall next_line
do_lcd_data_k 'e'
inc nletters
rcall next_line
do_lcd_data_k 'x'
inc nletters
rcall next_line
do_lcd_data_k 'p'
inc nletters
rcall next_line
do_lcd_data_k 'r'
inc nletters
rcall next_line
do_lcd_data_k 'e'
inc nletters
rcall next_line
do_lcd_data_k 's'
inc nletters
rcall next_line
do_lcd_data_k 's'
inc nletters
rcall next_line
do_lcd_data_k 'i'
inc nletters
rcall next_line
do_lcd_data_k 'o'
inc nletters
rcall next_line
do_lcd_data_k 'n'
inc nletters
rjmp loop



end_calculation:
;ldi r30, low(sec_num)
;ldi r31, high(sec_num)
;clr a
;st Z,a
;std Z+1,a
rcall next_line
do_lcd_data_k '='
inc nletters
print_result:
ldi r30, low(result)
ldi r31, high(result)
ld a, Z
ldd b, Z+1
ldi temp2,0
print_reg a
print_reg b
rjmp loop


print_num:
rcall next_line
mov lcd_result, temp2; store the value into lcd output register
ldi high_order_bit, HOB_NUM;
or lcd_result, high_order_bit; OR the high order bit with the value for outputting to lcd.
do_lcd_data_r lcd_result; output the value to the LCD
inc nletters
ret




next_line:
ldi temp2,16
cp nletters,temp2
breq go_next
ldi temp2,32
cp nletters,temp2
breq go_first
ret
go_next:
lcd_clr LCD_RS
lcd_clr LCD_RW
do_lcd_command 0b11000000
ret
go_first:
lcd_clr LCD_RS
lcd_clr LCD_RW
do_lcd_command 0b00000001
clr nletters
ret
 ;LCD MACRO AND OTHER FUNCTIONS
.equ LCD_RS = 7
.equ LCD_E = 6
.equ LCD_RW = 5
.equ LCD_BE = 4


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

loop:
rjmp loop