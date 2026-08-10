.8086
.MODEL medium
INCLUDE gb_defs.inc

EXTRN CORE2_START
EXTRN VARIABLE_BAD_OPCODE_handler
EXTRN VARIABLE_pointer_to_core_2
EXTRN VARIABLE_CYCLE_COUNT
EXTRN VARIABLE_pending_cycle_count
EXTRN VARIABLE_IME_flag

INIT SEGMENT
    ASSUME CS:INIT
ENDS
CORE2 SEGMENT
    ASSUME CS:CORE2
ENDS


COMMENT @
AX  = scratch
BX  = HL
CH  = H FLAG
CL  = A
BP  = BC
DX  = DE
DS  = emulated 64k space segment. 
SI  = PC
DI  = SP
SP  = (parent stack)
CS  = current emulator opcode processing core
ES  = ??
SS  = emulator init segment.
FLAGS emulate flags (ZF, AF, CF)
@


SEGMENT CORE1  USE16 PARA PUBLIC 'CODE'
ASSUME CS:CORE1


OPCODE_DEFINE 000h   ; NOP          ; Z- N- H- C-
    INCREMENT_CYCLES 1
    CORE1_START:
    public CORE1_START
    LOAD_NEXT_INSTRUCTION_NOCYCLES

OPCODE_DEFINE 001h   ; LD BC, d16   ; Z- N- H- C-
    lodsw
    xchg  ax, bp 
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 002h   ; LD (BC), A   ; Z- N- H- C-
    mov   byte ptr ds:[bp], cl
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 003h   ; INC BC       ; Z- N- H- C-
    lea  bp, [bp + 1]
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 004h   ; INC B        ; Z+ N0 H[3] C-
    xchg ax, bp
    inc  ah
    xchg ax, bp
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 005h   ; DEC B        ; Z+ N0 H[3] C-
    xchg ax, bp
    dec  ah
    xchg ax, bp
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 006h   ; LD B, d8     ; Z- N- H- C-
    ; a little gross.
    xchg ax, bp
    xchg al, ah
    lodsb
    xchg al, ah
    xchg ax, bp
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 007h   ; RLCA         ; Z0 N0 H0 C[7]
    test  ax, ax    ; clear flags, known to be 0707h 
    rol   cl, 1     ; set carry
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 008h   ; LD (a16), SP ; Z- N- H- C-
    lodsw
    xchg  ax, di
    mov   word ptr ds:[di], ax
    xchg  ax, di
    LOAD_NEXT_INSTRUCTION 5

OPCODE_DEFINE 009h   ; ADD HL, BC   ; Z- N0 H11 C15
    lahf
    mov  al, ah
    and  al, 040h ; preserve zero flag in al
    xchg ax, bp   ; BC into AX
    add  bl, al   ; add low bits
    adc  bh, ah   ; add high bits to get H flag from bit 11
    xchg ax, bp   ; BC into BP again
    lahf
    and  ah, 0BFh ; remove current zero flag
    or   ah, al    ; apply old zero flat
    sahf 
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 00Ah   ; LD A, (BC)   ; Z- N- H- C-
    mov   cl, byte ptr ds:[bp]
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 00Bh   ; DEC BC       ; Z- N- H- C-
    lea  bp, [bp - 1]
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 00Ch   ; INC C        ; Z+ N0 H[3] C-
    xchg ax, bp
    inc  al
    xchg ax, bp
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 00Dh   ; DEC C        ; Z+ N0 H[3] C-
    xchg ax, bp
    dec  al
    xchg ax, bp
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 00Eh   ; LD C, d8     ; Z- N- H- C-
    xchg ax, bp
    lodsb
    xchg ax, bp
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 00Fh   ; RRCA         ; Z0 N0 H0 C[0]
    test  ax, ax    ; clear flags, known to be 0F0Fh 
    ror   cl, 1     ; set carry
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 010h   ; STOP         ; Z- N- H- C-
    ; TODO.
    mov   byte ptr ds:[0FF04h], 0 ; reset timer

    jmp   dword ptr ss:[VARIABLE_BAD_OPCODE_handler]
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 011h   ; LD DE, d16   ; Z- N- H- C-
    lodsw
    xchg  ax, dx
    LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 012h   ; LD (DE), A   ; Z- N- H- C-
    xchg  dx, bx
    mov   byte ptr ds:[bx], cl
    xchg  dx, bx
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 013h   ; INC DE       ; Z- N- H- C-
    xchg dx, bp
    lea  bp, [bp + 1]
    xchg dx, bp
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 014h   ; INC D        ; Z+ N0 H[3] C-
    inc   dh
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 015h   ; DEC D        ; Z+ N0 H[3] C-
    dec   dh
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 016h   ; LD D, d8     ; Z- N- H- C-
    lodsb
    mov   dh, al
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 017h   ; RLA          ; Z0 N0 H0 C[7]
    rcl   cl, 1     ; thanks zero318
    sbb   al, al    ; 0 if nc, ff if c
    add   al, 010h  ; zf 0, af 0, cf if c
    SET_N_FLAG_OFF  
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 018h   ; JR s8        ; Z- N- H- C-
    lodsb
    cbw
    xchg ax, bx
    lea  si, [si + bx]
    xchg ax, bx
    lahf
    cmp  al, 0FEh 
    je   infinite_loop_exit_emulator 
    sahf
    LOAD_NEXT_INSTRUCTION 3

    infinite_loop_exit_emulator:
    sahf
    jmp   dword ptr ss:[VARIABLE_BAD_OPCODE_handler]


