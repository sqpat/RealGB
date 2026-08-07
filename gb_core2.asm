.8086
.MODEL medium
INCLUDE gb_defs.inc

; CB prefix instruction handling

EXTRN CORE1_START
EXTRN FF_OPCODE_HANDLER_CORE1

CORE1 SEGMENT
    ASSUME CS:CORE1
ENDS


SEGMENT CORE2  USE16 PARA PUBLIC 'CODE'
ASSUME  CS:CORE2

OPCODE_DEFINE 000h   ; RLC B        ; Z+ N0 H0 C[7]
    xchg  ax, bp
    test  ah, ah     ; set z, clear af
    rol   ah, 1
    xchg  ax, bp
    SET_N_FLAG_OFF
    CORE2_START:
    public CORE2_START
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2
    pointer_to_core_1:  ; todo move to ss
    public pointer_to_core_1
    dw CORE1_START, SEG CORE1


OPCODE_DEFINE 001h   ; RLC C        ; Z+ N0 H0 C[7]
    xchg  ax, bp
    test  al, al     ; set z, clear af
    rol   al, 1
    xchg  ax, bp
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 002h   ; RLC D        ; Z+ N0 H0 C[7]
    test  dh, dh     ; set z, clear af
    rol   dh, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 003h   ; RLC E        ; Z+ N0 H0 C[7]
    test  dl, dl     ; set z, clear af
    rol   dl, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 004h   ; RLC H        ; Z+ N0 H0 C[7]
    test  bh, bh     ; set z, clear af
    rol   bh, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 005h   ; RLC L        ; Z+ N0 H0 C[7]
    test  bl, bl     ; set z, clear af
    rol   bl, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 006h   ; RLC (HL)     ; Z+ N0 H0 C[7]
    cmp   byte ptr ds:[bx], 0  ; set z, clear af
    rol   byte ptr ds:[bx], 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 4

OPCODE_DEFINE 007h   ; RLC A        ; Z+ N0 H0 C[7]
    test  cl, cl     ; set z, clear af
    rol   cl, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 008h   ; RRC B        ; Z+ N0 H0 C[0]
    xchg  ax, bp
    test  ah, ah     ; set z, clear af
    ror   ah, 1
    xchg  ax, bp
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 009h   ; RRC C        ; Z+ N0 H0 C[0]
    xchg  ax, bp
    test  al, al     ; set z, clear af
    ror   al, 1
    xchg  ax, bp
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 00Ah   ; RRC D        ; Z+ N0 H0 C[0]
    test  dh, dh     ; set z, clear af
    ror   dh, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 00Bh   ; RRC E        ; Z+ N0 H0 C[0]
    test  dl, dl     ; set z, clear af
    ror   dl, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 00Ch   ; RRC H        ; Z+ N0 H0 C[0]
    test  bh, bh     ; set z, clear af
    ror   bh, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 00Dh   ; RRC L        ; Z+ N0 H0 C[0]
    test  bl, bl     ; set z, clear af
    ror   bl, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 00Eh   ; RRC (HL)     ; Z+ N0 H0 C[0]
    cmp   byte ptr ds:[bx], 0  ; set z, clear af
    ror   byte ptr ds:[bx], 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 4

OPCODE_DEFINE 00Fh   ; RRC A        ; Z+ N0 H0 C[0]
    test  cl, cl     ; set z, clear af
    ror   cl, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 010h   ; RL B         ; Z+ N0 H0 C[0]
    xchg  ax, bp
    rcl   ah, 1
    mov   bp, ax   ; store result
    mov   al, ah   ; backup result byte for test
    lahf           ; get flags for carry check in bit 0
    test  al, al   ; set zero flag, clear AF
    ror   ah, 1    ; set carry flag
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 011h   ; RL C         ; Z+ N0 H0 C[0]
    xchg  ax, bp
    rcl   al, 1
    mov   bp, ax   ; store result
    lahf           ; get flags for carry check in bit 0
    test  al, al   ; set zero flag, clear AF
    ror   ah, 1    ; set carry flag
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 012h   ; RL D         ; Z+ N0 H0 C[0]
    rcl   dh, 1
    lahf           ; get flags for carry check in bit 0
    test  dh, dh   ; set zero flag, clear AF
    ror   ah, 1    ; set carry flag
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 013h   ; RL E         ; Z+ N0 H0 C[0]
    rcl   dl, 1
    lahf           ; get flags for carry check in bit 0
    test  dl, dl   ; set zero flag, clear AF
    ror   ah, 1    ; set carry flag
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 014h   ; RL H         ; Z+ N0 H0 C[0]
    rcl   bh, 1
    lahf           ; get flags for carry check in bit 0
    test  bh, bh   ; set zero flag, clear AF
    ror   ah, 1    ; set carry flag
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 015h   ; RL L         ; Z+ N0 H0 C[0]
    rcl   bl, 1
    lahf           ; get flags for carry check in bit 0
    test  bl, bl   ; set zero flag, clear AF
    ror   ah, 1    ; set carry flag
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 016h   ; RL (HL)      ; Z+ N0 H0 C[0]
    rcl   byte ptr ds:[bx], 1
    lahf                        ; get flags for carry check in bit 0
    cmp   byte ptr ds:[bx], 0   ; set zero flag, clear AF
    ror   ah, 1                 ; set carry flag
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 4

