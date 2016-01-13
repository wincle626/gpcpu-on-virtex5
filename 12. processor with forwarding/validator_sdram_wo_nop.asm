.org 0x10000000
ldil $0 ,0xFFFF ;FILLING THE RAM
ldih $0 ,0xFFFF ;FILLING THE RAM

 
ldil $1 ,0x0000 ;Loading the Starting Address
ldih $1 ,0x0010

ldil $2 ,0x00FC ;Loading the Starting Address
ldih $2 ,0x0010

ldil $4 ,0x0004 ;Loading the Starting Address
ldih $4 ,0x0000

st.w $0,($1)

Fill_Routine:
add $1 ,$1, $4
sub $3,$2,$1
st.w $0,($1)
bnz  Fill_Routine,$3  




;--------------------T.E.S.T 0 ------------------
; ; test for "ADD" using reg 0,1,2,3,4,5,28,29
; 
;------------------------------------------------

test0:
;------------------------------------------------------------------
ldil $0 ,0x0001 ;FILLING THE RAM
ldih $0 ,0x0000 ;FILLING THE RAM

ldil $29 ,0xF0CE ;FILLING THE RAM
ldih $29 ,0xF0CE ;FILLING THE RAM

ldil $28 ,0x0000 ;Loading the Starting Address
ldih $28 ,0x0010


ldil $1 ,0x0001 ;Loading the 1st OP
ldih $1 ,0x0000

ldil $2 ,0x0001 ;Loading the 2nd OP
ldih $2 ,0x0000

ldil $4 ,0x0002 ;Loading the EXP result
ldih $4 ,0x0000

ldil $5 ,0x0001 ;Check Reg

ldih $5 ,0x0000

add $3,$2,$1

sub $5,$4,$3


bz correct , $5


st.w $29,($28)
 
 

bra end0
 
 

correct:
st.w $0,($28)
 
 
end0:
;------------------------------------------------
;--------------------T.E.S.T 1 ------------------
; ; test for "SHIFTING LEFT" SAL using reg 5,6,7,8,9
; ; Using SAL with +ve shifting 
;------------------------------------------------
test1:     
ldil $28 ,0x0004 ;Loading the 2nd Address
 
 
ldih $28 ,0x0010

ldil $5 , 0x0001
 
 
ldih $5 , 0x0000

ldil $6 , 0x0002
 
 
ldih $6 , 0x0000

;expected value is 4
ldil $8 , 0x0004
 
 
ldih $8 , 0x0000

sal $7,$5,$6 ;shifitng 5 as the value in 6
 
 

sub $9,$7,$8
 
 

bz correct1 , $9
 

st.w $29,($28)
 
 

bra end1
 


correct1:
st.w $0,($28)
 
 
end1:
;-------------------------------------------------
;--------------------T.E.S.T 2 ------------------
; ; test for "SHIFTING LEFT" SAL using reg 5,6,7,8,9
; ; Using SAL with -ve shifting 
;------------------------------------------------
;REMARKS: test failed because of problms in SAL with Negative numbers
;Problem with:- negative number to shift and shifting -ve times which makes it a Shift arithmatic right
;------------------------------------------------

test2:     
ldil $28 ,0x0008 ;Loading the 3rd Address
 
 
ldih $28 ,0x0010

ldil $5 , 0xFFFA ; loading -6
 
 
ldih $5 , 0xFFFF

ldil $6 , 0xFFFA ; loading -ve 6
 
 
ldih $6 , 0xFFFF

;expected value is -1
ldil $8 , 0xFFFF
 
 
ldih $8 , 0xFFFF

sal $7,$5,$6 ;shifitng $5 as much as the value in 6 i.e -ve6
 
 

sub $9,$7,$8
 
 

bz correct2 , $9
 

st.w $29,($28)
 
 

bra end2
 


correct2:
st.w $0,($28)
 
 

end2:
;-------------------------------------------------
;--------------------T.E.S.T 3 ------------------
; ; test for "SHIFTING Arithmatic RIGHT " using reg 5,6,7,8,9
; ; Using SAR with +ve shifting 
;------------------------------------------------
;REMARKS: sign preserved test passed
;------------------------------------------------