OPCODE_DEFINE 019h   ; ADD HL, DE   ; Z- N0 H11 C15
    lahf
    mov  al, ah
    and  al, 040h ; preserve zero flag in al
    add  bl, dl   ; add low bits
    adc  bh, dh   ; add high bits to get H flag from bit 11
    lahf
    and  ah, 0BFh ; remove current zero flag
    or   ah, al    ; apply old zero flat
    sahf 
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 01Ah   ; LD A, (DE)   ; Z- N- H- C-
    xchg bx, dx
    mov  cl, byte ptr ds:[bx]
    xchg bx, dx
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 01Bh   ; DEC DE       ; Z- N- H- C-
    xchg dx, bp
    lea  bp, [bp - 1]
    xchg dx, bp
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 01Ch   ; INC E        ; Z+ N0 H[3] C-
    inc  dl
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 01Dh   ; DEC E        ; Z+ N0 H[3] C-
    dec  dl
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 01Eh   ; LD E, d8     ; Z- N- H- C-
    lodsb
    mov    dl, al
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 01Fh   ; RRA          ; Z0 N0 H0 C[0]
    rcr   cl, 1     ; thanks zero318
    sbb   al, al    ; 0 if nc, ff if c
    add   al, 010h  ; zf 0, af 0, cf if c
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 020h   ; JR NZ, s8    ; Z- N- H- C-
    lodsb
    jnz   jr_zero_flag_off
    LOAD_NEXT_INSTRUCTION 2
    jr_zero_flag_off:
    cbw
    xchg ax, bx
    lea  si, [bx + si]
    xchg ax, bx
    LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 021h   ; LD HL, d16   ; Z- N- H- C-
    lodsw
    xchg  ax, bx
    LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 022h   ; LD (HL+), A  ; Z- N- H- C-
    mov   byte ptr ds:[bx], cl
    lea   bx, [bx + 1]
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 023h   ; INC HL       ; Z- N- H- C-
    lea  bx, [bx + 1]
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 024h   ; INC H        ; Z+ N0 H[3] C-
    inc   bh
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 025h   ; DEC H        ; Z+ N0 H[3] C-
    dec   bh
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 026h   ; LD H, d8     ; Z- N- H- C-
    lodsb
    mov   bh, al
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 027h   ; DAA          ; Z+ N- H0 C[7]
COMMENT @
    test ch, N_FLAG_BIT 
    jz   cleared_N
    set_N:
      LAHF
      MOV AL, 0
      DAS
      ADD CL, AL
      TEST CL, CL ; output ZF, clear AF
      ROR AH, 1 ; preserve CF
      LOAD_NEXT_INSTRUCTION 1

    cleared_N:
      XCHG AX, CX
      DAA ; output ZF/CF
      XCHG AX, CX
      LAHF
      AND AH, 0EFh ; clear AF
      SAHF

      LOAD_NEXT_INSTRUCTION 1
    @

    lahf
    test  ah, 1   ; test carry flag
    mov   al, 0
    xchg  ax, cx     ; ch = flags, ah = N. cl is value to add.
    jnz   daa_c_flag_on
    test  ah, N_FLAG_BIT
    jnz   skip_daa_high_digit_adjust ; skip if sub flag on
    cmp   al, 099h
    jbe   skip_daa_high_digit_adjust
    daa_c_flag_on:
    mov   cl, 060h
    inc   byte ptr cs:[SELFMODIFY_set_carry_flag+2]
    skip_daa_high_digit_adjust:


    test  ch, 10h    ; test AF
    mov   ch, al ; backup old digit
    jnz   daa_af_flag_on
    test  ah, N_FLAG_BIT
    jnz   sub_difference ; skip if sub flag on
    and   al, 0Fh
    cmp   al, 9
    jbe   skip_daa_low_digit_adjust
    daa_af_flag_on:
    add   cl, 6
    skip_daa_low_digit_adjust:

    ; add back value.

    ; set carry flag if cl
    test  ah, N_FLAG_BIT
    jz    add_difference
    sub_difference:
    neg   cl
    add_difference:
    add   cl, ch  ; ch has accumulator backup, cl has amount to add. cl is new accumulator.
    finished_daa_result:
    mov   ch, ah  ; restore N Flag
    mov   ah, 0   ; flags set
    jnz   dont_set_zero
    or    ah, 040h  ; set zero flag
    dont_set_zero:
    SELFMODIFY_set_carry_flag:
    or    ah, 0  ; set new carry flag. IDEA: inc ah vs nops?
    mov   byte ptr cs:[SELFMODIFY_set_carry_flag+2], 0  ; gross.
    sahf

    ; N flag left alone.
    ; zero flag set if zero
    LOAD_NEXT_INSTRUCTION 1
    