OPCODE_DEFINE 017h   ; RL A         ; Z+ N0 H0 C[0]
    rcl   cl, 1
    lahf           ; get flags for carry check in bit 0
    test  cl, cl   ; set zero flag, clear AF
    ror   ah, 1    ; set carry flag
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 018h   ; RR B         ; Z+ N0 H0 C[0]
    xchg  ax, bp
    rcr   ah, 1
    mov   bp, ax   ; store result
    mov   al, ah   ; backup result byte for test
    lahf           ; get flags for carry check in bit 0
    test  al, al   ; set zero flag, clear AF
    ror   ah, 1    ; set carry flag
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 019h   ; RR C         ; Z+ N0 H0 C[0]
    xchg  ax, bp
    rcr   al, 1
    xchg  ax, bp
    lahf           ; get flags for carry check in bit 0
    test  al, al   ; set zero flag, clear AF
    ror   ah, 1    ; set carry flag
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 01Ah   ; RR D         ; Z+ N0 H0 C[0]
    rcr   dh, 1
    lahf           ; get flags for carry check in bit 0
    test  dh, dh   ; set zero flag, clear AF
    ror   ah, 1    ; set carry flag
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 01Bh   ; RR E         ; Z+ N0 H0 C[0]
    rcr   dl, 1
    lahf           ; get flags for carry check in bit 0
    test  dl, dl   ; set zero flag, clear AF
    ror   ah, 1    ; set carry flag
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 01Ch   ; RR H         ; Z+ N0 H0 C[0]
    rcr   bh, 1
    lahf           ; get flags for carry check in bit 0
    test  bh, bh   ; set zero flag, clear AF
    ror   ah, 1    ; set carry flag
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 01Dh   ; RR L         ; Z+ N0 H0 C[0]
    rcr   bl, 1
    lahf           ; get flags for carry check in bit 0
    test  bl, bl   ; set zero flag, clear AF
    ror   ah, 1    ; set carry flag
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 01Eh   ; RR (HL)      ; Z+ N0 H0 C[0]
    rcr   byte ptr ds:[bx], 1
    lahf                        ; get flags for carry check in bit 0
    cmp   byte ptr ds:[bx], 0   ; set zero flag, clear AF
    ror   ah, 1                 ; set carry flag
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 4

OPCODE_DEFINE 01Fh   ; RR A         ; Z+ N0 H0 C[0]
    rcr   cl, 1
    lahf           ; get flags for carry check in bit 0
    test  cl, cl   ; set zero flag, clear AF
    ror   ah, 1    ; set carry flag
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 020h   ; SLA B        ; Z+ N0 H0 C[0]
    xchg  ax, bp
    test  ah, 07Fh    ; set ZF, clear AF/CF
    shl   ah, 1
    xchg  ax, bp
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 021h   ; SLA C        ; Z+ N0 H0 C[0]
    xchg  ax, bp
    test  al, 07Fh    ; set ZF, clear AF/CF
    shl   al, 1
    xchg  ax, bp
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 022h   ; SLA D        ; Z+ N0 H0 C[0]
    test  dh, 07Fh    ; set ZF, clear AF/CF
    shl   dh, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 023h   ; SLA E        ; Z+ N0 H0 C[0]
    test  dl, 07Fh    ; set ZF, clear AF/CF
    shl   dl, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 024h   ; SLA H        ; Z+ N0 H0 C[0]
    test  bh, 07Fh    ; set ZF, clear AF/CF
    shl   bh, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 025h   ; SLA L        ; Z+ N0 H0 C[0]
    test  bl, 07Fh    ; set ZF, clear AF/CF
    shl   bl, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 026h   ; SLA (HL)     ; Z+ N0 H0 C[0]
    test  byte ptr ds:[bx], 07Fh    ; set ZF, clear AF/CF
    shl   byte ptr ds:[bx], 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 4

OPCODE_DEFINE 027h   ; SLA A        ; Z+ N0 H0 C[0]
    test  cl, 07Fh    ; set ZF, clear AF/CF
    shl   cl, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 028h   ; SRA B        ; Z+ N0 H0 C[0]
    xchg  ax, bp
    sar   ah, 1
    xchg  ax, bp
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2


