.8086
.MODEL medium
INCLUDE gb_defs.inc

EXTRN CORE2_START
EXTRN BAD_OPCODE_DETECTED
EXTRN FF_OPCODE_HANDLER_CORE2

INIT SEGMENT
  ASSUME CS:INIT
ENDS
CORE2 SEGMENT
  ASSUME CS:CORE2
ENDS


COMMENT @
AX  = scratch
BX  = HL
CH  = ??
CL  = A
BP  = BC
DX  = DE
DI  = SP
DS  = emulated 64k space
SI  = IP (or pc or whatever)
SP  = ??
CS  = emulator core
ES  = ??
SS  = garbage area 
FLAGS emulate flags 
@


SEGMENT CORE1  USE16 PARA PUBLIC 'CODE'
ASSUME CS:CORE1



OPCODE_DEFINE 000h   ; NOP
INCREMENT_CYCLES 1

CORE1_START:
public CORE1_START

LOAD_NEXT_INSTRUCTION_NOCYCLES


OPCODE_DEFINE 001h   ; LD BC, d16

lodsw
xchg  ax, bp 
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 002h   ; LD (BC), A   

mov   byte ptr ds:[bp], cl

LOAD_NEXT_INSTRUCTION 2


OPCODE_DEFINE 003h   ; INC BC

inc  bp
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 004h   ; INC B

xchg ax, bp
inc  ah
xchg ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 005h   ; DEC B

xchg ax, bp
dec  ah
xchg ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 006h   ; LD B, d8

; a little gross.

xchg ax, bp
xchg al, ah
lodsb
xchg al, ah
xchg ax, bp
LOAD_NEXT_INSTRUCTION 2


OPCODE_DEFINE 007h   ; RLCA

rol cl, 1
LOAD_NEXT_INSTRUCTION 1


OPCODE_DEFINE 008h   ; LD (a16), SP

lodsw
xchg  ax, di
mov   word ptr ds:[di], ax
xchg  ax, di
LOAD_NEXT_INSTRUCTION 5

OPCODE_DEFINE 009h   ; ADD HL, BC

add   bx, bp
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 00Ah   ; LD A, (BC)

mov   cl, byte ptr ds:[bp]
LOAD_NEXT_INSTRUCTION 2



OPCODE_DEFINE 00Bh   ; DEC BC

dec   bp
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 00Ch   ; INC C

xchg ax, bp
inc  al
xchg ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 00Dh   ; DEC C

xchg ax, bp
dec  al
xchg ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 00Eh   ; LD C, d8

; a little gross.

xchg ax, bp
lodsb
xchg ax, bp
LOAD_NEXT_INSTRUCTION 2


OPCODE_DEFINE 00Fh   ; RRCA

ror  cl, 1
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 010h   ; STOP

; TODO.

OPCODE_DEFINE 011h   ; LD DE, d16

lodsw
xchg  ax, dx
LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 012h   ; LD (DE), A

xchg  dx, bx
mov   byte ptr ds:[bx], cl
xchg  dx, bx
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 013h   ; INC DE

inc   dx
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 014h   ; INC D

inc   dh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 015h   ; DEC D

dec   dh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 016h   ; LD D, d8

lodsb
mov  dh, al
LOAD_NEXT_INSTRUCTION 2


OPCODE_DEFINE 017h   ; RLA

rcl  cl, 1
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 018h   ; JR s8

lodsb
cbw
xchg ax, bx
lea  si, [si + bx]
xchg ax, bx
LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 019h   ; ADD HL, DE

add  bx, dx
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 01Ah   ; LD A, (DE)

xchg bx, dx
mov  cl, byte ptr ds:[bx]
xchg bx, dx
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 01Bh   ; DEC DE

dec  dx
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 01Ch   ; INC E

inc  dl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 01Dh   ; DEC E

dec  dl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 01Eh   ; LD E, d8

lodsb
mov   dl, al
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 01Fh   ; RRA