OPCODE_DEFINE 028h   ; JR Z, s8     ; Z- N- H- C-
    lodsb
    jz   jr_zero_flag_on
      LOAD_NEXT_INSTRUCTION 2
    jr_zero_flag_on:
      cbw
      xchg ax, bx
      lea  si, [bx + si]
      xchg ax, bx
      LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 029h   ; ADD HL, HL   ; Z- N0 H[11] C[15]
    lahf
    mov  al, ah
    and  al, 040h ; preserve zero flag in al
    add  bl, bl   ; add low bits
    adc  bh, bh   ; add high bits to get H flag from bit 11
    lahf
    and  ah, 0BFh ; remove current zero flag
    or   ah, al    ; apply old zero flat
    sahf 
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 02Ah   ; LD A, (HL+)  ; Z- N- H- C-
    mov  cl, byte ptr ds:[bx]
    lea  bx, [bx + 1]
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 02Bh   ; DEC HL       ; Z- N- H- C-
    lea  bx, [bx - 1]
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 02Ch   ; INC L        ; Z+ N0 H[3] C-
    inc  bl
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 02Dh   ; DEC L        ; Z+ N0 H[3] C-
    dec  bl
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 02Eh   ; LD L, d8     ; Z- N- H- C-
    lodsb
    mov  bl, al
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 02Fh   ; CPL          ; Z- N1 H1 C-
    not  cl  
    lahf
    or   ah, 010h  ; set ah to 1..
    sahf
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 030h   ; JR NC, s8    ; Z- N- H- C-
    lodsb
    jnc   jr_carry_flag_off
      LOAD_NEXT_INSTRUCTION 2
    jr_carry_flag_off:
      cbw
      xchg ax, bx
      lea  si, [bx + si]
      xchg ax, bx
      LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 031h   ; LD SP, d16   ; Z- N- H- C-
    lodsw
    xchg  ax, di
    LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 032h   ; LD (HL-), A  ; Z- N- H- C-
    mov  byte ptr ds:[bx], cl
    lea  bx, [bx - 1]
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 033h   ; INC SP       ; Z- N- H- C-
    lea  di, [di + 1]
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 034h   ; INC (HL)     ; Z+ N0 H[3] C-
    inc  byte ptr ds:[bx]
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 035h   ; DEC (HL)     ; Z+ N0 H[3] C-
    dec  byte ptr ds:[bx]
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 036h   ; LD (HL), d8  ; Z- N- H- C-
    lodsb
    mov   byte ptr ds:[bx], al
    LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 037h   ; SCF          ; Z- N0 H0 C[7]
    lahf
    and   ah, 0EFh       ; turn off AF
    sahf
    stc                  ; set carry flag
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 038h   ; JR C, s8     ; Z- N- H- C-
    lodsb
    jc   jr_carry_flag_on
      LOAD_NEXT_INSTRUCTION 2
    jr_carry_flag_on:
      cbw
      xchg ax, bx
      lea  si, [bx + si]
      xchg ax, bx
      LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 039h   ; ADD HL, SP   ; Z- N0 H11 C15
    lahf
    mov  al, ah
    and  al, 040h ; preserve zero flag in al
    xchg ax, di   ; SP into AX 
    add  bl, al   ; add low bits
    adc  bh, ah   ; add high bits to get H flag from bit 11
    xchg ax, di   ; SP back into DI
    lahf
    and  ah, 0BFh ; remove current zero flag
    or   ah, al    ; apply old zero flat
    sahf 
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 03Ah   ; LD A, (HL-)   ; Z- N- H- C-
    mov  cl, byte ptr ds:[bx]
    lea  bx, [bx - 1]
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 03Bh   ; DEC SP       ; Z- N- H- C-
    lea  di, [di - 1]
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 03Ch   ; INC A        ; Z+ N0 H[3] C-
    inc   cl
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 03Dh   ; DEC A        ; Z+ N0 H[3] C-
    dec   cl
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 03Eh   ; LD A, d8     ; Z- N- H- C-
    lodsb
    mov   cl, al
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 03Fh   ; CCF          ; Z- N0 H0 C[7]
    lahf
    and   ah, 0EFh  ; turn off AF
    sahf
    cmc             ; flip carry flag
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 040h   ; LD B, B      ; Z- N- H- C-
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 041h   ; LD B, C      ; Z- N- H- C-
    xchg  ax, bp
    mov   ah, al
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 042h   ; LD B, D      ; Z- N- H- C-
    xchg  ax, bp
    mov   ah, dh
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 043h   ; LD B, E      ; Z- N- H- C-
    xchg  ax, bp
    mov   ah, dl
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 044h   ; LD B, H      ; Z- N- H- C-
    xchg  ax, bp
    mov   ah, bh
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 045h   ; LD B, L      ; Z- N- H- C-
    xchg  ax, bp
    mov   ah, bl
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 046h   ; LD B, (HL)   ; Z- N- H- C-
    xchg  ax, bp
    mov   ah, byte ptr ds:[bx]
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 047h   ; LD B, A      ; Z- N- H- C-
    xchg  ax, bp
    mov   ah, cl
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 048h   ; LD C, B      ; Z- N- H- C-
    xchg  ax, bp
    mov   al, ah
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 049h   ; LD C, C      ; Z- N- H- C-
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 04Ah   ; LD C, D      ; Z- N- H- C-
    xchg  ax, bp
    mov   al, dh
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 04Bh   ; LD C, E      ; Z- N- H- C-
    xchg  ax, bp
    mov   al, dl
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 04Ch   ; LD C, H      ; Z- N- H- C-
    xchg  ax, bp
    mov   al, bh
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 04Dh   ; LD C, L      ; Z- N- H- C-
    xchg  ax, bp
    mov   al, bl
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 04Eh   ; LD C, (HL)   ; Z- N- H- C-
    xchg  ax, bp
    mov   al, byte ptr ds:[bx]
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 04Fh   ; LD C, A      ; Z- N- H- C-
    xchg  ax, bp
    mov   al, cl
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 050h   ; LD D, B      ; Z- N- H- C-
    xchg  ax, bp
    mov   dh, ah
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 051h   ; LD D, C      ; Z- N- H- C-
    xchg  ax, bp
    mov   dh, al
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 052h   ; LD D, D      ; Z- N- H- C-
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 053h   ; LD D, E      ; Z- N- H- C-
    mov   dh, dl
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 054h   ; LD D, H      ; Z- N- H- C-
    mov   dh, bh
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 055h   ; LD D, L      ; Z- N- H- C-
    mov   dh, bl
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 056h   ; LD D, (HL)   ; Z- N- H- C-
    mov   dh, byte ptr ds:[bx]
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 057h   ; LD D, A      ; Z- N- H- C-
    mov   dh, cl
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 058h   ; LD E, B      ; Z- N- H- C-
    xchg  ax, bp
    mov   dl, ah
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 059h   ; LD E, C      ; Z- N- H- C-
    xchg  ax, bp
    mov   dl, al
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 05Ah   ; LD E, D      ; Z- N- H- C-
    mov   dl, dh
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 05Bh   ; LD E, E      ; Z- N- H- C-
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 05Ch   ; LD E, H      ; Z- N- H- C-
    mov   dl, bh
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 05Dh   ; LD E, L      ; Z- N- H- C-
    mov   dl, bl
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 05Eh   ; LD E, (HL)   ; Z- N- H- C-
    mov   dl, byte ptr ds:[bx]
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 05Fh   ; LD E, A      ; Z- N- H- C-
    mov   dl, cl
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 060h   ; LD H, B      ; Z- N- H- C-
    xchg  ax, bp
    mov   bh, ah
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 061h   ; LD H, C      ; Z- N- H- C-
    xchg  ax, bp
    mov   bh, al
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 062h   ; LD H, D      ; Z- N- H- C-
    mov   bh, dh
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 063h   ; LD H, E      ; Z- N- H- C-
    mov   bh, dl
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 064h   ; LD H, H      ; Z- N- H- C-
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 065h   ; LD H, L      ; Z- N- H- C-
    mov   bh, bl
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 066h   ; LD H, (HL)   ; Z- N- H- C-
    mov   bh, byte ptr ds:[bx]
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 067h   ; LD H, A      ; Z- N- H- C-
    mov   bh, cl
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 068h   ; LD L, B      ; Z- N- H- C-
    xchg  ax, bp
    mov   bl, ah
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 069h   ; LD L, C      ; Z- N- H- C-
    xchg  ax, bp
    mov   bl, al
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 06Ah   ; LD L, D      ; Z- N- H- C-
    mov   bl, dh
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 06Bh   ; LD L, E      ; Z- N- H- C-
    mov   bl, dl
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 06Ch   ; LD L, H      ; Z- N- H- C-
    mov   bl, bh
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 06Dh   ; LD L, L      ; Z- N- H- C-
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 06Eh   ; LD L, (HL)   ; Z- N- H- C-
    mov   bl, byte ptr ds:[bx]
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 06Fh   ; LD L, A      ; Z- N- H- C-
    mov   bl, cl
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 070h   ; LD (HL), B   ; Z- N- H- C-
    xchg  ax, bp
    mov   byte ptr ds:[bx], ah
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 071h   ; LD (HL), C   ; Z- N- H- C-
    xchg  ax, bp
    mov   byte ptr ds:[bx], al
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 072h   ; LD (HL), D   ; Z- N- H- C-
    mov   byte ptr ds:[bx], dh
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 073h   ; LD (HL), E   ; Z- N- H- C-
    mov   byte ptr ds:[bx], dl
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 074h   ; LD (HL), H   ; Z- N- H- C-
    mov   byte ptr ds:[bx], bh
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 075h   ; LD (HL), L   ; Z- N- H- C-
    mov   byte ptr ds:[bx],  bl
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 076h   ; HALT         ; Z- N- H- C-
    ; TODO
    ; burn cycles until interrupt?
    jmp   dword ptr ss:[VARIABLE_BAD_OPCODE_handler]
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 077h   ; LD (HL), A   ; Z- N- H- C-
    mov   byte ptr ds:[bx], cl
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 078h   ; LD A, B      ; Z- N- H- C-
    xchg  ax, bp
    mov   cl, ah
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 079h   ; LD A, C      ; Z- N- H- C-
    xchg  ax, bp
    mov   cl, al
    xchg  ax, bp
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 07Ah   ; LD A, D      ; Z- N- H- C-
    mov   cl, dh
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 07Bh   ; LD A, E      ; Z- N- H- C-
    mov   cl, dl
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 07Ch   ; LD A, H      ; Z- N- H- C-
    mov   cl, bh
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 07Dh   ; LD A, L      ; Z- N- H- C-
    mov   cl, bl
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 07Eh   ; LD A, (HL)   ; Z- N- H- C-
    mov   cl, byte ptr ds:[bx]
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 07Fh   ; LD A, A      ; Z- N- H- C-
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 080h   ; ADD A, B     ; Z+ N0 H[3] C[7]
    xchg  ax, bp
    add   cl, ah
    xchg  ax, bp
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 081h   ; ADD A, C     ; Z+ N0 H[3] C[7]
    xchg  ax, bp
    add   cl, al
    xchg  ax, bp
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 082h   ; ADD A, D     ; Z+ N0 H[3] C[7]
    add   cl, dh
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 083h   ; ADD A, E     ; Z+ N0 H[3] C[7]
    add   cl, dl
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 084h   ; ADD A, H     ; Z+ N0 H[3] C[7]
    add   cl, bh
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 085h   ; ADD A, L     ; Z+ N0 H[3] C[7]
    add   cl, bl
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 086h   ; ADD A, (HL)  ; Z+ N0 H[3] C[7]
    add   cl, byte ptr ds:[bx]
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 087h   ; ADD A, A     ; Z+ N0 H[3] C[7]
    add   cl, cl
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 088h   ; ADC A, B     ; Z+ N0 H[3] C[7]
    xchg  ax, bp
    adc   cl, ah
    xchg  ax, bp
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 089h   ; ADC A, C     ; Z+ N0 H[3] C[7]
    xchg  ax, bp
    adc   cl, al
    xchg  ax, bp
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 08Ah   ; ADC A, D     ; Z+ N0 H[3] C[7]
    adc   cl, dh
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 08Bh   ; ADC A, E     ; Z+ N0 H[3] C[7]
    adc   cl, dl
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 08Ch   ; ADC A, H     ; Z+ N0 H[3] C[7]
    adc   cl, bh
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 08Dh   ; ADC A, L     ; Z+ N0 H[3] C[7]
    adc   cl, bl
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 08Eh   ; ADD AC (HL)  ; Z+ N0 H[3] C[7]
    adc   cl, byte ptr ds:[bx]
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 08Fh   ; ADC A, A     ; Z+ N0 H[3] C[7]
    adc   cl, cl
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 090h   ; SUB B        ; Z+ N1 H[3] C[7]
    xchg  ax, bp
    sub   cl, ah
    xchg  ax, bp
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 091h   ; SUB C        ; Z+ N1 H[3] C[7]
    xchg  ax, bp
    sub   cl, al
    xchg  ax, bp
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 092h   ; SUB D        ; Z+ N1 H[3] C[7]
    sub   cl, dh
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 093h   ; SUB E        ; Z+ N1 H[3] C[7]
    sub   cl, dl
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 094h   ; SUB H        ; Z+ N1 H[3] C[7]
    sub   cl, bh
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 095h   ; SUB L        ; Z+ N1 H[3] C[7]
    sub   cl, bl
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 096h   ; SUB (HL)     ; Z+ N1 H[3] C[7]
    sub   cl, byte ptr ds:[bx]
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 097h   ; SUB A        ; Z+ N1 H[3] C[7]
    sub   cl, cl
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 098h   ; SBC B        ; Z+ N1 H[3] C[7]
    xchg  ax, bp
    sbb   cl, ah
    xchg  ax, bp
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 099h   ; SBC C        ; Z+ N1 H[3] C[7]
    xchg  ax, bp
    sbb   cl, al
    xchg  ax, bp
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 09Ah   ; SBC D        ; Z+ N1 H[3] C[7]
    sbb   cl, dh
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 09Bh   ; SBC E        ; Z+ N1 H[3] C[7]
    sbb   cl, dl
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 09Ch   ; SBC H        ; Z+ N1 H[3] C[7]
    sbb   cl, bh
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 09Dh   ; SBC L        ; Z+ N1 H[3] C[7]
    sbb   cl, bl
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 09Eh   ; SBC (HL)     ; Z+ N1 H[3] C[7]
    sbb   cl, byte ptr ds:[bx]
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 09Fh   ; SBC A        ; Z+ N1 H[3] C[7]
    sbb   cl, cl
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0A0h   ; AND B        ; Z+ N0 H1 C0
    xchg  ax, bp
    and   cl, ah
    xchg  ax, bp
    lahf
    or    ah, 010h       ; turn on AF
    sahf
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0A1h   ; AND C        ; Z+ N0 H1 C0
    xchg  ax, bp
    and   cl, al
    xchg  ax, bp
    lahf
    or    ah, 010h       ; turn on AF
    sahf
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0A2h   ; AND D        ; Z+ N0 H1 C0
    and   cl, dh
    lahf
    or    ah, 010h       ; turn on AF
    sahf
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0A3h   ; AND E        ; Z+ N0 H1 C0
    and   cl, dl
    lahf
    or    ah, 010h       ; turn on AF
    sahf
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0A4h   ; AND H        ; Z+ N0 H1 C0
    and   cl, bh
    lahf
    or    ah, 010h       ; turn on AF
    sahf
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0A5h   ; AND L        ; Z+ N0 H1 C0
    and   cl, bl
    lahf
    or    ah, 010h       ; turn on AF
    sahf
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0A6h   ; AND (HL)     ; Z+ N0 H1 C0
    and   cl, byte ptr ds:[bx]
    lahf
    or    ah, 010h       ; turn on AF
    sahf
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0A7h   ; AND A        ; Z+ N0 H1 C0
    and   cl, cl
    lahf
    or    ah, 010h       ; turn on AF
    sahf
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0A8h   ; XOR B        ; Z+ N0 H0 C0
    xchg  ax, bp
    xor   cl, ah
    xchg  ax, bp
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0A9h   ; XOR C        ; Z+ N0 H0 C0
    xchg  ax, bp
    xor   cl, al
    xchg  ax, bp
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0AAh   ; XOR D        ; Z+ N0 H0 C0
    xor   cl, dh
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0ABh   ; XOR E        ; Z+ N0 H0 C0
    xor   cl, dl
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0ACh   ; XOR H        ; Z+ N0 H0 C0
    xor   cl, bh
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0ADh   ; XOR L        ; Z+ N0 H0 C0
    xor   cl, bl
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0AEh   ; XOR (HL)     ; Z+ N0 H0 C0
    xor   cl, byte ptr ds:[bx]
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0AFh   ; XOR A        ; Z+ N0 H0 C0
    xor   cl, cl
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0B0h   ; OR B        ; Z+ N0 H0 C0
    xchg  ax, bp
    or    cl, ah
    xchg  ax, bp
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0B1h   ; OR C        ; Z+ N0 H0 C0
    xchg  ax, bp
    or    cl, al
    xchg  ax, bp
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0B2h   ; OR D        ; Z+ N0 H0 C0
    or    cl, dh
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0B3h   ; OR E        ; Z+ N0 H0 C0
    or    cl, dl
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0B4h   ; OR H        ; Z+ N0 H0 C0
    or    cl, bh
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0B5h   ; OR L        ; Z+ N0 H0 C0
    or    cl, bl
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0B6h   ; OR (HL)     ; Z+ N0 H0 C0
    or    cl, byte ptr ds:[bx]
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0B7h   ; OR A        ; Z+ N0 H0 C0
    or    cl, cl
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0B8h   ; CP B        ; Z+ N1 H[3] C[7]
    xchg  ax, bp
    cmp   cl, ah
    xchg  ax, bp
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0B9h   ; CP C        ; Z+ N1 H[3] C[7]
    xchg  ax, bp
    cmp   cl, al
    xchg  ax, bp
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0BAh   ; CP D        ; Z+ N1 H[3] C[7]
    cmp    cl, dh
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0BBh   ; CP E        ; Z+ N1 H[3] C[7]
    cmp    cl, dl
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0BCh   ; CP H        ; Z+ N1 H[3] C[7]
    cmp    cl, bh
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0BDh   ; CP L        ; Z+ N1 H[3] C[7]
    cmp    cl, bl
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0BEh   ; CP (HL)     ; Z+ N1 H[3] C[7]
    cmp    cl, byte ptr ds:[bx]
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0BFh   ; CP A        ; Z+ N1 H[3] C[7]
    cmp    cl, cl
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0C0h   ; RET NZ       ; Z- N- H- C-
    jnz    do_ret_nz
      LOAD_NEXT_INSTRUCTION 2
    do_ret_nz:
      mov    si, word ptr ds:[di]
      lea    di, [di + 2] ; pop off stack.
      LOAD_NEXT_INSTRUCTION 5