OPCODE_DEFINE 029h   ; SRA C        ; Z+ N0 H0 C[0]
    xchg  ax, bp
    sar   al, 1
    xchg  ax, bp
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2


OPCODE_DEFINE 02Ah   ; SRA D        ; Z+ N0 H0 C[0]
    sar   dh, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2


OPCODE_DEFINE 02Bh   ; SRA E        ; Z+ N0 H0 C[0]
    sar   dl, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 02Ch   ; SRA H        ; Z+ N0 H0 C[0]
    sar   bh, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 02Dh   ; SRA L        ; Z+ N0 H0 C[0]
    sar   bl, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 02Eh   ; SRA (HL)     ; Z+ N0 H0 C[0]
    sar   byte ptr ds:[bx], 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 4

OPCODE_DEFINE 02Fh   ; SRA A        ; Z+ N0 H0 C[0]
    sar   cl, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 030h   ; SWAP B       ; Z+ N0 H0 C0
    xchg  ax, bp
    ROL4_MACRO ah
    test  ah, ah
    xchg  ax, bp
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 031h   ; SWAP C       ; Z+ N0 H0 C0
    xchg  ax, bp
    ROL4_MACRO al
    test  al, al
    xchg  ax, bp
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 032h   ; SWAP D       ; Z+ N0 H0 C0
    ROL4_MACRO dh
    test  dh, dh
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 033h   ; SWAP E       ; Z+ N0 H0 C0
    ROL4_MACRO dl
    test  dl, dl
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 034h   ; SWAP H       ; Z+ N0 H0 C0
    ROL4_MACRO bh
    test  bh, bh
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 035h   ; SWAP L       ; Z+ N0 H0 C0
    ROL4_MACRO bl
    test  bl, bl
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 036h   ; SWAP (HL)    ; Z+ N0 H0 C0
    mov   al, byte ptr ds:[bx]
    ROL4_MACRO al
    mov   byte ptr ds:[bx], al
    test  al, al
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 4

OPCODE_DEFINE 037h   ; SWAP A       ; Z+ N0 H0 C0
    ROL4_MACRO cl
    test  cl, cl
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 038h   ; SRL B        ; Z+ N0 H0 C[0]
    xchg  ax, bp
    shr   ah, 1
    xchg  ax, bp
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 039h   ; SRL C        ; Z+ N0 H0 C[0]
    xchg  ax, bp
    shr   al, 1
    xchg  ax, bp
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 03Ah   ; SRL D        ; Z+ N0 H0 C[0]
    shr   dh, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 03Bh   ; SRL E        ; Z+ N0 H0 C[0]
    shr   dl, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 03Ch   ; SRL H        ; Z+ N0 H0 C[0]
    shr   bh, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 03Dh   ; SRL L        ; Z+ N0 H0 C[0]
    shr   bl, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 03Eh   ; SRL (HL)     ; Z+ N0 H0 C[0]
    shr   byte ptr ds:[bx], 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 4

OPCODE_DEFINE 03Fh   ; SRL A        ; Z+ N0 H0 C[0]
    shr   cl, 1
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 040h   ; BIT 0, B     ; Zn N0 H1 C-
    test  bp, ((1 SHL 0) SHL 8)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 041h   ; BIT 0, C     ; Zn N0 H1 C-
    test  bp, (1 SHL 0)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 042h   ; BIT 0, D     ; Zn N0 H1 C-
    test  dh, (1 SHL 0)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 043h   ; BIT 0, E     ; Zn N0 H1 C-
    test  dl, (1 SHL 0)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 044h   ; BIT 0, H     ; Zn N0 H1 C-
    test  bh, (1 SHL 0)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 045h   ; BIT 0, L     ; Zn N0 H1 C-
    test  bl, (1 SHL 0)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 046h   ; BIT 0, (HL)  ; Zn N0 H1 C-
    test  byte ptr ds:[bx], (1 SHL 0)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 3

OPCODE_DEFINE 047h   ; BIT 0, A     ; Zn N0 H1 C-
    test  cl, (1 SHL 0)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 048h   ; BIT 1, B     ; Zn N0 H1 C-
    test  bp, ((1 SHL 1) SHL 8)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 049h   ; BIT 1, C     ; Zn N0 H1 C-
    test  bp, (1 SHL 1)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 04Ah   ; BIT 1, D     ; Zn N0 H1 C-
    test  dh, (1 SHL 1)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 04Bh   ; BIT 1, E     ; Zn N0 H1 C-
    test  dl, (1 SHL 1)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 04Ch   ; BIT 1, H     ; Zn N0 H1 C-
    test  bh, (1 SHL 1)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 04Dh   ; BIT 1, L     ; Zn N0 H1 C-
    test  bl, (1 SHL 1)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 04Eh   ; BIT 1, (HL)  ; Zn N0 H1 C-
    test  byte ptr ds:[bx], (1 SHL 1)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 3