test3:     
ldil $28 ,0x000C ;Loading the 4th Address
 
 
ldih $28 ,0x0010

ldil $5 , 0xFFFA ; loading -6
 
 
ldih $5 , 0xFFFF

ldil $6 , 0x0001 ;Shifting 1 time
 
 
ldih $6 , 0x0000

;expected value is -3
ldil $8 , 0xFFFD
 
 
ldih $8 , 0xFFFF

sar $7,$5,$6 ;shifitng $5 as much as the value given
 
 

sub $9,$7,$8
 
 

bz correct3 , $9
 

st.w $29,($28)
 
 

bra end3
 


correct3:
st.w $0,($28)
 
 

end3:
;-------------------------------------------------
;--------------------T.E.S.T 4 ------------------
; ; test for "SHIFTING ARITHMATIC RIGHT" using reg 5,6,7,8,9
; ; Using SAR with -ve shifting 
;------------------------------------------------
test4:     
ldil $28 ,0x0010 ;Loading the 5th Address
 
 
ldih $28 ,0x0010

ldil $5 , 0xFFFA ; loading -6
 
 
ldih $5 , 0xFFFF

ldil $6 , 0xFFFF ; loading -1
 
 
ldih $6 , 0xFFFF

;expected value is -12
ldil $8 , 0xFFF4
 
 
ldih $8 , 0xFFFF

sar $7,$5,$6 ;shifitng $5 as much as the value in $6
 
 

sub $9,$7,$8
 
 

bz correct4 , $9
 

st.w $29,($28)
 
 

bra end4
 


correct4:
st.w $0,($28)
 
 

end4:
;-------------------------------------------------
;--------------------T.E.S.T 5 ------------------
; ; test for "AND" using reg 5,6,7,8,9
; ;------------------------------------------------
;REMARKS: PASSED OFCOURSE !! JESUS MAN !
; ;------------------------------------------------

test5:     
ldil $28 ,0x0014 ;Loading the 6th Address
 
 
ldih $28 ,0x0010

ldil $5 , 0x0000 ; loading the 16 MSBSwith highs and lsbs with lows
 
 
ldih $5 , 0xFFFF

ldil $6 , 0xFFFF ; loading the 16 MSBS with lows and lsbs with highs
 
 
ldih $6 , 0x0000

;expected value is 0000 0000 
ldil $8 , 0x0000
 
 
ldih $8 , 0x0000

and $7,$5,$6 ;ANDing both reg
 
 

sub $9,$7,$8
 
 

bz correct5 , $9
 

st.w $29,($28)
 
 

bra end5
 


correct5:
st.w $0,($28)
 
 

end5:
;-------------------------------------------------
;--------------------T.E.S.T 6 ------------------
; ; test for "OR" using reg 5,6,7,8,9
; ;------------------------------------------------
;REMARKS: PASSED OFCOURSE !!
; ;------------------------------------------------

test6:     
ldil $28 ,0x0018 ;Loading the 7th Address
 
 
ldih $28 ,0x0010

ldil $5 , 0x0000 ; loading the 16 MSBSwith highs and lsbs with lows
 
 
ldih $5 , 0xFFFF

ldil $6 , 0xFFFF ; loading the 16 MSBS with lows and lsbs with highs
 
 
ldih $6 , 0x0000

;expected value is FFFF FFFF 
ldil $8 , 0xFFFF
 
 
ldih $8 , 0xFFFF

or $7,$5,$6 ;ORing both reg
 
 

sub $9,$7,$8
 
 

bz correct6 , $9
 

st.w $29,($28)
 
 

bra end6
 


correct6:
st.w $0,($28)
 
 

end6:
;-------------------------------------------------
;--------------------T.E.S.T 7 ------------------
; ; test for "NOT" using reg 5,6,7,8,9
; ;------------------------------------------------
;REMARKS: PASSED OFCOURSE !!
; ;------------------------------------------------