rcr  cl, 1
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 020h   ; JR NZ, s8

lodsb
jnz   jr_zero_flag_off

LOAD_NEXT_INSTRUCTION 2

jr_zero_flag_off:
cbw
xchg ax, bx
lea  si, [bx + si]
xchg ax, bx
LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 021h   ; LD HL, d16

lodsw
xchg  ax, bx
LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 022h   ; LD (HL+), A

mov   byte ptr ds:[bx], cl
lea   bx, [bx + 1]
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 023h   ; INC HL

inc   bx
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 024h   ; INC H

inc   bh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 025h   ; DEC H

dec   bh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 026h   ; LD H, d8

lodsb
mov   bh, al
LOAD_NEXT_INSTRUCTION 2


OPCODE_DEFINE 027h   ; DAA

; TODO


OPCODE_DEFINE 028h   ; JR Z, s8

lodsb
jz   jr_zero_flag_on

LOAD_NEXT_INSTRUCTION 2

jr_zero_flag_on:
cbw
xchg ax, bx
lea  si, [bx + si]
xchg ax, bx
LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 029h   ; ADD HL, HL

add  bx, bx
LOAD_NEXT_INSTRUCTION 2


OPCODE_DEFINE 02Ah   ; LD A, (HL+)

mov  cl, byte ptr ds:[bx]
lea  bx, [bx + 1]
LOAD_NEXT_INSTRUCTION 2


OPCODE_DEFINE 02Bh   ; DEC HL

dec  bx
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 02Ch   ; INC L

inc  bl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 02Dh   ; DEC L

dec  bl
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 02Eh   ; LD L, d8

lodsb
mov  bl, al
LOAD_NEXT_INSTRUCTION 2


OPCODE_DEFINE 02Fh   ; CPL

not  cl  ; TODO check flags
LOAD_NEXT_INSTRUCTION 1


OPCODE_DEFINE 030h   ; JR NC, s8

lodsb
jnc   jr_carry_flag_off

LOAD_NEXT_INSTRUCTION 2

jr_carry_flag_off:
cbw
xchg ax, bx
lea  si, [bx + si]
xchg ax, bx
LOAD_NEXT_INSTRUCTION 3


OPCODE_DEFINE 031h   ; LD SP, d16

lodsw
xchg  ax, di
LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 032h   ; LD (HL-), A

mov  byte ptr ds:[bx], cl
lea  bx, [bx - 1]
LOAD_NEXT_INSTRUCTION 2


OPCODE_DEFINE 033h   ; INC SP
inc  di
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 034h   ; INC (HL)
inc  byte ptr ds:[bx]
LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 035h   ; DEC (HL)
dec  byte ptr ds:[bx]
LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 036h   ; LD (HL), d8
lodsb
mov   byte ptr ds:[bx], al
LOAD_NEXT_INSTRUCTION 3


OPCODE_DEFINE 037h   ; SCF

stc
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 038h   ; JR C, s8

lodsb
jc   jr_carry_flag_on

LOAD_NEXT_INSTRUCTION 2

jr_carry_flag_on:
cbw
xchg ax, bx
lea  si, [bx + si]
xchg ax, bx
LOAD_NEXT_INSTRUCTION 3


OPCODE_DEFINE 039h   ; ADD HL, SP

add  bx, di
LOAD_NEXT_INSTRUCTION 2


OPCODE_DEFINE 03Ah   ; LD A, (HL-)

mov  cl, byte ptr ds:[bx]
lea  bx, [bx - 1]
LOAD_NEXT_INSTRUCTION 2


OPCODE_DEFINE 03Bh   ; DEC SP

dec   di
LOAD_NEXT_INSTRUCTION 2


OPCODE_DEFINE 03Ch   ; INC A

inc   cl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 03Dh   ; DEC A

dec   cl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 03Eh   ; LD A, d8

lodsb
mov   cl, al
inc   cl
LOAD_NEXT_INSTRUCTION 2


OPCODE_DEFINE 03Fh   ; CCF