OPCODE_DEFINE 04Fh   ; BIT 1, A     ; Zn N0 H1 C-
    test  cl, (1 SHL 1)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 050h   ; BIT 2, B     ; Zn N0 H1 C-
    test  bp, ((1 SHL 2) SHL 8)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 051h   ; BIT 2, C     ; Zn N0 H1 C-
    test  bp, (1 SHL 2)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 052h   ; BIT 2, D     ; Zn N0 H1 C-
    test  dh, (1 SHL 2)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 053h   ; BIT 2, E     ; Zn N0 H1 C-
    test  dl, (1 SHL 2)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 054h   ; BIT 2, H     ; Zn N0 H1 C-
    test  bh, (1 SHL 2)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 055h   ; BIT 2, L     ; Zn N0 H1 C-
    test  bl, (1 SHL 2)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 056h   ; BIT 2, (HL)  ; Zn N0 H1 C-
    test  byte ptr ds:[bx], (1 SHL 2)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 3

OPCODE_DEFINE 057h   ; BIT 2, A     ; Zn N0 H1 C-
    test  cl, (1 SHL 2)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 058h   ; BIT 3, B     ; Zn N0 H1 C-
    test  bp, ((1 SHL 3) SHL 8)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 059h   ; BIT 3, C     ; Zn N0 H1 C-
    test  bp, (1 SHL 3)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 05Ah   ; BIT 3, D     ; Zn N0 H1 C-
    test  dh, (1 SHL 3)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 05Bh   ; BIT 3, E     ; Zn N0 H1 C-
    test  dl, (1 SHL 3)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 05Ch   ; BIT 3, H     ; Zn N0 H1 C-
    test  bh, (1 SHL 3)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 05Dh   ; BIT 3, L     ; Zn N0 H1 C-
    test  bl, (1 SHL 3)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 05Eh   ; BIT 3, (HL)  ; Zn N0 H1 C-
    test  byte ptr ds:[bx], (1 SHL 3)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 3

OPCODE_DEFINE 05Fh   ; BIT 3, A     ; Zn N0 H1 C-
    test  cl, (1 SHL 3)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 060h   ; BIT 4, B     ; Zn N0 H1 C-
    test  bp, ((1 SHL 4) SHL 8)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 061h   ; BIT 4, C     ; Zn N0 H1 C-
    test  bp, (1 SHL 4)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 062h   ; BIT 4, D     ; Zn N0 H1 C-
    test  dh, (1 SHL 4)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 063h   ; BIT 4, E     ; Zn N0 H1 C-
    test  dl, (1 SHL 4)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 064h   ; BIT 4, H     ; Zn N0 H1 C-
    test  bh, (1 SHL 4)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 065h   ; BIT 4, L     ; Zn N0 H1 C-
    test  bl, (1 SHL 4)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 066h   ; BIT 4, (HL)  ; Zn N0 H1 C-
    test  byte ptr ds:[bx], (1 SHL 4)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 3

OPCODE_DEFINE 067h   ; BIT 4, A     ; Zn N0 H1 C-
    test  cl, (1 SHL 4)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 068h   ; BIT 5, B     ; Zn N0 H1 C-
    test  bp, ((1 SHL 5) SHL 8)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 069h   ; BIT 5, C     ; Zn N0 H1 C-
    test  bp, (1 SHL 5)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 06Ah   ; BIT 5, D     ; Zn N0 H1 C-
    test  dh, (1 SHL 5)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 06Bh   ; BIT 5, E     ; Zn N0 H1 C-
    test  dl, (1 SHL 5)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 06Ch   ; BIT 5, H     ; Zn N0 H1 C-
    test  bh, (1 SHL 5)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 06Dh   ; BIT 5, L     ; Zn N0 H1 C-
    test  bl, (1 SHL 5)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 06Eh   ; BIT 5, (HL)  ; Zn N0 H1 C-
    test  byte ptr ds:[bx], (1 SHL 5)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 3

OPCODE_DEFINE 06Fh   ; BIT 5, A     ; Zn N0 H1 C-
    test  cl, (1 SHL 5)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 070h   ; BIT 6, B     ; Zn N0 H1 C-
    test  bp, ((1 SHL 6) SHL 8)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 071h   ; BIT 6, C     ; Zn N0 H1 C-
    test  bp, (1 SHL 6)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 072h   ; BIT 6, D     ; Zn N0 H1 C-
    test  dh, (1 SHL 6)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 073h   ; BIT 6, E     ; Zn N0 H1 C-
    test  dl, (1 SHL 6)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 074h   ; BIT 6, H     ; Zn N0 H1 C-
    test  bh, (1 SHL 6)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 075h   ; BIT 6, L     ; Zn N0 H1 C-
    test  bl, (1 SHL 6)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 076h   ; BIT 6, (HL)  ; Zn N0 H1 C-
    test  byte ptr ds:[bx], (1 SHL 6)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 3

