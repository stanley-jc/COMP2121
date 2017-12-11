;
; LAB02B.asm
;
; Created: 2017/8/27 0:22:18
; Author : LI JINGCHENG
;


; Replace with your application code
.dseg


sum: .byte 3
a: .byte 10
num: .byte 2
result: .byte 2
i: .byte 1
xg: .byte 1
ng: .byte 1
.cseg


ldi r16,low(xg)
ldi r17,low(ng)
ldi r18,low(i)
ldi r19,low(num)
ldi r20,high(num)
ldi r21,low(sum)
ldi r22,high(sum)
ldi r23,byte3(sum)
ldi zl,low(a)
ldi zh,high(a)

;use macro for calculating power
.macro power 
;@0 = x  @1 = i  @2 = low(num)  @3 = high(num)
	
ldi r26,1
ldi r24,1
ldi r25,0
power_forloop:
cp @1,r26
brlo loopover
;do the multiplication
mul r24,@0
mov @2,r0
mov @3,r1

mul r25,@0
adc @3,r0

;store the result into r24&r25
mov r24,@2
mov r25,@3
inc r26
rjmp power_forloop

loopover:
.endmacro


main:

ldi r16,3
ldi r17,10
ldi r18,0
clr r19
clr r20
clr r21
clr r22
clr r23
inc r19

main_forloop:
		
cp r17,r18
brlo end

st z,r18
power r16,r18,r19,r20
ld r15,z+

;do the multiplication
mul r24,r15
mov r12,r0
mov r13,r1

mul r25,r15
adc r13,r0
adc r14,r1

;store the result into sum
add r21,r12
adc r22,r13
adc r23,r14
;clear temp variables
clr r12
clr r13
clr r14

inc r18
rjmp main_forloop
end: rjmp end