cmc
LOAD_NEXT_INSTRUCTION 1


OPCODE_DEFINE 040h   ; LD B, B

LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 041h   ; LD B, C

xchg  ax, bp
mov   ah, al
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 042h   ; LD B, D
xchg  ax, bp
mov   ah, dh
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 043h   ; LD B, E
xchg  ax, bp
mov   ah, dl
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 044h   ; LD B, H
xchg  ax, bp
mov   ah, bh
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 045h   ; LD B, L
xchg  ax, bp
mov   ah, bl
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 046h   ; LD B, (HL)
xchg  ax, bp
mov   ah, byte ptr ds:[bx]
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 2


OPCODE_DEFINE 047h   ; LD B, A
xchg  ax, bp
mov   ah, cl
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1


OPCODE_DEFINE 048h   ; LD C, B
xchg  ax, bp
mov   al, ah
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 049h   ; LD C, C
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 04Ah   ; LD C, D
xchg  ax, bp
mov   al, dh
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 04Bh   ; LD C, E
xchg  ax, bp
mov   al, dl
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 04Ch   ; LD C, H
xchg  ax, bp
mov   al, bh
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 04Dh   ; LD C, L
xchg  ax, bp
mov   al, bl
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 04Eh   ; LD C, (HL)
xchg  ax, bp
mov   al, byte ptr ds:[bx]
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 04Fh   ; LD C, A
xchg  ax, bp
mov   al, cl
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1


OPCODE_DEFINE 050h   ; LD D, B
xchg  ax, bp
mov   dh, ah
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1


OPCODE_DEFINE 051h   ; LD D, C
xchg  ax, bp
mov   dh, al
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 052h   ; LD D, D
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 053h   ; LD D, E
mov   dh, dl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 054h   ; LD D, H
mov   dh, bh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 055h   ; LD D, L
mov   dh, bl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 056h   ; LD D, (HL)
mov   dh, byte ptr ds:[bx]
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 057h   ; LD D, A
mov   dh, cl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 058h   ; LD E, B
xchg  ax, bp
mov   dl, ah
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 059h   ; LD E, C
xchg  ax, bp
mov   dl, al
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 05Ah   ; LD E, D
mov   dl, dh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 05Bh   ; LD E, E
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 05Ch   ; LD E, H
mov   dl, bh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 05Dh   ; LD E, L
mov   dl, bl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 05Eh   ; LD E, (HL)
mov   dl, byte ptr ds:[bx]
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 05Fh   ; LD E, A
mov   dl, cl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 060h   ; LD H, B
xchg  ax, bp
mov   bh, ah
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 061h   ; LD H, C
xchg  ax, bp
mov   bh, al
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 062h   ; LD H, D
mov   bh, dh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 063h   ; LD H, E
mov   bh, dl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 064h   ; LD H, H
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 065h   ; LD H, L
mov   bh, bl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 066h   ; LD H, (HL)
mov   bh, byte ptr ds:[bx]
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 067h   ; LD H, A
mov   bh, cl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 068h   ; LD L, B
xchg  ax, bp
mov   bl, ah
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 069h   ; LD L, C
xchg  ax, bp
mov   bl, al
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 06Ah   ; LD L, D
mov   bl, dh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 06Bh   ; LD L, E
mov   bl, dl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 06Ch   ; LD L, H
mov   bl, bh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 06Dh   ; LD L, L
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 06Eh   ; LD L, (HL)
mov   bl, byte ptr ds:[bx]
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 06Fh   ; LD L, A
mov   bl, cl
LOAD_NEXT_INSTRUCTION 1


OPCODE_DEFINE 070h   ; LD (HL), B
xchg  ax, bp
mov   byte ptr ds:[bx], ah
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 071h   ; LD (HL), C
xchg  ax, bp
mov   byte ptr ds:[bx], al
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 072h   ; LD (HL), D
mov   byte ptr ds:[bx], dh
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 073h   ; LD (HL), E
mov   byte ptr ds:[bx], dl
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 074h   ; LD (HL), H
mov   byte ptr ds:[bx], bh
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 075h   ; LD (HL), L
mov   byte ptr ds:[bx],  bl
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 076h   ; HALT
; TODO