OPCODE_DEFINE 077h   ; BIT 6, A     ; Zn N0 H1 C-
    test  cl, (1 SHL 6)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 078h   ; BIT 7, B     ; Zn N0 H1 C-
    test  bp, ((1 SHL 7) SHL 8)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 079h   ; BIT 7, C     ; Zn N0 H1 C-
    test  bp, (1 SHL 7)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 07Ah   ; BIT 7, D     ; Zn N0 H1 C-
    test  dh, (1 SHL 7)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 07Bh   ; BIT 7, E     ; Zn N0 H1 C-
    test  dl, (1 SHL 7)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 07Ch   ; BIT 7, H     ; Zn N0 H1 C-
    test  bh, (1 SHL 7)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 07Dh   ; BIT 7, L     ; Zn N0 H1 C-
    test  bl, (1 SHL 7)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 07Eh   ; BIT 7, (HL)  ; Zn N0 H1 C-
    test  byte ptr ds:[bx], (1 SHL 7)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 3

OPCODE_DEFINE 07Fh   ; BIT 7, A     ; Zn N0 H1 C-
    test  cl, (1 SHL 7)
    SET_N_FLAG_OFF
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2


OPCODE_DEFINE 080h   ; RES 0, B     ; Z- N- H- C-
    lahf
    and   bp, (NOT ((1 SHL 0) SHL 8))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 081h   ; RES 0, C     ; Z- N- H- C-
    lahf
    and   bp, (NOT (1 SHL 0))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 082h   ; RES 0, D     ; Z- N- H- C-
    lahf
    and   dh, (NOT (1 SHL 0))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 083h   ; RES 0, E     ; Z- N- H- C-
    lahf
    and   dl, (NOT (1 SHL 0))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 084h   ; RES 0, H     ; Z- N- H- C-
    lahf
    and   bh, (NOT (1 SHL 0))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 085h   ; RES 0, L     ; Z- N- H- C-
    lahf
    and   bl, (NOT (1 SHL 0))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 086h   ; RES 0, (HL)  ; Z- N- H- C-
    lahf
    and   byte ptr ds:[bx], (NOT (1 SHL 0))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 4

OPCODE_DEFINE 087h   ; RES 0, A     ; Z- N- H- C-
    lahf
    and   cl, (NOT (1 SHL 0))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 088h   ; RES 1, B     ; Z- N- H- C-
    lahf
    and   bp, (NOT ((1 SHL 1) SHL 8))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 089h   ; RES 1, C     ; Z- N- H- C-
    lahf
    and   bp, (NOT (1 SHL 1))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 08Ah   ; RES 1, D     ; Z- N- H- C-
    lahf
    and   dh, (NOT (1 SHL 1))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 08Bh   ; RES 1, E     ; Z- N- H- C-
    lahf
    and   dl, (NOT (1 SHL 1))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 08Ch   ; RES 1, H     ; Z- N- H- C-
    lahf
    and   bh, (NOT (1 SHL 1))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 08Dh   ; RES 1, L     ; Z- N- H- C-
    lahf
    and   bl, (NOT (1 SHL 1))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 08Eh   ; RES 1, (HL)  ; Z- N- H- C-
    lahf
    and   byte ptr ds:[bx], (NOT (1 SHL 1))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 4

OPCODE_DEFINE 08Fh   ; RES 1, A     ; Z- N- H- C-
    lahf
    and   cl, (NOT (1 SHL 1))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 090h   ; RES 2, B     ; Z- N- H- C-
    lahf
    and   bp, (NOT ((1 SHL 2) SHL 8))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 091h   ; RES 2, C     ; Z- N- H- C-
    lahf
    and   bp, (NOT (1 SHL 2))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 092h   ; RES 2, D     ; Z- N- H- C-
    lahf
    and   dh, (NOT (1 SHL 2))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 093h   ; RES 2, E     ; Z- N- H- C-
    lahf
    and   dl, (NOT (1 SHL 2))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 094h   ; RES 2, H     ; Z- N- H- C-
    lahf
    and   bh, (NOT (1 SHL 2))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 095h   ; RES 2, L     ; Z- N- H- C-
    lahf
    and   bl, (NOT (1 SHL 2))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 096h   ; RES 2, (HL)  ; Z- N- H- C-
    lahf
    and   byte ptr ds:[bx], (NOT (1 SHL 2))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 4

