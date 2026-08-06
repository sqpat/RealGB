



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

LOAD_NEXT_INSTRUCTION MACRO
    lodsb
    mov  ah, al
    jmp  ax
ENDM

OPCODE_DEFINE MACRO byte
    ORG ( &byte shl 8) + &byte
ENDM

