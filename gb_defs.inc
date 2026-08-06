



PUSHA_MACRO MACRO

    push  ax	
    push  cx
    push  dx
    push  bx
    push  si
    push  di
ENDM


POPA_MACRO MACRO

    pop   di
    pop   si
    pop   bx
    pop   dx
    pop   cx
    pop   ax	
ENDM



INCREMENT_CYCLES MACRO cycles

ENDM

LOAD_NEXT_INSTRUCTION MACRO cycles
    INCREMENT_CYCLES cycles
    lodsb
    mov  ah, al
    jmp  ax
ENDM

LOAD_NEXT_INSTRUCTION_SEGMENT_2 MACRO cycles
    INCREMENT_CYCLES cycles
    lodsb
    mov  ah, al
    mov  word ptr cs:[pointer_to_core_1], ax
    jmp  dword ptr cs:[pointer_to_core_1]
ENDM

LOAD_NEXT_INSTRUCTION_NOCYCLES MACRO
    lodsb
    mov  ah, al
    jmp  ax
ENDM





OPCODE_DEFINE MACRO byte
    ORG ( &byte shl 8) + &byte
ENDM