OPCODE_DEFINE 077h   ; LD (HL), A
mov   byte ptr ds:[bx], cl
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 078h   ; LD A, B
xchg  ax, bp
mov   cl, ah
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 079h   ; LD A, C
xchg  ax, bp
mov   cl, al
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 07Ah   ; LD A, D
mov   cl, dh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 07Bh   ; LD A, E
mov   cl, dl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 07Ch   ; LD A, H
mov   cl, bh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 07Dh   ; LD A, L
mov   cl, bl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 07Eh   ; LD A, (HL)
mov   cl, byte ptr ds:[bx]
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 07Fh   ; LD A, A
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 080h   ; ADD A, B
xchg  ax, bp
add   cl, ah
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 081h   ; ADD A, C
xchg  ax, bp
add   cl, al
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 082h   ; ADD A, D
add   cl, dh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 083h   ; ADD A, E
add   cl, dl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 084h   ; ADD A, H
add   cl, bh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 085h   ; ADD A, L
add   cl, bl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 086h   ; ADD A, (HL)
add   cl, byte ptr ds:[bx]
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 087h   ; ADD A, A
add   cl, cl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 088h   ; ADC A, B
xchg  ax, bp
adc   cl, ah
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 089h   ; ADC A, C
xchg  ax, bp
adc   cl, al
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 08Ah   ; ADC A, D
adc   cl, dh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 08Bh   ; ADC A, E
adc   cl, dl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 08Ch   ; ADC A, H
adc   cl, bh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 08Dh   ; ADC A, L
adc   cl, bl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 08Eh   ; ADD AC (HL)
adc   cl, byte ptr ds:[bx]
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 08Fh   ; ADC A, A
adc   cl, cl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 090h   ; SUB B
xchg  ax, bp
sub   cl, ah
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 091h   ; SUB C
xchg  ax, bp
sub   cl, al
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 092h   ; SUB D
sub   cl, dh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 093h   ; SUB E
sub   cl, dl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 094h   ; SUB H
sub   cl, bh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 095h   ; SUB L
sub   cl, bl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 096h   ; SUB (HL)
sub   cl, byte ptr ds:[bx]
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 097h   ; SUB A
sub   cl, cl
LOAD_NEXT_INSTRUCTION 1


OPCODE_DEFINE 098h   ; SBC B
xchg  ax, bp
sbb   cl, ah
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 099h   ; SBC C
xchg  ax, bp
sbb   cl, al
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 09Ah   ; SBC D
sbb   cl, dh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 09Bh   ; SBC E
sbb   cl, dl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 09Ch   ; SBC H
sbb   cl, bh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 09Dh   ; SBC L
sbb   cl, bl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 09Eh   ; SBC (HL)
sbb   cl, byte ptr ds:[bx]
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 09Fh   ; SBC A
sbb   cl, cl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0A0h   ; AND B
xchg  ax, bp
and   cl, ah
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0A1h   ; AND C
xchg  ax, bp
and   cl, al
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0A2h   ; AND D
and   cl, dh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0A3h   ; AND E
and   cl, dl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0A4h   ; AND H
and   cl, bh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0A5h   ; AND L
and   cl, bl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0A6h   ; AND (HL)
and   cl, byte ptr ds:[bx]
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0A7h   ; AND A
and   cl, cl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0A8h   ; XOR B
xchg  ax, bp
xor   cl, ah
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0A9h   ; XOR C
xchg  ax, bp
xor   cl, al
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0AAh   ; XOR D
xor   cl, dh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0ABh   ; XOR E
xor   cl, dl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0ACh   ; XOR H
xor   cl, bh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0ADh   ; XOR L
xor   cl, bl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0AEh   ; XOR (HL)
xor   cl, byte ptr ds:[bx]
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0AFh   ; XOR A
xor   cl, cl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0B0h   ; OR B
xchg  ax, bp
or    cl, ah
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0B1h   ; OR C
xchg  ax, bp
or    cl, al
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0B2h   ; OR D
or    cl, dh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0B3h   ; OR E
or    cl, dl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0B4h   ; OR H
or    cl, bh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0B5h   ; OR L
or    cl, bl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0B6h   ; OR (HL)
or    cl, byte ptr ds:[bx]
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0B7h   ; OR A
or    cl, cl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0B8h   ; CP B
xchg  ax, bp
cmp   cl, ah
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0B9h   ; CP C
xchg  ax, bp
cmp   cl, al
xchg  ax, bp
LOAD_NEXT_INSTRUCTION 1


