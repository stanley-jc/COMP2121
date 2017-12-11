;
; LAB02B.asm
;
; Created: 2017/8/27 0:22:18
; Author : LI JINGCHENG
;


; Replace with your application code

.include "m2560def.inc"


.def ai = r11
.def result_low = r24
.def result_high = r25
.def one = r12
.def number = r13
.def pow = r14
.def ten = r15
.def three = r16
.def count = r17
.def i = r18
.def num_low = r19
.def num_high = r20
.def sum_low = r21
.def sum_mid = r22
.def sum_high = r23

.dseg

a: .byte 11


xg: .byte 1
ng: .byte 1

.macro mulsum 

;do the multiplication
mul @0,@2
mov r8,r0
mov r9,r1

mul @1,@2
adc r9,r0
adc r10,r1

;store the result into sum
add @3,r8
adc @4,r9
adc @5,r10
;clear temp variables
clr r8
clr r9
clr r10
.endmacro


.cseg

ldi zl,low(a)
ldi zh,high(a)

ldi three,10
mov ten,three
ldi three,1
mov one,three
ldi three,3

ldi xl,low(xg)
ldi xh,high(xg)
st x,three

ldi xl,low(ng)
ldi xh,high(ng)
st x,ten

main:

ldi yl,low(RAMEND-6)
ldi yh,high(RAMEND-6)
out spl,yl
out sph,yh

std y+1,one
std y+2,r5
std y+3,r5
std y+4,r5
std y+5,r5
std y+6,r5
		

ldd i,y+6
ldd sum_high,y+5
ldd sum_mid,y+4
ldd sum_low,y+3
ldd result_high,y+2
ldd result_low,y+1


main_forloop:
		
cp ten,i
brlo end

st z,i
rcall power		;call power to calculate the refsult of x to the power of i
ld ai,z+
				
				;multiply result with ai and sum to sum
mulsum result_low,result_high,ai,sum_low,sum_mid,sum_high

inc i
rjmp main_forloop


power:


				;prologue, frame size=5 (excluding the stack frame
				;space for storing return address and registers) 
push r28		; Save r28 and r29 in the stack
push r29
in r28,SPL
in r29,SPH
sbiw r28,5		; Compute the stack frame top for move
				; Notice that 4 bytes are needed to store
				; the actual parameters number,power,num_low,num_high and counter
out SPH,r29
out SPL,r28
std y+1,three
std y+2,i

std y+3,one
std y+4,one
std y+5,r5


ldd number,y+1
ldd pow,y+2
ldd count,y+3
ldi r24,1
ldi r25,0


power_forloop:
cp pow,count
brlo epilogue

;do the multiplication
mul r24,number
mov num_low,r0
mov num_high,r1

mul r25,number
adc num_high,r0

;store the result into r24&r25
mov r24,num_low
mov r25,num_high
inc count

rjmp power_forloop
;@0 = x  @1 = i  @2 = low(num)  @3 = high(num)
	
epilogue:
adiw r28,5		;deallocate the stack frame
out SPH,r29
out SPL,r28
pop r29			;restore y
pop r28
ret				;return to main





end: rjmp end


