.org 0x10000000
;bnz jumpdone,$29;
ldi $19,0xFFFFFFFF
;
;register 20 contains the counter
ldi $20,256;
ldi $21,0x00100000;
;register useful for the jump case 14
ldi $29, 0;
;filling the the registers from 0x00100000 to 0x001000FC
;in register 31 we have the wrong test value
ldi $31,0xDEADAFFE;
;in register 30 we have the right result
ldi $30,0x00000001;

ldi $5,-4;
ldi $6,4

loop:
add $20,$20,$5;
st.w $19,0($21);
add $21,$21,$6
;----incrementing the address
bnz loop,$20
;register 28 contains the number of the test and 27 the memory
;test loadi
;test 0
ldi $28,0
ldi $27,0x00100000
ldi $4[1,3],1
perm $1,$4[3,3,3,3]
st.w $1,0($27)

;test1 ldi for the other register and perm just in 0
addi $28,$28,1
addi $27,$27,4
ldi $3[2],1
perm $0,$3[2,1,2,3]
st.w $1,0($27)

;test2,3,4,5
ldi $3,0 
addi $28,$28,1
addi $27,$27,4
ldi $0[0],2
ldi $1[0],-1
ldi $0[1],3
ldi $1[1],-2
ldi $0[2],4
ldi $1[2],-3
ldi $0[3],5
ldi $1[3],-4
add $3,$1,$0
st.w $3,0($27)
perm $3,$3[1,2,1,3]
addi $28,$28,1
st.w $3,4($27)
addi $28,$28,1
perm $3,$3[2,1,2,3]
st.w $3,8($27)
addi $28,$28,1
perm $3,$3[3,1,2,3]
st.w $3,12($27)
addi $27,$27,12

;test 6 mult
ldi $3,0 
addi $28,$28,1
addi $27,$27,4
ldi $5,2
ldi $0[0],2
ldi $1[0],-4
ldi $0[1],3
ldi $1[1],-6
ldi $0[2],4
ldi $1[2],-8
ldi $0[3],5
ldi $1[3],-10
mul $5,$5,$0
add $0,$5,$1
bz correct6,$0
st.w $31,0($27)
bra end6
correct6:
st.w $30,0($27)
end6:



;test rdc8 with different destination
ldi $8,1
addi $28,$28,1
addi $27,$27,4
ldi $7,0xFF
rdc8 $8,$7
sub $8,$8,$7
bz correct7,$0
st.w $31,0($27)
bra end7
correct7:
st.w $30,0($27)
end7:

;test rdc8 with same destination
ldi $8,1
addi $28,$28,1
addi $27,$27,4
ldi $7,0xFF
rdc8 $7,$7
ldi $7[1,2,3],0xFFFFFFFF
addi $7,$7,1
bz correct8,$0
st.w $31,0($27)
bra end8
correct8:
st.w $30,0($27)
end8:

;test mult with negative operands
ldi $3,0 
addi $28,$28,1
addi $27,$27,4
ldi $5,-2
ldi $0[0],-2
ldi $1[0],4
ldi $0[1],-3
ldi $1[1],6
ldi $0[2],-4
ldi $1[2],8
ldi $0[3],-5
ldi $1[3],10
mul $5,$5,$0
sub $0,$5,$1
bz correct9,$0
st.w $31,0($27)
bra end9
correct9:
st.w $30,0($27)
end9:



;test tse
addi $28,$28,1
addi $27,$27,4
ldi $12[0,1],23
ldi $12[2,3],-5
ldi $13[0,1],8
ldi $13[2,3],4
tse $12,$12,$13 
ldi $12[0,1],1
addi $12,$12,-1
bz correct10,$12
st.w $31,0($27)
bra end10
correct10:
st.w $30,0($27)
end10:
;test tge
addi $28,$28,1
addi $27,$27,4
ldi $12[0,1],23
ldi $12[2,3],-5
ldi $13[0,1],8
ldi $13[2,3],4
tge $12,$12,$13       
ldi $12[2,3],1
addi $12,$12,-1
bz correct11,$12
st.w $31,0($27)
bra end11
correct11:
st.w $30,0($27)
end11:

;test bnz with specific register without nop
ldi $6,0
addi $28,$28,1
addi $27,$27,4
ldi $6[2,3],1
bnz test_bnz_1,$6[2,3]
ldi $6,0
nop
nop
nop
nop
bra end12
test_bnz_1:
ldi $6[0],1
st.w $6,0($27)
end12:

;test bnz with specific register with a operation in between
ldi $6,0
addi $28,$28,1
addi $27,$27,4
ldi $6[1,3],1
add $11,$3,$6
bnz test_bnz_2,$6[1,3]
ldi $6,0
nop
nop
nop
nop
bra end13
test_bnz_2:
ldi $6[0],1
st.w $6,0($27)
end13:


;test bnz with specific register with 2 operations in between
addi $28,$28,1
addi $27,$27,4
ldi $6[1,2],1
add $11,$3,$6
sari $4,$6,4
bnz test_bnz_3,$6[1,2]
ldi $6,0
nop
nop
nop
nop
bra end14
test_bnz_3:
ldi $6[0],1
st.w $6,0($27)
end14:


;test bz with specific register without nop
ldi $6,1
addi $28,$28,1
addi $27,$27,4
ldi $6[2,3],0
bz test_bz_1,$6[2,3]
ldi $6,0
nop
nop
nop
nop
bra end15
test_bz_1:
ldi $6[0],1
st.w $6,0($27)
end15:

;test bz with specific register with a operation in between
ldi $6,1
addi $28,$28,1
addi $27,$27,4
ldi $6[1,2],0
add $11,$3,$6
bz test_bz_2,$6[1,2]
ldi $6,0
nop
nop
nop
nop
bra end16
test_bz_2:
ldi $6[0],1
st.w $6,0($27)
end16:


;test bz with specific register with 2 operations in between
ldi $6,1
addi $28,$28,1
addi $27,$27,4
ldi $6[1,3],0
add $11,$3,$6
sari $4,$6,4
bz test_bz_3,$6[1,3]
ldi $6,0
nop
nop
nop
nop
bra end17
test_bz_3:
ldi $6[0],1
st.w $6,0($27)
end17:

;test bz with specific register with 2 operations in between
ldi $6,1
addi $28,$28,1
addi $27,$27,4
ldi $6[0,1,2,3],0
bz test_bz_4,$6[0,1,2,3]
ldi $6,4
nop
nop
nop
nop
bra end18
test_bz_4:
ldi $6[0],1
st.w $6,0($27)
end18:


;test bnz with perm with no operation in between
ldi $0,0
addi $28,$28,1
addi $27,$27,4
ldi $0[2],1
perm $0,$0[2,1,2,2]
bnz test_bnz_4,$0[0,2,3]
nop
nop
nop
bra end19
test_bnz_4:
st.w $0,0($27)
end19:


;test bz with rdc8
addi $28,$28,1
addi $27,$27,4
ldi $6,0xffffff00
rdc8 $6,$6
bz correct20,$6[0]
st.w $31,0($27)
bra end20
correct20:
st.w $30,0($27)
end20:

;test bnz with rdc8
ldi $6,1
addi $28,$28,1
addi $27,$27,4
ldi $6,0xf0f0
rdc8 $6,$6
bnz correct21,$6[0]
st.w $31,0($27)
bra end21
correct21:
st.w $30,0($27)
end21:

;test 22
;test store with rdc8 no nops
addi $28,$28,1
addi $27,$27,4
ldi $5[0],1
ldi $5[1,2,3],0xfff0000
rdc8 $3,$5
st.w $3,0($27)

;test 23
;test store with rdc8 1 nop
addi $28,$28,1
addi $27,$27,4
ldi $5[0],1
ldi $5[1,2,3],0x00ff00
rdc8 $3,$5
nop
st.w $3,0($27)
;test 24
;test tse with a write back
addi $28,$28,1
addi $27,$27,4
ldi $12[0,1],23
ldi $12[2,3],-5
ldi $13[0,1],8
ldi $13[2,3],4
tse $12,$12,$13 
;random instruction
sub $14,$12,$12
bz correct24_1,$12[0,1]
st.w $31,0($27)
bra end24
correct24_1:
addi $12,$12,-1
bz correct24,$12[2,3]
st.w $31,0($27)
bra end24
correct24:
st.w $30,0($27)
end24:
;test 25
;test tge with writeback and bz
addi $28,$28,1
addi $27,$27,4
ldi $12[0,1],23
ldi $12[2,3],-5
ldi $13[0,1],8
ldi $13[2,3],4
tge $12,$12,$13       
bz correct25_1,$12[3,2]
st.w $31,0($27)
bra end25
correct25_1:
addi $12,$12,-1
bz correct25,$12[0,1]
st.w $31,0($27)
bra end25
st.w $31,0($27)
bra end25
correct25:
st.w $30,0($27)
end25:

;test 26 multiplication with bz
addi $28,$28,1
addi $27,$27,4
ldi $13,0
ldi $0,34
ldi $6,8
mul $0,$6,$13
bz correct26,$0
st.w $31,0($27)
bra end26
correct26:
st.w $30,0($27)
end26:


;test 27 mixing operation
addi $28,$28,1
addi $27,$27,4
ldi $6,5
ldi $2[0],2
perm $1,$2[0,0,2,3]
perm $1,$1[0,1,0,3]
perm $1,$1[0,1,2,0]
mul $1,$6,$1
addi $1,$1,-9
st.w $1,0($27)
ldi $1[0],0xDEADAFFE
;test28
addi $28,$28,1
perm $1,$1[1,1,2,3]
addi $27,$27,4
st.w $1,0($27)
ldi $1[0],0xDEADAFFE
;test29
perm $1,$1[2,1,2,3]
addi $28,$28,1
addi $27,$27,4
st.w $1,0($27)
ldi $1[0],0xDEADAFFE
;test30
perm $1,$1[3,1,2,3]
nop
addi $28,$28,1
addi $27,$27,4
st.w $1,0($27)
;test31,32
addi $28,$28,1
addi $27,$27,4
ldi $0,subr31
ldi $1,0xff
sari $1,$1,7
call $0,$0
st.w $5,0($27)
bra end31

correct31:
perm $5,$5[3,1,2,3]
addi $28,$28,1
st.w $5,0($27)
addi $27,$27,4 
jmp $0
end31:

;test 33

addi $28,$28,1
ldi $3,0xDEADAFFE
addi $27,$27,4
ld.w $3,-4($27)
ldi $5,5
mul $5,$3,$5
addi $5,$5,-5
ldi $5[0,1],1
perm $6,$5[0,1,1,0]
ldi $6[0,1],2
tge $6,$5,$6
bz correct33,$6
end33:

;test 34 tge with equal
addi $28,$28,1
addi $27,$27,4
ldi $4,6
ldi $6,6
tge $3,$4,$6
st.w $3,0($27)


;test 35 tse with equal
addi $28,$28,1
addi $27,$27,4
ldi $4,6
ldi $6,6
tse $3,$4,$6
st.w $3,0($27)

;test 36 wb vector with read from different positions
addi $28,$28,1
addi $27,$27,4
ldi $4,0xdaadbaad
ldi $4[0,1],0
bz correct36, $4[0, 1]
bra wrong36

correct36:
st.w $30, 0($27)

bra test_37

wrong36:
st.w $31, 0($27)


;test 37, 5 store together for write buffer
test_37:
addi $28,$28,1
addi $27,$27,4


ldi $23,0x00100700
ldi $15, 1;
ldi $16, 2;
ldi $17, 6;
ldi $18, 7;
ldi $19, 8;
ldi $20, 9;
ldi $21, 0 ;add register result
ldi $26, 33

st.w $15, 0($23)
st.w $16, 4($23)
st.w $17, 8($23)
st.w $18, 12($23)
st.w $19, 16($23)
st.w $20, 20($23)

ld.w $22,0($23)

add $21, $21, $22
ld.w $22,4($23)
add $21, $21, $22
ld.w $22,8($23)
add $21, $21, $22
ld.w $22,12($23)
add $21, $21, $22
ld.w $22,16($23)
add $21, $21, $22
ld.w $22,20($23)
add $21, $21, $22

sub $26, $21, $26

bz correct37, $26
bra wrong37



correct37:
st.w $30, 0($27)

bra done

wrong37:
st.w $31, 0($27)


done:
ldi $20,0xFFFFFFFF
bra done


correct33:
st.w $5,0($27)
ldi $5,end33
jmp $5


subr31:
rdc8 $4,$1
nop
rdc8 $4,$4
perm $5,$4[1,2,3,0]
bz correct31,$5[0,1,2]