OPCODE_DEFINE 0BAh   ; CP D
cmp    cl, dh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0BBh   ; CP E
cmp    cl, dl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0BCh   ; CP H
cmp    cl, bh
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0BDh   ; CP L
cmp    cl, bl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0BEh   ; CP (HL)
cmp    cl, byte ptr ds:[bx]
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0BFh   ; CP A
cmp    cl, cl
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0C0h   ; RET NZ
jnz    do_ret_nz
LOAD_NEXT_INSTRUCTION 2
do_ret_nz:
mov    si, word ptr ds:[di]
lea    di, [di + 2] ; pop off stack.
LOAD_NEXT_INSTRUCTION 5

OPCODE_DEFINE 0C1h   ; POP BC
mov    bp, word ptr ds:[di]
lea    di, [di + 2] ; pop off stack.
LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 0C2h   ; JP NZ, a16
lodsw
jnz   jp_a16_zero_flag_off
LOAD_NEXT_INSTRUCTION 3
jp_a16_zero_flag_off:
xchg ax, si
LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0C3h   ; JP a16
lodsw
xchg  ax, si
LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0C4h   ; CALL NZ, a16
lodsw
jnz   do_call_nz
LOAD_NEXT_INSTRUCTION 3
do_call_nz:
mov   word ptr ds:[di], si  ; store IP
lea   di, [di - 2] ; push to stack.
xchg  ax, si
LOAD_NEXT_INSTRUCTION 6

OPCODE_DEFINE 0C5h   ; PUSH BC
mov    word ptr ds:[di], bp
lea    di, [di - 2] ; push to stack.
LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0C6h   ; ADD A, d8
lodsb
add   cl, al
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0C7h   ; RST 0
mov   word ptr ds:[di], si  ; store IP
lea   di, [di - 2] ; push to stack.
mov   si, 0
LOAD_NEXT_INSTRUCTION 4


OPCODE_DEFINE 0C8h   ; RET Z
jz    do_ret_z
LOAD_NEXT_INSTRUCTION 2

do_ret_z:
mov   si, word ptr ds:[di]
lea   di, [di + 2] ; pop off stack.
LOAD_NEXT_INSTRUCTION 5

OPCODE_DEFINE 0C9h   ; RET
mov   si, word ptr ds:[di]
lea   di, [di + 2] ; pop off stack.


OPCODE_DEFINE 0CAh   ; JP Z, a16
lodsw
jz    jp_a16_zero_flag_on
LOAD_NEXT_INSTRUCTION 3
jp_a16_zero_flag_on:
xchg ax, si
LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0CBh   ; FIRST BYTE OF TWO BYTE CALL

; jump into core 2 
pop  ax
mov  ax, OFFSET FF_OPCODE_HANDLER_CORE2
push ax 


lodsb
mov  ah, al
mov  word ptr cs:[pointer_to_core_2], ax
jmp  dword ptr cs:[pointer_to_core_2]

pointer_to_core_2:
public pointer_to_core_2
dw CORE2_START, SEG CORE2 
BAD_OPCODE:
dw BAD_OPCODE_DETECTED, SEG INIT