test7:     
ldil $28 ,0x001C ;Loading the 8th Address
 
 
ldih $28 ,0x0010

ldil $5 , 0x0000 ; loading the 16 MSBSwith highs and lsbs with lows
 
 
ldih $5 , 0xFFFF

ldil $6 , 0xFFFF ; NOT USED
 
 
ldih $6 , 0x0000

;expected value is 0000 FFFF 
ldil $8 , 0xFFFF
 
 
ldih $8 , 0x0000

not $7,$5 ;NOTing
 
 

sub $9,$7,$8
 
 

bz correct7 , $9
 

st.w $29,($28)
 
 

bra end7
 


correct7:
st.w $0,($28)
 
 

end7:
;-------------------------------------------------
;--------------------T.E.S.T 8 ------------------
; ; test for "JMP" using reg 5,6,7,8,9
; ;------------------------------------------------
;REMARKS: PASSED OFCOURSE !!
; ;------------------------------------------------

test8:     
ldil $28 ,0x0020 ;Loading the 9th Address
 
 
ldih $28 ,0x0010


ldil $5 , 0x0244 ; Loading the adress of label CORRECT8 i.e 0x10000510
 
 
ldih $5 , 0x1000
 
 

jmp $5


ldil $6 , 0xFFFF ; irrelevent
 
 
ldih $6 , 0x0000

;expected value is irrelevent
ldil $8 , 0xFFFF
 
 
ldih $8 , 0x0000

not $7,$5 ;NOTing
 
 

sub $9,$7,$8
 
 

bz correct8 , $9
 

st.w $29,($28)
 
 

bra end8
 

correct8:
st.w $0,($28)
 
 

end8:
;-------------------------------------------------
;--------------------T.E.S.T 9 ------------------
; ; test for "BRA" using reg 5,6,7,8,9
; ;------------------------------------------------
;REMARKS: PASSED OFCOURSE !!
; ;------------------------------------------------

test9:     
ldil $28 ,0x0024 ;Loading the 10th Address
 
 
ldih $28 ,0x0010

bra correct9
 


ldil $5 , 0x051C ; irrelevent
 
 
ldih $5 , 0x1000
 
 

jmp $5


ldil $6 , 0xFFFF ; irrelevent
 
 
ldih $6 , 0x0000

;expected value is irrelevent
ldil $8 , 0xFFFF
 
 
ldih $8 , 0x0000

not $7,$5 ;irrelevent
 
 

sub $9,$7,$8
 
 

bz correct9 , $9
 

st.w $29,($28)
 
 

bra end9
 

correct9:
st.w $0,($28)
 
 

end9:
;-------------------------------------------------
;--------------------T.E.S.T 10 ------------------
; ; test for "BL" using reg 5,6,7,8,9
; ;------------------------------------------------
;REMARKS: PASSED OFCOURSE !!
; ;------------------------------------------------

test10:     
ldil $28 ,0x0028 ;Loading the 11th Address
 
 
ldih $28 ,0x0010

bl $5, correct10 ; it should save 0x10000294 in $5 that is the add of next instruction
st.w $29,($28)
bra end9
 

correct10:
ldil $6 ,0x00294 ;Loading the saved Address of PC to check if PC landed where it should and Saved the Right adress
ldih $6 ,0x1000
sub $7,$5,$6
bz correct10_1 , $7
 
st.w $29,($28)
bra end10

correct10_1:
st.w $0,($28)

end10:
;-------------------------------------------------

;--------------------T.E.S.T 11 ------------------
; ; test for "ADDing with -ve Op" using reg 5,6,7,8,9
; ;------------------------------------------------

; ;------------------------------------------------

test11:     
ldil $28 ,0x002C ;Loading the 12th Address
 
 
ldih $28 ,0x0010

ldil $5 , 0xFFFE ; loading -2
 
 
ldih $5 , 0xFFFF

ldil $6 , 0xFFFE ; loading -2
 
 
ldih $6 , 0xFFFF

;expected value is FFFF FFFC  -4
ldil $8 , 0xFFFC
 
 
ldih $8 , 0xFFFF

