.org 0x10000000 

ldi $10, 0xFFE00000
ldi $1,0x0
ldi $2,0x0
ldi $2,0x0
ldi $4,0x0
ldi $5,0x0

st.w $1,0($10)
;ldi $2, 0xF5
;st.w $2,0($1)
; Fill ram location with FFF's
ldi $8,0x0
ldi $9,0x0
ldi $19,0xFFFFFFFF
ldi $21,0x00100000
;#1 store and load operations alternative pattern 1
addi $8,$8,1  ;testcase 1
st.w $19, 0($21)
ld.w $1,0($21)
st.w $19, 12($21)
ld.w $1,12($21)

ldi $2,0xFFFFFFFF 
sub $3,$2,$1
bnz display_LED,$3
addi $9,$9,1
;#2 store and load alternative pattern 2
addi $8,$8,1

;ld.w $1,0($21)
;st.w $5, 0($21)
;ld.w $1,4($21)
;st.w $1,0($10)
;st.w $19, 4($21)

;ldi $2,0xFFFFFFFF 
;sub $3,$2,$1
;bnz display_LED,$3
addi $9,$9,1

;#3 store and nop 1
addi $8,$8,1
nop
st.w $19, 0($21)
nop
st.w $19, 4($21)
nop
st.w $19, 8($21)
nop
st.w $19, 12($21)
nop
st.w $19, 16($21)
nop
st.w $19, 20($21)
ldi $2,0xFFFFFFFF 
sub $3,$2,$1
bnz display_LED,$3
addi $9,$9,1
;#4 store and nop 2
addi $8,$8,1
nop
nop
nop
st.w $19, 0($21)
nop
nop
nop
st.w $19, 4($21)
nop
nop
nop
st.w $19, 8($21)
nop
nop
nop
st.w $19, 12($21)
nop
nop
nop
st.w $19, 16($21)
nop
nop
nop
st.w $19, 20($21)
ldi $2,0xFFFFFFFF 
sub $3,$2,$1
bnz display_LED,$3
addi $9,$9,1

;#5 load and nop 1
addi $8,$8,1
nop
ld.w $1,0($21)
nop
ld.w $1,4($21)
nop
ld.w $1,8($21)
nop
ld.w $1,12($21)
nop
ld.w $1,16($21)
nop
ld.w $1,20($21)
ldi $2,0xFFFFFFFF 
sub $3,$2,$1
bnz display_LED,$3
addi $9,$9,1

;#6 load and nop 2
addi $8,$8,1
nop
nop
nop
ld.w $1,0($21)
nop
nop
nop
ld.w $1,4($21)
nop
nop
nop
ld.w $1,8($21)
nop
nop
nop
ld.w $1,12($21)
nop
nop
nop
ld.w $1,16($21)
nop
nop
nop
ld.w $1,20($21)
ldi $2,0xFFFFFFFF 
sub $3,$2,$1
bnz display_LED,$3
addi $9,$9,1

;#7 store and load with nop
addi $8,$8,1
st.w $19, 0($21)
nop
nop
nop
ld.w $1,0($21)
nop
nop
nop
st.w $19, 4($21)
nop
nop
nop
ld.w $1,4($21)
nop
nop
nop
st.w $19, 8($21)
nop
nop
nop
ld.w $1,8($21)
nop
nop
nop
st.w $19, 12($21)
nop
nop
nop
ld.w $1,12($21)
nop
nop
nop
st.w $19, 16($21)
nop
nop
nop
ld.w $1,16($21)
ldi $2,0xFFFFFFFF 
sub $3,$2,$1
bnz display_LED,$3
addi $9,$9,1

;#8 store and load with nop backwards
addi $8,$8,1
st.w $19, 4($21)
nop
nop
nop
ld.w $1,0($21)
nop
nop
nop
ld.w $19, 4($21)
nop
nop
nop
st.w $1,4($21)
nop
nop
nop
st.w $19, 8($21)
nop
nop
nop

ldi $2,0xFFFFFFFF 
sub $3,$2,$1
bnz display_LED,$3
addi $9,$9,1

;#9 store and load with nops- non sequential/random locations
addi $8,$8,1
st.w $19,0($21)
nop
nop
nop
st.w $19,16($21)
nop
nop
ld.w $1,0($21)
nop
st.w $19,16($21)
st.w $19,20($21)
ld.w $1,4($21)
ld.w $1,8($21)
nop
nop
st.w $19,8($21)
nop
ld.w $1,16($21)
nop
nop
nop
st.w $19,8($21)

ldi $2,0xFFFFFFFF 
sub $3,$2,$1
bnz display_LED,$3
addi $9,$9,1


bra label

display_LED:
ldi $1,0xFFE00000
st.w $8,0($1)
infLoop_1: nop
bra infLoop_1

label:
ldi $11,0xFFFFFFFF
st.w $11,0($10)
nop
nop
loooop2:
bra loooop2
nop


