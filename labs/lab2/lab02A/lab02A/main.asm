;
; lab02A.asm
;
; Created: 2017/8/22 17:36:07
; Author : LI JINGCHENG
;


.include "m2560def.inc"





.cseg

ldi r25,low(63001)
mov r15,r25
ldi r16,high(63001)
ldi r17,low(6000)
ldi r18,high(6000)
ldi r19,0
ldi r20,0
ldi r23,1
ldi r24,0
;ldi r25,low(3217)
ldi r26,0



while1:

cp r15,r17
cpc r16,r18
brlo while2

mov r21,r17
mov r22,r18
;avoid overflow
andi r21,low(0x8000)
andi r22,high(0x8000)
add  r21,r22
cpi r21,0
brne while2

;shift one bit left
lsl r17
rol r18

lsl r23
rol r24



rjmp while1

while2:

cp r23,r7
cpc r24,r7
brlo end
breq end


cp r15,r17
cpc r16,r18
brlo shiftback

;do the subtraction
sub r15,r17
sbc r16,r18

add r19,r23
adc r20,r24

shiftback:
;shift one bit right
lsr r18
ror r17

lsr r24
ror r23

rjmp while2

end:
rjmp end