OPCODE_DEFINE 0C1h   ; POP BC       ; Z- N- H- C-
    mov    bp, word ptr ds:[di]
    lea    di, [di + 2] ; pop off stack.
    LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 0C2h   ; JP NZ, a16   ; Z- N- H- C-
    lodsw
    jnz   jp_a16_zero_flag_off
      LOAD_NEXT_INSTRUCTION 3
    jp_a16_zero_flag_off:
      xchg ax, si
      LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0C3h   ; JP a16       ; Z- N- H- C-
    lodsw
    xchg  ax, si
    LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0C4h   ; CALL NZ, a16 ; Z- N- H- C-
    lodsw
    jnz   do_call_nz
      LOAD_NEXT_INSTRUCTION 3
    do_call_nz:
      lea   di, [di - 2] ; push to stack.
      xchg  ax, si
      mov   word ptr ds:[di], ax  ; store IP
      LOAD_NEXT_INSTRUCTION 6

OPCODE_DEFINE 0C5h   ; PUSH BC      ; Z- N- H- C-
    lea    di, [di - 2] ; push to stack.
    mov    word ptr ds:[di], bp
    LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0C6h   ; ADD A, d8    ; Z+ N0 H[3] C[7]
    lodsb
    add   cl, al
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0C7h   ; RST 0        ; Z- N- H- C-
    lea   di, [di - 2] ; push to stack.
    mov   word ptr ds:[di], si  ; store IP
    mov   si, 0
    LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0C8h   ; RET Z        ; Z- N- H- C-
    jz    do_ret_z
      LOAD_NEXT_INSTRUCTION 2
    do_ret_z:
      mov   si, word ptr ds:[di]
      lea   di, [di + 2] ; pop off stack.
      LOAD_NEXT_INSTRUCTION 5