add $7,$5,$6
 
 

sub $9,$7,$8
 
 

bz correct11 , $9
 

st.w $29,($28)
 
 

bra end11
 


correct11:
st.w $0,($28)
 
 

end11:
;-------------------------------------------------

;--------------------T.E.S.T 12 ------------------
; ; test for "ADDing with -ve" using reg 5,6,7,8,9
;Checking overflow
; ;------------------------------------------------

; ;------------------------------------------------

test12:     
ldil $28 ,0x0030 ;Loading the 13th Address
 
 
ldih $28 ,0x0010

ldil $5 , 0xFFFF ; loading -1
 
 
ldih $5 , 0xFFFF

ldil $6 , 0x0001 ; loading 1
 
 
ldih $6 , 0x0000

;expected value is 0000 0000  0
ldil $8 , 0x0000
 
 
ldih $8 , 0x0000

add $7,$5,$6
 
 

sub $9,$7,$8
 
 

bz correct12 , $9
 

st.w $29,($28)
 
 

bra end12
 


correct12:
st.w $0,($28)
 
 

end12:
;-------------------------------------------------
;--------------------T.E.S.T 13 ------------------
; ; test for "ADDing with -ve" using reg 5,6,7,8,9
;Checking overflow
; ;------------------------------------------------

; ;------------------------------------------------

test13:     
ldil $28 ,0x0034 ;Loading the 14th Address
 
 
ldih $28 ,0x0010

ldil $5 , 0xFFFF ; loading -1
 
 
ldih $5 , 0xFFFF

ldil $6 , 0xFFFF ; loading -2
 
 
ldih $6 , 0xFFFF

;expected value is FFFF FFFE
ldil $8 , 0xFFFE
 
 
ldih $8 , 0xFFFF

add $7,$5,$6
 
 

sub $9,$7,$8
 
 

bz correct13 , $9
 

st.w $29,($28)
 
 

bra end13
 


correct13:
st.w $0,($28)
 
 

end13:
;-------------------------------------------------
;--------------------T.E.S.T 14 ------------------
; ; test for "CALL" using reg 5,6,7,8,9
; ;------------------------------------------------
;REMARKS: PASSED OFCOURSE !!
; ;------------------------------------------------

test14:     
ldil $28 ,0x0038 ;Loading the 15th Address
 
 
ldih $28 ,0x0010

ldil $6 ,0x0380 ;Loading the Address of place where to jump
 
 
ldih $6 ,0x1000
 
 

call $5, $6 ; it should save 0x100007e8 in $5 that is the addr of next instruction and should jump to the instruction at ($6)
 

bz correct14 , $9
 

st.w $29,($28)
 
 

bra end9
 

correct14:
ldil $6 ,0x0374 ;Loading the saved Address of PC to check if PC landed where it should and Saved the Right adress
 
 
ldih $6 ,0x1000
 
 


sub $7,$5,$6
 
 

bz correct14_1 , $7
 
st.w $29,($28)
 
 
bra end14
 



correct14_1:
st.w $0,($28)
 
 

end14:
;-------------------------------------------------
;--------------------T.E.S.T 15 ------------------
; ; test for "ADD a,a,a" using reg 5,6,7,8,9
;Checking overflow
; ;------------------------------------------------

; ;------------------------------------------------

test15:     
ldil $28 ,0x003C ;Loading the 16th Address
 
 
ldih $28 ,0x0010

;expected value is FFFF FFFE -2
ldil $8 , 0xFFFE
 
 
ldih $8 , 0xFFFF

ldil $5 , 0xFFFF ; loading -1
 
 
ldih $5 , 0xFFFF
 
 

add $5,$5,$5
 
 

sub $9,$5,$8
 
 

bz correct15 , $9
 

st.w $29,($28)
 
 

bra end15
 


correct15:
st.w $0,($28)

end15:
;-------------------------------------------------
;--------------------T.E.S.T 16 ------------------
; ; test for "Store After load with Displcment addr" using reg 5,6,7,8,9
;
; ;------------------------------------------------
;Remarks :  passed!!
; ;------------------------------------------------

