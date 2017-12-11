;
; lab03D.asm
;
; Created: 2017/8/12 20:36:26
; Author : LI JINGCHENG
;


; Replace with your application code


.include"m2560def.inc"
;define variables
.def i=r16
.def j=r17
.def k=r18
.def var=r19
.def val1=r22
.def val2=r23
.dseg
;set space for arraies and variables
arraya: .byte 25
arrayb: .byte 25
arrayc: .byte 50

temp: .byte 2
.cseg
;load address to registers
ldi r20,low(temp)
ldi r21,high(temp)

ldi zl,low(arraya)
ldi zh,high(arraya)
ldi yl,low(arrayb)
ldi yh,high(arrayb)
ldi xl,low(arrayc)
ldi xh,high(arrayc)

clr r20
clr r21
clr i
clr j
clr k

;initialise array a,b,c
initialise1:

cpi i,5
brlt initialise2
rjmp reload


initialise2:

mov var,i
add var,j
st z+,var

mov var,i
sub var,j
st y+,var

clr var
st x+,var
st x+,var

inc j
cpi j,5
brlt initialise2

clr j
inc i
rjmp initialise1

;reload the variables
reload:
ldi zl,low(arraya)
ldi zh,high(arraya)
ldi yl,low(arrayb)
ldi yh,high(arrayb)
ldi xl,low(arrayc)
ldi xh,high(arrayc)

clr i
clr j
clr k


;show:

;ld r0,z+
;ld r1,y+
;ld r2,x+
;ld r3,x+

;inc i
;cpi i,25
;brlt show

;ldi zl,low(arraya)
;ldi zh,high(arraya)
;ldi yl,low(arrayb)
;ldi yh,high(arrayb)
;ldi xl,low(arrayc)
;ldi xh,high(arrayc)

;clr i
;clr j
;clr k

;do the loops
multi1:

cpi i,5
brlt multi2
rjmp end

multi2:

cpi j,5
brlt multi3

clr j
inc i
adiw z,5
sbiw y,5
rjmp multi1

multi3:
ld val1,z+
ld val2,y
ld r20,x+
ld r21,x+

sbiw x,2
;multiply elements of a and b
mulsu val2,val1
add r20,r0
adc r21,r1
;store them into array c
st x+,r20
st x+,r21
sbiw x,2
;update the pointers
adiw y,5
inc k
cpi k,5
brlt multi3

clr k
inc j
adiw x,2
sbiw y,25
adiw y,1
sbiw z,5
rjmp multi2

end:
rjmp end