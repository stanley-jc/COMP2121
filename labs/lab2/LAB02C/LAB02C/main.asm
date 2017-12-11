;
; LAB02C.asm
;
; Created: 2017/8/28 10:52:35
; Author : LI JINGCHENG
;


; Replace with your application code
.include "m2560def.inc"
.def n=r16
.def a=r17
.def b=r18
.def c=r19
.def cou=r22
.def timerl=r23
.def timerh=r24

.dseg

counter: .byte 1

.cseg

ldi n,8
ldi a,1
ldi b,3
ldi c,2

ldi xl,low(counter)
ldi xh,high(counter)
ldi cou,low(counter)

clr r20
clr cou
st x,r20
ldi r21,1

	

main:

ldi yl,low(RAMEND-4)
ldi yh,high(RAMEND-4)
out spl,yl
out sph,yh

std y+4,n		;address of n is y+4
std y+3,a		;address of a is y+3
std y+2,b		;address of b is y+2
std y+1,c		;address of c is y+1
	
rcall move

end : rjmp end



move:

				;prologue, frame size=4 (excluding the stack frame
				;space for storing return address and registers) 
push r28		; Save r28 and r29 in the stack
push r29
in r28,spl
in r29,sph
sbiw r28,4		; Compute the stack frame top for move
				; Notice that 4 bytes are needed to store
				; the actual parameters n, a, b, c

out sph,r29		; Adjust the stack frame pointer to point to
out spl,r28		; the new stack frame

add timerl,r21
adc timerh,r22

std y+4,n
std y+3,a
std y+2,c
std y+1,b


;if statement
cp n,r21
brne else
	
add cou,r21
st x,cou

epilogue:

adiw r28,4		; Deallocate the stack frame
out sph,r29
out spl,r28
pop r29			; Restore Y 
pop r28
ret				; Return 
	
else:

ldd n,y+4		;first recursive move call
ldd a,y+3
ldd b,y+2
ldd c,y+1
sub n,r21
rcall move

ldd n,y+4		;second recursive move call
ldd a,y+3
ldd b,y+1
ldd c,y+2
mov n,r21
rcall move

ldd n,y+4		;third recursive move call
ldd a,y+1
ldd b,y+3
ldd c,y+2
sub n,r21
rcall move

rjmp epilogue	;go to epilogue