test16:     
ldil $28 ,0x0040 ;Loading the 17th Address
 
 
ldih $28 ,0x0010

;expected value is FOCE FOCE 
ldil $8 , 0xF0ce
 
 
ldih $8 , 0xF0ce

ldil $5 , 0x0000 ; loading the base address
 
 
ldih $5 , 0x1100
 
 

st.w $29,0x4($5) ; saving "FOCEFOCE" at the address $5 + 4 i.e 0x11000004

ld.w $6 ,0x4($5) ; loading the data from the address $5 + 4 i.e 0x11000004 and content "FOCEFOCE"
 
 

sub $9,$6,$8 ; subtracting the expected address with the recived address 
 
 

bz correct16 , $9
 

st.w $29,($28)

bra end16
 


correct16:
st.w $0,($28)

end16:
;-------------------------------------------------
;--------------------T.E.S.T 17 ------------------
; ; test for "Jump After load " using reg 5,6,7,8,9
;
; ;------------------------------------------------
;Remarks :  
; ;------------------------------------------------

test17:     
ldil $28 ,0x0044 ;Loading the 18th Address
 
 
ldih $28 ,0x0010

;expected value. REG NOT USED
ldil $8 , 0x5555
ldih $8 , 0x5555

ldil $7 , 0xF0ce ;loading some garbage data
 
 
ldih $7 , 0xF0ce

ldil $5 , 0x0000 ; loading the base address
 
 
ldih $5 , 0x1100

ldil $6 , 0xAAAA ; loading the contents to write at the address
 
 
ldih $6 , 0xAAAA
 
 

st.w $6,($5) ; saving "0xAAAAAAAAA" at the address $5  i.e 0x11000000

ld.w $7 ,($5) ; loading the data from the address $5  i.e 0x11000000 and content "0xAAAAAAAA"
 
and $7,$7,$8 

bz correct17 , $7
 

st.w $29,($28)

bra end17
 

correct17:
st.w $0,($28)

end17:
;-------------------------------------------------
;--------------------T.E.S.T 18 ------------------
; ; test for "Store After load with Displcment -ve addr" using reg 5,6,7,8,9
;
; ;------------------------------------------------

; ;------------------------------------------------

test18:     
ldil $28 ,0x0048 ;Loading the 17th Address
 
 
ldih $28 ,0x0010

;expected value is FOCE FOCE 
ldil $8 , 0xF0ce
 
 
ldih $8 , 0xF0ce

ldil $5 , 0x0008 ; loading the base address 0x11000008
 
 
ldih $5 , 0x1100
 
 

st.w $29,0xFFFC($5) ; saving "FOCEFOCE" at the address $5 - 4 i.e 0x11000004

ld.w $6 ,0xFFFC($5) ; loading the data from the address $5 - 4 i.e 0x11000004 and content "FOCEFOCE"
 
 

sub $9,$6,$8 ; subtracting the expected address with the recived address 
 
 

bz correct18 , $9
 

st.w $29,($28)

bra end18
 


correct18:
st.w $0,($28)

end18:
;-------------------------------------------------
;--------------------T.E.S.T 19 ------------------
; ; test for "SARI" shifting with -ve number using reg 5,6,7,8,9
;
; ;------------------------------------------------

; ;------------------------------------------------

test19:     
ldil $28 ,0x004C ;Loading the 18th Address
 
 
ldih $28 ,0x0010

;expected value is 2
ldil $8 , 0x0002
 
 
ldih $8 , 0x0000

ldil $5 , 0x0001 ; loading the value 1
 
 
ldih $5 , 0x0000
 
 

sari $6,$5,0xFFFF
 
 

sub $9,$6,$8 ; subtracting the expected address with the recived address 
 
 

bz correct19 , $9
 

st.w $29,($28)

bra end19
 


correct19:
st.w $0,($28)

end19:
;-------------------------------------------------
;--------------------T.E.S.T 20 ------------------
; ; test for "SARI"  using reg 5,6,7,8,9
;
; ;------------------------------------------------

; ;------------------------------------------------