OPCODE_DEFINE 0C9h   ; RET          ; Z- N- H- C-
    mov   si, word ptr ds:[di]
    lea   di, [di + 2] ; pop off stack.
    LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0CAh   ; JP Z, a16    ; Z- N- H- C-
    lodsw
    jz    jp_a16_zero_flag_on
      LOAD_NEXT_INSTRUCTION 3
    jp_a16_zero_flag_on:
      xchg ax, si
      LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0CBh   ; FIRST BYTE OF TWO BYTE CALL
    ; jump into core 2 
    lodsb
    mov  ah, al
    mov  word ptr ss:[VARIABLE_pointer_to_core_2], ax
    jmp  dword ptr ss:[VARIABLE_pointer_to_core_2]


OPCODE_DEFINE 0CCh   ; CALL Z, a16  ; Z- N- H- C-
    lodsw
    jz    do_call_z
      LOAD_NEXT_INSTRUCTION 3
    do_call_z:
      lea   di, [di - 2] ; push to stack.
      xchg  ax, si
      mov   word ptr ds:[di], ax  ; store IP
      LOAD_NEXT_INSTRUCTION 6

OPCODE_DEFINE 0CDh   ; CALL a16     ; Z- N- H- C-
    lodsw
    lea   di, [di - 2] ; push to stack.
    xchg  ax, si
    mov   word ptr ds:[di], ax  ; store IP
    LOAD_NEXT_INSTRUCTION 6