OPCODE_DEFINE 097h   ; RES 2, A     ; Z- N- H- C-
    lahf
    and   cl, (NOT (1 SHL 2))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 098h   ; RES 3, B     ; Z- N- H- C-
    lahf
    and   bp, (NOT ((1 SHL 3) SHL 8))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 099h   ; RES 3, C     ; Z- N- H- C-
    lahf
    and   bp, (NOT (1 SHL 3))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 09Ah   ; RES 3, D     ; Z- N- H- C-
    lahf
    and   dh, (NOT (1 SHL 3))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 09Bh   ; RES 3, E     ; Z- N- H- C-
    lahf
    and   dl, (NOT (1 SHL 3))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 09Ch   ; RES 3, H     ; Z- N- H- C-
    lahf
    and   bh, (NOT (1 SHL 3))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 09Dh   ; RES 3, L     ; Z- N- H- C-
    lahf
    and   bl, (NOT (1 SHL 3))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 09Eh   ; RES 3, (HL)  ; Z- N- H- C-
    lahf
    and   byte ptr ds:[bx], (NOT (1 SHL 3))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 4

OPCODE_DEFINE 09Fh   ; RES 3, A     ; Z- N- H- C-
    lahf
    and   cl, (NOT (1 SHL 3))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0A0h   ; RES 4, B     ; Z- N- H- C-
    lahf
    and   bp, (NOT ((1 SHL 4) SHL 8))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0A1h   ; RES 4, C     ; Z- N- H- C-
    lahf
    and   bp, (NOT (1 SHL 4))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0A2h   ; RES 4, D     ; Z- N- H- C-
    lahf
    and   dh, (NOT (1 SHL 4))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0A3h   ; RES 4, E     ; Z- N- H- C-
    lahf
    and   dl, (NOT (1 SHL 4))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0A4h   ; RES 4, H     ; Z- N- H- C-
    lahf
    and   bh, (NOT (1 SHL 4))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0A5h   ; RES 4, L     ; Z- N- H- C-
    lahf
    and   bl, (NOT (1 SHL 4))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0A6h   ; RES 4, (HL)  ; Z- N- H- C-
    lahf
    and   byte ptr ds:[bx], (NOT (1 SHL 4))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 4

OPCODE_DEFINE 0A7h   ; RES 4, A     ; Z- N- H- C-
    lahf
    and   cl, (NOT (1 SHL 4))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0A8h   ; RES 5, B     ; Z- N- H- C-
    lahf
    and   bp, (NOT ((1 SHL 5) SHL 8))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0A9h   ; RES 5, C     ; Z- N- H- C-
    lahf
    and   bp, (NOT (1 SHL 5))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0AAh   ; RES 5, D     ; Z- N- H- C-
    lahf
    and   dh, (NOT (1 SHL 5))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0ABh   ; RES 5, E     ; Z- N- H- C-
    lahf
    and   dl, (NOT (1 SHL 5))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0ACh   ; RES 5, H     ; Z- N- H- C-
    lahf
    and   bh, (NOT (1 SHL 5))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0ADh   ; RES 5, L     ; Z- N- H- C-
    lahf
    and   bl, (NOT (1 SHL 5))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0AEh   ; RES 5, (HL)  ; Z- N- H- C-
    lahf
    and   byte ptr ds:[bx], (NOT (1 SHL 5))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 4

OPCODE_DEFINE 0AFh   ; RES 5, A     ; Z- N- H- C-
    lahf
    and   cl, (NOT (1 SHL 5))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0B0h   ; RES 6, B     ; Z- N- H- C-
    lahf
    and   bp, (NOT ((1 SHL 6) SHL 8))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0B1h   ; RES 6, C     ; Z- N- H- C-
    lahf
    and   bp, (NOT (1 SHL 6))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0B2h   ; RES 6, D     ; Z- N- H- C-
    lahf
    and   dh, (NOT (1 SHL 6))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0B3h   ; RES 6, E     ; Z- N- H- C-
    lahf
    and   dl, (NOT (1 SHL 6))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0B4h   ; RES 6, H     ; Z- N- H- C-
    lahf
    and   bh, (NOT (1 SHL 6))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0B5h   ; RES 6, L     ; Z- N- H- C-
    lahf
    and   bl, (NOT (1 SHL 6))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0B6h   ; RES 6, (HL)  ; Z- N- H- C-
    lahf
    and   byte ptr ds:[bx], (NOT (1 SHL 6))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 4