OPCODE_DEFINE 0CCh   ; CALL Z, a16
lodsw
jz    do_call_z
LOAD_NEXT_INSTRUCTION 3

do_call_z:
mov   word ptr ds:[di], si  ; store IP
lea   di, [di - 2] ; push to stack.
xchg  ax, si
LOAD_NEXT_INSTRUCTION 6

OPCODE_DEFINE 0CDh   ; CALL a16
lodsw
mov   word ptr ds:[di], si  ; store IP
lea   di, [di - 2] ; push to stack.
xchg  ax, si
LOAD_NEXT_INSTRUCTION 6

OPCODE_DEFINE 0CEh   ; ADC A, d8
lodsb
adc  cl, al
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0CFh   ; RST 1
mov    word ptr ds:[di], si  ; store IP
lea    di, [di - 2] ; push to stack.
mov    si, 08h
LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0D0h   ; RET NC
jnc    do_ret_nc
LOAD_NEXT_INSTRUCTION 2
do_ret_nc:
mov    si, word ptr ds:[di]
lea    di, [di + 2] ; pop off stack.
LOAD_NEXT_INSTRUCTION 5

OPCODE_DEFINE 0D1h   ; POP DE
mov    dx, word ptr ds:[di]
lea    di, [di + 2] ; pop off stack.
LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 0D2h   ; JP NC, a16
lodsw
jnc   jp_a16_nc
LOAD_NEXT_INSTRUCTION 3
jp_a16_nc:
xchg ax, si
LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0D3h   ; xxxx
jmp   dword ptr cs:[BAD_OPCODE]

OPCODE_DEFINE 0D4h   ; CALL NC, a16
lodsw
jnc   do_call_nc
LOAD_NEXT_INSTRUCTION 3
do_call_nc:
mov   word ptr ds:[di], si  ; store IP
lea   di, [di - 2] ; push to stack.
xchg  ax, si
LOAD_NEXT_INSTRUCTION 6

OPCODE_DEFINE 0D5h   ; PUSH DE
mov    word ptr ds:[di], dx
lea    di, [di - 2] ; push to stack.
LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0D6h   ; SUB d8
lodsb
sub    cl, al
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0D7h   ; RST 2
mov    word ptr ds:[di], si  ; store IP
lea    di, [di - 2] ; push to stack.
mov    si, 010h
LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0D8h   ; RET C
jc     do_ret_c
LOAD_NEXT_INSTRUCTION 2
do_ret_c:
mov    si, word ptr ds:[di]
lea    di, [di + 2] ; pop off stack.
LOAD_NEXT_INSTRUCTION 5

OPCODE_DEFINE 0D9h   ; RETI
; TODO interrupt stuff
mov    si, word ptr ds:[di]
lea    di, [di + 2] ; pop off stack.
LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0DAh   ; JP C, a16
lodsw
jc    jp_a16_c
LOAD_NEXT_INSTRUCTION 3
jp_a16_c:
xchg ax, si
LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0DBh   ; xxxx
jmp   dword ptr cs:[BAD_OPCODE]

OPCODE_DEFINE 0DCh   ; CALL C, a16
lodsw
jc    do_call_c
LOAD_NEXT_INSTRUCTION 3
do_call_c:
mov   word ptr ds:[di], si  ; store IP
lea   di, [di - 2] ; push to stack.
xchg  ax, si
LOAD_NEXT_INSTRUCTION 6

OPCODE_DEFINE 0DDh   ; xxxx
jmp   dword ptr cs:[BAD_OPCODE]

OPCODE_DEFINE 0DEh   ; SBC A, d8
lodsb
sbb    cl, al
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0DFh   ; RST 3
mov    word ptr ds:[di], si  ; store IP
lea    di, [di - 2] ; push to stack.
mov    si, 018h
LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0E0h   ; LD (a8), A
lodsb
mov    ah, 0FFh
xchg   ax, bx
mov    byte ptr ds:[bx], cl
xchg   ax, bx
LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 0E1h   ; POP HL
mov    bx, word ptr ds:[di]
lea    di, [di + 2] ; pop off stack.
LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 0E2h   ; LD (C), A
mov    ax, bp
mov    ah, 0FFh
xchg   ax, bx
mov    byte ptr ds:[bx], cl
xchg   ax, bx
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0E3h   ; xxxx
jmp   dword ptr cs:[BAD_OPCODE]

