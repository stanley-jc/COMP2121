;
; lab1A.asm
;
; Created: 08/08/2017 14:09:56
;


.include "m2560def.inc"

.cseg
rjmp start

start:
;load two numbers
ldi r16, LOW(7654)
ldi r17, HIGH(7654)
ldi r18, LOW(5432)
ldi r19, HIGH(5432)

while:
;compare two numbers
;if equal
cp r16, r18
cpc r17, r19
brne if
rjmp end

if:
cp r16, r18
cpc r17, r19
brsh elsepart ;if a>b

;do b-a
sub r18, r16
sbc r19, r17 
rjmp while

elsepart:
;do a-b
sub r16, r18
sbc r17, r19
rjmp while

end:
rjmp end













    

