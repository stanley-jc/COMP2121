;
; lab03B.asm
;
; Created: 2017/8/12 13:55:04
; Author : LI JINGCHENG
;

; Replace with your application code

.include "m2560def.inc"

.def counter=r16;define counter
.dseg

sum: .byte 3;set a 24-bit variable summ
tempa: .byte 3;set a 24-bit temporate variable
tempb: .byte 3;set a 24-bit temporate variable
.cseg

string:.db "325658"
ldi zl, low(string<<1);let the pointer point to the start of the string
ldi zh, high(string<<1);let the pointer point to the start of the string

ldi r24,low(sum);link register to sum
ldi r25,high(sum);
ldi r26,byte3(sum)

ldi r17,10;set 10 to r17

ldi r18,low(tempa);link register to tempa
ldi r19,high(tempa)
ldi r20,byte3(tempa)

ldi r21,low(tempb);link register to tempb
ldi r22,high(tempb)
ldi r23,byte3(tempb)

;clear all the values
clr counter

clr r24
clr r25
clr r26
clr r18
clr r19
clr r20
clr r21
clr r22
clr r23

;do the summation
main:

lpm r27, z+
subi r27, 48

;do the multiplication
mul r24,r17
mov r18,r0
mov r19,r1
clr r20

mul r25,r17
mov r22,r0
mov r23,r1
clr r21

add r18,r21
adc r19,r22
adc r20,r23

mul r26,r17
mov r23,r0
clr r21
clr r22

;add the value together
add r21,r18
adc r22,r19
adc r23,r20

;store them into sum
adc r21,r27
mov r24,r21
mov r25,r22
mov r26,r23

inc counter
cpi counter, 6
brlt main

;endless loop
loop:
rjmp loop