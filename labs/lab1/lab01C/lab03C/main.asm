


;
; lab03C.asm
;
; Created: 2017/8/11 16:51:22
; Author : LI JINGCHENG
;


; Replace with your application code

.include"m2560def.inc"

.def counter=r19;define a counter
.dseg

array: .byte 20;set array space
sum: .byte 2;set a 16-bit variable for summation
temp: .byte 2;temporate variable
.cseg
;set register 
ldi r16,low(temp)
ldi r17,high(temp)

ldi zl, low(array)
ldi zh, high(array)

ldi r21,low(sum)
ldi r22,high(sum)

;initialise value
ldi r20,200
clr r16
clr r17
clr counter

;initialise the value of the array
initialise:

mul counter,r20
mov r16,r0
mov r17,r1
st z+,r16
st z+,r17
inc counter

cpi counter,10

brlt initialise

;reload the value
clr counter
clr r0
clr r1
ldi zl, low(array)
ldi zh, high(array)

;test if values are stored correctly
;show:

;ld r0,z+
;ld r1,z+
;inc counter
;cpi counter,10
;brlt show

;ldi zl, low(array)
;ldi zh, high(array)
;clr counter
;clr r0
;clr r1
;clr r21
;clr r22

;do the summation
summation:
;load values from array a
ld r0,z+
ld r1,z+

add r21,r0
adc r22,r1

inc counter
cpi counter,10
;loop if counter is less than 10
brlt summation

;endless loop
end:
rjmp end