test20:     
ldil $28 ,0x0050 ;Loading the 19th Address
 
 
ldih $28 ,0x0010

;expected value is 1
ldil $8 , 0x0001
 
 
ldih $8 , 0x0000

ldil $5 , 0x0002 ; loading the value 2
 
 
ldih $5 , 0x0000
 
 

sari $6,$5,0x0001
 
 

sub $9,$6,$8 ; subtracting the expected address with the recived address 
 
 

bz correct20 , $9
 

st.w $29,($28)

bra end20
 


correct20:
st.w $0,($28)

end20:
;-------------------------------------------------
;--------------------T.E.S.T 21 ------------------
; ; test for "SARI" with negative numbers and positive
; shift value to check id it preservers the signs
; using reg 5,6,7,8,9
;
; ;------------------------------------------------
; ;------------------------------------------------

test21:     
ldil $28 ,0x0054 ;Loading the 20th Address
 
 
ldih $28 ,0x0010

;expected value is -3
ldil $8 , 0xFFFD
 
 
ldih $8 , 0xFFFF

ldil $5 , 0xFFFA ; loading the value -6
 
 
ldih $5 , 0xFFFF
 
 

sari $6,$5,0x0001
 
 

sub $9,$6,$8 ; subtracting the expected address with the recived address 
 
 

bz correct21 , $9
 

st.w $29,($28)

bra end21
 


correct21:
st.w $0,($28)

end21:
;-------------------------------------------------
;--------------------T.E.S.T 22 ------------------
; ; test for "SARI" with negative numbers and positive
; shift value to check id it preservers the signs
; using reg 5,6,7,8,9
;
; ;------------------------------------------------
; ;------------------------------------------------

test22:     
ldil $28 ,0x0058 ;Loading the 21th Address
 
 
ldih $28 ,0x0010

;expected value is -12
ldil $8 , 0xFFF4
 
 
ldih $8 , 0xFFFF

ldil $5 , 0xFFFA ; loading the value -6
 
 
ldih $5 , 0xFFFF
 
 

sari $6,$5,0xFFFF ;shifting by -ve 1
 
 

sub $9,$6,$8 ; subtracting the expected address with the recived address 
 
 

bz correct22 , $9
 

st.w $29,($28)

bra end22
 


correct22:
st.w $0,($28)

end22:
;-------------------------------------------------
;--------------------T.E.S.T 23 ------------------
; ; test for "ADDI" adding -ve number using reg 5,6,7,8,9
; ;------------------------------------------------
; ;------------------------------------------------

test23:     
ldil $28 ,0x005C ;Loading the 22th Address
 
 
ldih $28 ,0x0010

;expected value is -12
ldil $8 , 0xFFF4
 
 
ldih $8 , 0xFFFF

ldil $5 , 0xFFFA ; loading the value -6
 
 
ldih $5 , 0xFFFF


addi $6,$5,0xFFFA ; adding -6 to the reg $5 that is loaded with -6
 
 

sub $9,$6,$8 ; subtracting the expected address with the recived address 
 
 

bz correct23 , $9
 

st.w $29,($28)

bra end23
 


correct23:
st.w $0,($28)

end23:
;-------------------------------------------------
;--------------------T.E.S.T 24 ------------------
; ; test for "ADDI" adding 3 to -6 number using reg 5,6,7,8,9
; ;------------------------------------------------
; ;------------------------------------------------

test24:     
ldil $28 ,0x0060 ;Loading the 23th Address
 
 
ldih $28 ,0x0010

;expected value is -3
ldil $8 , 0xFFFD
 
 
ldih $8 , 0xFFFF

ldil $5 , 0xFFFA ; loading the value -6
 
 
ldih $5 , 0xFFFF


addi $6,$5,0x0003 ; adding -6 to the reg $5 that is loaded with -6
 
 

sub $9,$6,$8 ; subtracting the expected address with the recived address 
 
 

bz correct24 , $9
 

st.w $29,($28)

bra end24
 


correct24:
st.w $0,($28)

end24:
;-----------------------------------------