OPCODE_DEFINE 0B7h   ; RES 6, A     ; Z- N- H- C-
    lahf
    and   cl, (NOT (1 SHL 6))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0B8h   ; RES 7, B     ; Z- N- H- C-
    lahf
    and   bp, (NOT ((1 SHL 7) SHL 8))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0B9h   ; RES 7, C     ; Z- N- H- C-
    lahf
    and   bp, (NOT (1 SHL 7))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0BAh   ; RES 7, D     ; Z- N- H- C-
    lahf
    and   dh, (NOT (1 SHL 7))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0BBh   ; RES 7, E     ; Z- N- H- C-
    lahf
    and   dl, (NOT (1 SHL 7))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0BCh   ; RES 7, H     ; Z- N- H- C-
    lahf
    and   bh, (NOT (1 SHL 7))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0BDh   ; RES 7, L     ; Z- N- H- C-
    lahf
    and   bl, (NOT (1 SHL 7))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0BEh   ; RES 7, (HL)  ; Z- N- H- C-
    lahf
    and   byte ptr ds:[bx], (NOT (1 SHL 7))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 4

OPCODE_DEFINE 0BFh   ; RES 7, A     ; Z- N- H- C-
    lahf
    and   cl, (NOT (1 SHL 7))
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0C0h   ; SET 0, B     ; Z- N- H- C-
    lahf
    or    bp, ( (1 SHL 0) SHL 8)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0C1h   ; SET 0, C     ; Z- N- H- C-
    lahf
    or    bp, (1 SHL 0)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0C2h   ; SET 0, D     ; Z- N- H- C-
    lahf
    or    dh, (1 SHL 0)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0C3h   ; SET 0, E     ; Z- N- H- C-
    lahf
    or    dl, (1 SHL 0)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0C4h   ; SET 0, H     ; Z- N- H- C-
    lahf
    or    bh, (1 SHL 0)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0C5h   ; SET 0, L     ; Z- N- H- C-
    lahf
    or    bl, (1 SHL 0)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0C6h   ; SET 0, (HL)  ; Z- N- H- C-
    lahf
    or    byte ptr ds:[bx],  (1 SHL 0)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 4

OPCODE_DEFINE 0C7h   ; SET 0, A     ; Z- N- H- C-
    lahf
    or    cl, (1 SHL 0)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0C8h   ; SET 1, B     ; Z- N- H- C-
    lahf
    or    bp, ( (1 SHL 1) SHL 8)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0C9h   ; SET 1, C     ; Z- N- H- C-
    lahf
    or    bp, (1 SHL 1)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0CAh   ; SET 1, D     ; Z- N- H- C-
    lahf
    or    dh, (1 SHL 1)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0CBh   ; SET 1, E     ; Z- N- H- C-
    lahf
    or    dl, (1 SHL 1)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0CCh   ; SET 1, H     ; Z- N- H- C-
    lahf
    or    bh, (1 SHL 1)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0CDh   ; SET 1, L     ; Z- N- H- C-
    lahf
    or    bl, (1 SHL 1)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0CEh   ; SET 1, (HL)  ; Z- N- H- C-
    lahf
    or    byte ptr ds:[bx],  (1 SHL 1)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 4

OPCODE_DEFINE 0CFh   ; SET 1, A     ; Z- N- H- C-
    lahf
    or    cl, (1 SHL 1)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0D0h   ; SET 2, B     ; Z- N- H- C-
    lahf
    or    bp, ( (1 SHL 2) SHL 8)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0D1h   ; SET 2, C     ; Z- N- H- C-
    lahf
    or    bp, (1 SHL 2)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0D2h   ; SET 2, D     ; Z- N- H- C-
    lahf
    or    dh, (1 SHL 2)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0D3h   ; SET 2, E     ; Z- N- H- C-
    lahf
    or    dl, (1 SHL 2)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0D4h   ; SET 2, H     ; Z- N- H- C-
    lahf
    or    bh, (1 SHL 2)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0D5h   ; SET 2, L     ; Z- N- H- C-
    lahf
    or    bl, (1 SHL 2)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0D6h   ; SET 2, (HL)  ; Z- N- H- C-
    lahf
    or    byte ptr ds:[bx],  (1 SHL 2)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 4

OPCODE_DEFINE 0D7h   ; SET 2, A     ; Z- N- H- C-
    lahf
    or    cl, (1 SHL 2)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0D8h   ; SET 3, B     ; Z- N- H- C-
    lahf
    or    bp, ( (1 SHL 3) SHL 8)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0D9h   ; SET 3, C     ; Z- N- H- C-
    lahf
    or    bp, (1 SHL 3)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0DAh   ; SET 3, D     ; Z- N- H- C-
    lahf
    or    dh, (1 SHL 3)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0DBh   ; SET 3, E     ; Z- N- H- C-
    lahf
    or    dl, (1 SHL 3)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0DCh   ; SET 3, H     ; Z- N- H- C-
    lahf
    or    bh, (1 SHL 3)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0DDh   ; SET 3, L     ; Z- N- H- C-
    lahf
    or    bl, (1 SHL 3)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0DEh   ; SET 3, (HL)  ; Z- N- H- C-
    lahf
    or    byte ptr ds:[bx],  (1 SHL 3)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 4