OPCODE_DEFINE 0CEh   ; ADC A, d8    ; Z+ N0 H[3] C[7]
    lodsb
    adc  cl, al
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0CFh   ; RST 1        ; Z- N- H- C-
    lea    di, [di - 2] ; push to stack.
    mov    word ptr ds:[di], si  ; store IP
    mov    si, 08h
    LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0D0h   ; RET NC       ; Z- N- H- C-
    jnc    do_ret_nc
      LOAD_NEXT_INSTRUCTION 2
    do_ret_nc:
      mov    si, word ptr ds:[di]
      lea    di, [di + 2] ; pop off stack.
      LOAD_NEXT_INSTRUCTION 5

OPCODE_DEFINE 0D1h   ; POP DE       ; Z- N- H- C-
    mov    dx, word ptr ds:[di]
    lea    di, [di + 2] ; pop off stack.
    LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 0D2h   ; JP NC, a16   ; Z- N- H- C-
    lodsw
    jnc   jp_a16_nc
      LOAD_NEXT_INSTRUCTION 3
    jp_a16_nc:
      xchg ax, si
      LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0D3h   ; xxxx         ; Z- N- H- C-
    jmp   dword ptr ss:[VARIABLE_BAD_OPCODE_handler]
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0D4h   ; CALL NC, a16 ; Z- N- H- C-
    lodsw
    jnc   do_call_nc
      LOAD_NEXT_INSTRUCTION 3
    do_call_nc:
      lea   di, [di - 2] ; push to stack.
      xchg  ax, si
      mov   word ptr ds:[di], ax  ; store IP
      LOAD_NEXT_INSTRUCTION 6

OPCODE_DEFINE 0D5h   ; PUSH DE      ; Z- N- H- C-
    lea    di, [di - 2] ; push to stack.
    mov    word ptr ds:[di], dx
    LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0D6h   ; SUB d8       ; Z+ N1 H[3] C[7]
    lodsb
    sub    cl, al
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0D7h   ; RST 2        ; Z- N- H- C-
    lea    di, [di - 2] ; push to stack.
    mov    word ptr ds:[di], si  ; store IP
    mov    si, 010h
    LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0D8h   ; RET C         ; Z- N- H- C-
    jc     do_ret_c
      LOAD_NEXT_INSTRUCTION 2
    do_ret_c:
      mov    si, word ptr ds:[di]
      lea    di, [di + 2] ; pop off stack.
      LOAD_NEXT_INSTRUCTION 5

OPCODE_DEFINE 0D9h   ; RETI         ; Z- N- H- C-
    ; TODO interrupt stuff
    mov    si, word ptr ds:[di]
    lea    di, [di + 2] ; pop off stack.
    LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0DAh   ; JP C, a16    ; Z- N- H- C-
    lodsw
    jc    jp_a16_c
      LOAD_NEXT_INSTRUCTION 3
    jp_a16_c:
      xchg ax, si
      LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0DBh   ; xxxx         ; Z- N- H- C-
    jmp   dword ptr ss:[VARIABLE_BAD_OPCODE_handler]
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0DCh   ; CALL C, a16  ; Z- N- H- C-
    lodsw
    jc    do_call_c
      LOAD_NEXT_INSTRUCTION 3
    do_call_c:
      lea   di, [di - 2] ; push to stack.
      xchg  ax, si
      mov   word ptr ds:[di], ax  ; store IP
      LOAD_NEXT_INSTRUCTION 6

OPCODE_DEFINE 0DDh   ; xxxx         ; Z- N- H- C-
    jmp   dword ptr ss:[VARIABLE_BAD_OPCODE_handler]
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0DEh   ; SBC A, d8    ; Z+ N1 H[3] C[7]
    lodsb
    sbb    cl, al
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0DFh   ; RST 3        ; Z- N- H- C-
    lea    di, [di - 2] ; push to stack.
    mov    word ptr ds:[di], si  ; store IP
    mov    si, 018h
    LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0E0h   ; LD (a8), A   ; Z- N- H- C-
    lodsb
    mov    ah, 0FFh
    xchg   ax, bx
    mov    byte ptr ds:[bx], cl ; todo write after test
    xchg   ax, bx
    lahf
    test  al, al
    jns   handle_io_write_0
    sahf    
    LOAD_NEXT_INSTRUCTION 3
  handle_io_write_0:
    sahf
    mov   ah, al
    mov   al, IO_WRITE_OFFSET
    mov   word ptr ss:[VARIABLE_pending_cycle_count], 3
    jmp   ax  ; IO handler 

OPCODE_DEFINE 0E1h   ; POP HL       ; Z- N- H- C-
    mov    bx, word ptr ds:[di]
    lea    di, [di + 2] ; pop off stack.
    LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 0E2h   ; LD (C), A    ; Z- N- H- C-
    mov    ax, bp
    mov    ah, 0FFh
    xchg   ax, bx
    mov    byte ptr ds:[bx], cl ; todo write after test
    xchg   ax, bx
    lahf
    test  al, al
    jns   handle_io_write_1
    sahf    
    LOAD_NEXT_INSTRUCTION 2
  handle_io_write_1:
    sahf
    mov   ah, al
    mov   al, IO_WRITE_OFFSET
    mov   word ptr ss:[VARIABLE_pending_cycle_count], 2
    jmp   ax  ; IO handler 

