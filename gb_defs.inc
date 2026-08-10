

COMPILE_8086 = 0
COMPILE_186 = 1
COMPILE_286 = 2

COMPISA = COMPILE_8086


FF_OPCODE_HANDLER_OFFSET = 0FEC0h

PUSHA_MACRO MACRO

  IF COMPISA GE COMPILE_186
    pusha
  ELSE
    push  ax	
    push  cx
    push  dx
    push  bx
    push  si
    push  di
    push  bp
  ENDIF
ENDM


POPA_MACRO MACRO

  IF COMPISA GE COMPILE_186
    popa
  ELSE
    pop   bp
    pop   di
    pop   si
    pop   bx
    pop   dx
    pop   cx
    pop   ax	
  ENDIF
ENDM



DEBUG_CYCLE_COUNTER = 1

IFDEF DEBUG_CYCLE_COUNTER
  INCREMENT_CYCLES MACRO cycles
      lahf
      add  word ptr ss:[VARIABLE_CYCLE_COUNT+0], cycles
      adc  word ptr ss:[VARIABLE_CYCLE_COUNT+2], 0
      sahf
  ENDM
  INCREMENT_CYCLES_IO MACRO
      pushf
      mov  ax, word ptr ss:[VARIABLE_pending_cycle_count]
      add  word ptr ss:[VARIABLE_CYCLE_COUNT+0], ax
      adc  word ptr ss:[VARIABLE_CYCLE_COUNT+2], 0
      popf
  ENDM

ELSE
  INCREMENT_CYCLES_IO MACRO

  ENDM

  INCREMENT_CYCLES MACRO cycles

  ENDM
ENDIF


LOAD_NEXT_INSTRUCTION MACRO cycles
    INCREMENT_CYCLES cycles
    lodsb
    mov  ah, al
    jmp  ax
ENDM


LOAD_NEXT_INSTRUCTION_FROM_IO MACRO 
    INCREMENT_CYCLES_IO 
    lodsb
    mov  ah, al
    jmp  ax
ENDM


LOAD_NEXT_INSTRUCTION_SEGMENT_2 MACRO cycles
    INCREMENT_CYCLES cycles
    pop  ax
    PUSH_IMMEDIATE_MACRO FF_OPCODE_HANDLER_OFFSET

    lodsb
    mov  ah, al
    mov  word ptr ss:[VARIABLE_pointer_to_core_1], ax
    jmp  dword ptr ss:[VARIABLE_pointer_to_core_1]
ENDM

LOAD_NEXT_INSTRUCTION_NOCYCLES MACRO
    lodsb
    mov  ah, al
    jmp  ax
ENDM

PUSH_IMMEDIATE_MACRO MACRO  imm
  IF COMPISA GE COMPILE_186
    push  OFFSET imm
  ELSE
    mov   ax, OFFSET imm
    push  ax
  ENDIF
ENDM


ROL4_MACRO MACRO reg
  IF COMPISA GE COMPILE_186
    rol reg, 4
  ELSE
    rol reg, 1
    rol reg, 1
    rol reg, 1
    rol reg, 1
  ENDIF
ENDM

; store in ch bit 1, though its used as as bit 6 (0x40) in emulator
N_FLAG_BIT_CH = 001h
N_FLAG_BIT_GAME_BOY = 040h

SET_N_FLAG_ON MACRO
  lahf
   or ch, N_FLAG_BIT_CH
  sahf
;   mov ch, N_FLAG_BIT_CH
ENDM

SET_N_FLAG_OFF MACRO
  lahf
   and ch, (NOT N_FLAG_BIT_CH)
  sahf
;   mov ch, 0
ENDM


OPCODE_DEFINE MACRO byte
    ORG ( &byte shl 8) + &byte
ENDM

IO_READ_OFFSET = 0A0h
IO_WRITE_OFFSET = 0C8h

IO_WRITE_DEFINE MACRO byte
    ORG ( &byte shl 8) + IO_WRITE_OFFSET
ENDM



IO_READ_DEFINE MACRO byte
    ORG ( &byte shl 8) + IO_READ_OFFSET
ENDM