OPCODE_DEFINE 0E4h   ; xxxx
jmp   dword ptr cs:[BAD_OPCODE]

OPCODE_DEFINE 0E5h   ; PUSH HL
mov    word ptr ds:[di], bx
lea    di, [di - 2] ; push to stack.
LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0E6h   ; AND d8
lodsb
and    cl, al
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0E7h   ; RST 4
mov    word ptr ds:[di], si  ; store IP
lea    di, [di - 2] ; push to stack.
mov    si, 020h
LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0E8h   ; ADD SP, s8
lodsb
cbw
add    di, ax
LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0E9h   ; JP HL
mov    si, bx
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0EAh   ; LD (a16), A
lodsw
xchg   ax, bx
mov    byte ptr ds:[bx], cl
xchg   ax, bx
LOAD_NEXT_INSTRUCTION 4


OPCODE_DEFINE 0EBh   ; xxxx
jmp   dword ptr cs:[BAD_OPCODE]

OPCODE_DEFINE 0ECh   ; xxxx
jmp   dword ptr cs:[BAD_OPCODE]

OPCODE_DEFINE 0EDh   ; xxxx
jmp   dword ptr cs:[BAD_OPCODE]

OPCODE_DEFINE 0EEh   ; XOR d8
lodsb
xor    cl, al
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0EFh   ; RST 5
mov    word ptr ds:[di], si  ; store IP
lea    di, [di - 2] ; push to stack.
mov    si, 028h
LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0F0h   ; LD A, (a8)
lodsb
mov    ah, 0FFh
xchg   ax, bx
mov    cl, byte ptr ds:[bx]
xchg   ax, bx
LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 0F1h   ; POP AF
mov    ax, word ptr ds:[di]
mov    cl, al
sahf
lea    di, [di + 2] ; pop off stack.
LOAD_NEXT_INSTRUCTION 3


OPCODE_DEFINE 0F2h   ; LD A, (C)
mov    ax, bp
mov    ah, 0FFh
xchg   ax, bx
mov    cl, byte ptr ds:[bx]
xchg   ax, bx
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0F3h   ; DI
; TODO interrupt stuff.
LOAD_NEXT_INSTRUCTION 1


OPCODE_DEFINE 0F4h   ; xxxx
jmp   dword ptr cs:[BAD_OPCODE]

OPCODE_DEFINE 0F5h   ; PUSH AF
mov    al, cl
lahf
mov    word ptr ds:[di], ax
lea    di, [di - 2] ; push to stack.
LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0F6h   ; OR d8
lodsb
or     cl, al
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0F7h   ; RST 6
mov    word ptr ds:[di], si  ; store IP
lea    di, [di - 2] ; push to stack.
mov    si, 030h
LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0F8h   ; LD HL, SP+s8
; todo flags
lodsb
cbw
xchg   ax, bx
lea    bx, [bx + di]
LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 0F9h   ; LD SP, HL
mov    di, bx
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0FAh   ; LD A, (a16)
lodsw
xchg   ax, bx
mov    cl, byte ptr ds:[bx]
xchg   ax, bx
LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 0FBh   ; EI
; TODO interrupt stuff.
LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0FCh   ; xxxx
jmp   dword ptr cs:[BAD_OPCODE]

OPCODE_DEFINE 0FDh   ; xxxx
jmp   dword ptr cs:[BAD_OPCODE]

OPCODE_DEFINE 0FEh   ; CP d8
lodsb
cmp    cl, al
LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0FFh   ; RST 7
retf
; todo...  int3? retf?






ENDS  ; CORE1


END