OPCODE_DEFINE 0E3h   ; xxxx         ; Z- N- H- C-
    jmp   dword ptr ss:[VARIABLE_BAD_OPCODE_handler]
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0E4h   ; xxxx         ; Z- N- H- C-
    jmp   dword ptr ss:[VARIABLE_BAD_OPCODE_handler]
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0E5h   ; PUSH HL      ; Z- N- H- C-
    lea    di, [di - 2] ; push to stack.
    mov    word ptr ds:[di], bx
    LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0E6h   ; AND d8        ; Z+ N0 H1 C[7]
    lodsb
    and    cl, al
    lahf
    or     ah, 010h      ; turn on AF
    sahf
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0E7h   ; RST 4        ; Z- N- H- C-
    lea    di, [di - 2] ; push to stack.
    mov    word ptr ds:[di], si  ; store IP
    mov    si, 020h
    LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0E8h   ; ADD SP, s8   ; Z0 N0 H[3] C[7]
    lodsb
    cbw             ; sign bits into ah
    xchg   di, cx   ; SP into cx
    add    cl, al   ; add lo bits
    mov    al, ah   ; back up sign bits
    lahf            ; get AF, CF
    adc    ch, al
    xchg   di, cx   ; put SP back in DI
    and    ah, 0BFH ; Z flag off
    sahf            ; set sign bits
    SET_N_FLAG_OFF  ; N flag off
    LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0E9h   ; JP HL        ; Z- N- H- C-
    mov    si, bx
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0EAh   ; LD (a16), A  ; Z- N- H- C-
    lodsw
    xchg  ax, bx
    mov   byte ptr ds:[bx], cl
    xchg  ax, bx
    mov   al, ah
    lahf
    inc   al
    jz    check_lo_byte_write ; todo write after test
    not_io_write:
    sahf
    LOAD_NEXT_INSTRUCTION 4
  check_lo_byte_write:
    mov   al, byte ptr ds:[si-2]
    test  al, al
    js    not_io_write
    sahf
    mov   ah, al
    mov   al, IO_WRITE_OFFSET
    mov   word ptr ss:[VARIABLE_pending_cycle_count], 4
    jmp   ax

OPCODE_DEFINE 0EBh   ; xxxx         ; Z- N- H- C-
    jmp   dword ptr ss:[VARIABLE_BAD_OPCODE_handler]
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0ECh   ; xxxx         ; Z- N- H- C-
    jmp   dword ptr ss:[VARIABLE_BAD_OPCODE_handler]
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0EDh   ; xxxx         ; Z- N- H- C-
    jmp   dword ptr ss:[VARIABLE_BAD_OPCODE_handler]
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0EEh   ; XOR d8        ; Z+ N0 H0 C0
    lodsb
    xor    cl, al
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0EFh   ; RST 5        ; Z- N- H- C-
    lea    di, [di - 2] ; push to stack.
    mov    word ptr ds:[di], si  ; store IP
    mov    si, 028h
    LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0F0h   ; LD A, (a8)   ; Z- N- H- C-
    lodsb
    mov    ah, 0FFh
    xchg   ax, bx
    mov    cl, byte ptr ds:[bx]
    xchg   ax, bx
    lahf
    test  al, al
    jns   handle_io_read_0
    sahf    
    LOAD_NEXT_INSTRUCTION 3
  handle_io_read_0:
    sahf
    mov   ah, al
    mov   al, IO_READ_OFFSET
    mov   word ptr ss:[VARIABLE_pending_cycle_count], 3
    jmp   ax  ; IO handler 

OPCODE_DEFINE 0F1h   ; POP AF       ; Z? N? H? C?
    ; gb   x86 (lahf)
    ; 7  z     x
    ; 6  n     zf (z)
    ; 5  h     0
    ; 4  c     af (h)
    ; 3  0     x
    ; 2  0     x
    ; 1  0     x
    ; 0  0     cf (c)

      mov    ax, word ptr ds:[di]
      add    di, 2   ; pop off stack.
      mov    cl, ah   ; set accumulator
      mov    ah, al   ; copy flags
      mov    ch, N_FLAG_BIT  
      and    ch, al ; N set.
      and    ax, 0A010h
      add    ax, (512 - 16) ; bit 9 set only if bit 4 was set
      shr    ah, 1    ; ah has ZF/AF/CF flags in place
      sahf             ; set ZF/AF/CF
      LOAD_NEXT_INSTRUCTION 3


      COMMENT @

    MOV AX, [DI]
    ADD DI, 2 ; clobbering flags is fine, they're getting set anyway
    XCHG AL, AH ; flags to AH, A to AL
    MOV CX, 040FFh
    AND CX, AX ; set A, set N
    OR AH, 1 ; set a bit so AAA will carry to bit 2
    AND AX, 0F100h ; AL = 0, clear extra AH bits
    SAHF ; AF = C
    AAA ; +1 to AH if AF set, setting bit 2 to C
    SHR AH, 1 ; align bits with x86 flags
    SAHF ; ZF = Z, AF = H, CF = C
  @

OPCODE_DEFINE 0F2h   ; LD A, (C)    ; Z- N- H- C-
    mov    ax, bp
    mov    ah, 0FFh
    xchg   ax, bx
    mov    cl, byte ptr ds:[bx]
    xchg   ax, bx
    lahf
    test  al, al
    jns   handle_io_read_1
    sahf    
    LOAD_NEXT_INSTRUCTION 3
  handle_io_read_1:
    sahf
    mov   ah, al
    mov   al, IO_READ_OFFSET
    mov   word ptr ss:[VARIABLE_pending_cycle_count], 2
    jmp   ax  ; IO handler 


OPCODE_DEFINE 0F3h   ; DI           ; Z- N- H- C-
    mov    byte ptr ss:[VARIABLE_IME_flag], 0
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0F4h   ; xxxx         ; Z- N- H- C-
    jmp   dword ptr ss:[VARIABLE_BAD_OPCODE_handler]
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0F5h   ; PUSH AF      ; Z- N- H- C-
    ; gb   x86 (lahf)
    ; 7  z     x
    ; 6  n     zf (z)
    ; 5  h     0
    ; 4  c     af (h)
    ; 3  0     x
    ; 2  0     x
    ; 1  0     x
    ; 0  0     cf (c)

    lahf
    mov  al, ah
    jnc  skip_carry_flag
    or   al, 08h  ; turn on carry flag  (was: reserved 0)
    skip_carry_flag:
      rol  al, 1    ; line up z and h and c
      and  al, 0B0h ; turn off bits 0-3 and 6
      or   al, ch   ; stores 0x40 or 0?
      sahf          ; restore flags
      mov  ah, cl
      lea   di, [di - 2] ; push to stack.
      mov  word ptr ds:[di], ax
      LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0F6h   ; OR d8        ; Z+ N0 H0 C0
    lodsb
    or     cl, al
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0F7h   ; RST 6        ; Z- N- H- C-
    lea    di, [di - 2] ; push to stack.
    mov    word ptr ds:[di], si  ; store IP
    mov    si, 030h
    LOAD_NEXT_INSTRUCTION 4