OPCODE_DEFINE 0DFh   ; SET 3, A     ; Z- N- H- C-
    lahf
    or    cl, (1 SHL 3)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0E0h   ; SET 4, B     ; Z- N- H- C-
    lahf
    or    bp, ( (1 SHL 4) SHL 8)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0E1h   ; SET 4, C     ; Z- N- H- C-
    lahf
    or    bp, (1 SHL 4)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0E2h   ; SET 4, D     ; Z- N- H- C-
    lahf
    or    dh, (1 SHL 4)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0E3h   ; SET 4, E     ; Z- N- H- C-
    lahf
    or    dl, (1 SHL 4)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0E4h   ; SET 4, H     ; Z- N- H- C-
    lahf
    or    bh, (1 SHL 4)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0E5h   ; SET 4, L     ; Z- N- H- C-
    lahf
    or    bl, (1 SHL 4)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0E6h   ; SET 4, (HL)  ; Z- N- H- C-
    lahf
    or    byte ptr ds:[bx],  (1 SHL 4)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 4

OPCODE_DEFINE 0E7h   ; SET 4, A     ; Z- N- H- C-
    lahf
    or    cl, (1 SHL 4)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0E8h   ; SET 5, B     ; Z- N- H- C-
    lahf
    or    bp, ( (1 SHL 5) SHL 8)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0E9h   ; SET 5, C     ; Z- N- H- C-
    lahf
    or    bp, (1 SHL 5)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0EAh   ; SET 5, D     ; Z- N- H- C-
    lahf
    or    dh, (1 SHL 5)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0EBh   ; SET 5, E     ; Z- N- H- C-
    lahf
    or    dl, (1 SHL 5)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0ECh   ; SET 5, H     ; Z- N- H- C-
    lahf
    or    bh, (1 SHL 5)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0EDh   ; SET 5, L     ; Z- N- H- C-
    lahf
    or    bl, (1 SHL 5)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0EEh   ; SET 5, (HL)  ; Z- N- H- C-
    lahf
    or    byte ptr ds:[bx],  (1 SHL 5)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 4

OPCODE_DEFINE 0EFh   ; SET 5, A     ; Z- N- H- C-
    lahf
    or    cl, (1 SHL 5)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0F0h   ; SET 6, B     ; Z- N- H- C-
    lahf
    or    bp, ( (1 SHL 6) SHL 8)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0F1h   ; SET 6, C     ; Z- N- H- C-
    lahf
    or    bp, (1 SHL 6)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0F2h   ; SET 6, D     ; Z- N- H- C-
    lahf
    or    dh, (1 SHL 6)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0F3h   ; SET 6, E     ; Z- N- H- C-
    lahf
    or    dl, (1 SHL 6)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0F4h   ; SET 6, H     ; Z- N- H- C-
    lahf
    or    bh, (1 SHL 6)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0F5h   ; SET 6, L     ; Z- N- H- C-
    lahf
    or    bl, (1 SHL 6)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0F6h   ; SET 6, (HL)  ; Z- N- H- C-
    lahf
    or    byte ptr ds:[bx],  (1 SHL 6)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 4

OPCODE_DEFINE 0F7h   ; SET 6, A     ; Z- N- H- C-
    lahf
    or    cl, (1 SHL 6)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0F8h   ; SET 7, B     ; Z- N- H- C-
    lahf
    or    bp, ( (1 SHL 7) SHL 8)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0F9h   ; SET 7, C     ; Z- N- H- C-
    lahf
    or    bp, (1 SHL 7)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0FAh   ; SET 7, D     ; Z- N- H- C-
    lahf
    or    dh, (1 SHL 7)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0FBh   ; SET 7, E     ; Z- N- H- C-
    lahf
    or    dl, (1 SHL 7)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0FCh   ; SET 7, H     ; Z- N- H- C-
    lahf
    or    bh, (1 SHL 7)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0FDh   ; SET 7, L     ; Z- N- H- C-
    lahf
    or    bl, (1 SHL 7)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2

OPCODE_DEFINE 0FEh   ; SET 7, (HL)  ; Z- N- H- C-
    lahf
    or    byte ptr ds:[bx],  (1 SHL 7)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 4

OPCODE_DEFINE 0FFh   ; SET 7, A     ; Z- N- H- C-
    retf

    COMMENT @
    lahf
    or    cl, (1 SHL 7)
    sahf
    LOAD_NEXT_INSTRUCTION_SEGMENT_2 2
    @



    ENDS  ; CORE2


    END