OPCODE_DEFINE 0F8h   ; LD HL, SP+s8 ; Z0 N0 H[3] C[7]
    ; a little gross
    lodsb
    cbw             ; sign bits into ah
    mov    bx, di   ; sp into hl
    add    bl, al
    mov    al, ah   ; back up sign bits
    lahf            ; get AF, CF
    adc    bh, al
    and    ah, 0BFH ; Z flag off
    sahf            ; set sign bits
    SET_N_FLAG_OFF  ; N flag off
    LOAD_NEXT_INSTRUCTION 3

OPCODE_DEFINE 0F9h   ; LD SP, HL    ; Z- N- H- C-
    mov    di, bx
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0FAh   ; LD A, (a16)  ; Z- N- H- C-
    lodsw
    xchg   ax, bx
    mov    cl, byte ptr ds:[bx]
    xchg   ax, bx
    mov   al, ah
    lahf
    inc   al
    jz    check_lo_byte_read
    jns   handle_io_read_2
    not_io_read:
    sahf    
    LOAD_NEXT_INSTRUCTION 3
  handle_io_read_2:
  check_lo_byte_read:
    mov   al, byte ptr ds:[si-2]
    test  al, al
    js    not_io_read
    sahf
    mov   ah, al
    mov   al, IO_READ_OFFSET
    mov   word ptr ss:[VARIABLE_pending_cycle_count], 3
    jmp   ax  ; IO handler 

OPCODE_DEFINE 0FBh   ; EI           ; Z- N- H- C-
    mov    byte ptr ss:[VARIABLE_IME_flag], 1
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0FCh   ; xxxx         ; Z- N- H- C-
    jmp   dword ptr ss:[VARIABLE_BAD_OPCODE_handler]
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0FDh   ; xxxx         ; Z- N- H- C-
    jmp   dword ptr ss:[VARIABLE_BAD_OPCODE_handler]
    LOAD_NEXT_INSTRUCTION 1

OPCODE_DEFINE 0FEh   ; CP d8        ; Z+ N1 H[3] C[7]
    lodsb
    cmp    cl, al
    SET_N_FLAG_ON
    LOAD_NEXT_INSTRUCTION 2

OPCODE_DEFINE 0FFh   ; RST 7        ; Z- N- H- C-
    ret  ; jump to 

ORG FF_OPCODE_HANDLER_OFFSET
; FF handler
    PUSH_IMMEDIATE_MACRO FF_OPCODE_HANDLER_OFFSET  ; put this back on stack.
    lea   di, [di - 2] ; push to stack.
    mov   word ptr ds:[di], si  ; store IP
    mov   si, 038h
    LOAD_NEXT_INSTRUCTION 4


IO_WRITE_DEFINE 00h ; FF00 — P1/JOYP: Joypad TODO
    
    LOAD_NEXT_INSTRUCTION_FROM_IO


IO_WRITE_DEFINE 01h ; FF01 — SB: Serial transfer data TODO
    handle_serial_write:
    ; print charcter to screen
    mov    ah, 0Eh
    mov    al, cl 
    push   bx
    mov    bx, 0
    int    010h    ; INT 10,E - Write Text in Teletype Mode
    pop    bx
    
    LOAD_NEXT_INSTRUCTION_FROM_IO

IO_WRITE_DEFINE 02h ; FF02 — SC: Serial transfer control  TODO
    LOAD_NEXT_INSTRUCTION_FROM_IO

IO_WRITE_DEFINE 03h ; empty
    LOAD_NEXT_INSTRUCTION_FROM_IO

IO_WRITE_DEFINE 04h ; FF04 — DIV: Divider register TODO
    mov   byte ptr ds:[0FF04h], 0 ; . Writing any value to this register resets it to $00. 
    ; TODO: reset, recalcualte interrupt counts
    LOAD_NEXT_INSTRUCTION_FROM_IO

IO_WRITE_DEFINE 05h ; FF05 — TIMA: Timer counter TODO
    LOAD_NEXT_INSTRUCTION_FROM_IO

IO_WRITE_DEFINE 06h ; FF06 — TMA: Timer modulo TODO
    LOAD_NEXT_INSTRUCTION_FROM_IO

IO_WRITE_DEFINE 07h ; FF07 — TAC: Timer control TODO
    LOAD_NEXT_INSTRUCTION_FROM_IO

CURRENT_IO = 08h

REPT 078h
    IO_WRITE_DEFINE CURRENT_IO
        LOAD_NEXT_INSTRUCTION_FROM_IO
        CURRENT_IO = CURRENT_IO + 1
ENDM



IO_READ_DEFINE 00h ; FF00 — P1/JOYP: Joypad TODO
    LOAD_NEXT_INSTRUCTION_FROM_IO


IO_READ_DEFINE 01h ; FF01 — SB: Serial transfer data TODO
    LOAD_NEXT_INSTRUCTION_FROM_IO

IO_READ_DEFINE 02h ; FF02 — SC: Serial transfer control  TODO
    LOAD_NEXT_INSTRUCTION_FROM_IO

IO_READ_DEFINE 03h ; empty
    LOAD_NEXT_INSTRUCTION_FROM_IO


IO_READ_DEFINE 04h ; FF04 — DIV: Divider register TODO
    ; TODO: dynamically calculate the value based on current cycle count.
    LOAD_NEXT_INSTRUCTION_FROM_IO


IO_READ_DEFINE 05h ; FF05 — TIMA: Timer counter TODO
    LOAD_NEXT_INSTRUCTION_FROM_IO


IO_READ_DEFINE 06h ; FF06 — TMA: Timer modulo TODO
    LOAD_NEXT_INSTRUCTION_FROM_IO


IO_READ_DEFINE 07h ; FF07 — TAC: Timer control TODO
    LOAD_NEXT_INSTRUCTION_FROM_IO


CURRENT_IO = 08h

REPT 078h
    IO_READ_DEFINE CURRENT_IO
        LOAD_NEXT_INSTRUCTION_FROM_IO
        CURRENT_IO = CURRENT_IO + 1
ENDM





ENDS  ; CORE1


END