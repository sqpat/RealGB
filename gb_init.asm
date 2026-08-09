; gb_init  bootstraps the program.

INCLUDE gb_defs.inc


IF COMPISA EQ 0
    .8086
ELSE
    .286
ENDIF
.MODEL medium



CORE1 SEGMENT
  ASSUME CS:CORE1
ENDS

CORE2 SEGMENT
  ASSUME CS:CORE2
ENDS



EXTRN CORE1_START
EXTRN CORE2_START




INIT SEGMENT "STACK"
  ASSUME CS:INIT


init_emulator:
public init_emulator

;; EXE ENTRY POINT
;; EXE ENTRY POINT
;; EXE ENTRY POINT



PUSHA_MACRO   ; todo how much of this reg storage is necessary

mov   word ptr ds:[VARIABLE_original_ds], ds

push  ds
push  es

push  cs
pop   es
mov  word ptr ds:[VARIABLE_exit_sp], sp


;;; BOOTSTRAP EMULATOR HERE


; 1. get comamnd line arg(s)

xor   cx, cx
mov   cl, byte ptr ds:[0080h]
jcxz  no_command_line
mov   si, 0082h
skip_next_space:
lodsb
cmp   al, " "
jne   found_start
dec   cx
jmp   skip_next_space
found_start:
dec   si
dec   cx
mov   di, offset rom_filename
rep   movsb  ; set filename..
lodsb
cmp   al, 0Dh
je    skip_newline_filename
cmp   al, 0Ah
je    skip_newline_filename
cmp   al, " "
je    skip_newline_filename
stosb
skip_newline_filename:
mov   al, 0
stosb

no_command_line:

push  cs
pop   ds


; 2. init EMS page frame

; TODO. For now just shove it in segment 0x8000 until 

; 3. load rom into EMS page frame

;INT 21,3D - Open File Using Handle
mov   ax, 03D00h
mov   dx, OFFSET rom_filename
int   021h
jc    nofileload  

mov   word ptr cs:[VARIABLE_rom_file_handle], ax


; INT 21,3F - Read From File or Device Using Handle

xchg  ax, bx
mov   ax, 08000h
mov   ds, ax   ; emulator lives in 0x8000
mov   es, ax   ; emulator lives in 0x8000
mov   cx, 32768
xor   ax, ax
xor   di, di
rep   stosw  ; clear memory first... todo use FF isntead of 00?
push  cs
pop   es  ; restore es
xor   dx, dx   
mov   ah, 03Fh
mov   cx, 32768
int   021h

jc    emulator_shutdown

test  ax, ax  
jns   done_loading_rom
; load 32768 more

mov   ah, 03Fh
mov   cx, 32768
mov   dx, cx
int   021h

jc    emulator_shutdown

done_loading_rom:
; 2. initialize emualtor state

mov   ax, cs
mov   word ptr es:[VARIABLE_BAD_OPCODE_handler+2], ax
sub   ax, 02000h ; core1
mov   word ptr cs:[VARIABLE_core_location+2], ax
mov   word ptr cs:[VARIABLE_pointer_to_core_1+2], ax
add   ax, 01000h ; core2
mov   word ptr cs:[VARIABLE_pointer_to_core_2+2], ax



mov  si, 0100h   ; initial PC
mov  di, 0FFFEh  ; initial SP
mov  bp, 00013h  ; initial BC
mov  dx, 000D8h  ; initial DE
mov  bx, 0014Dh  ; initial HL
xor  ax, ax
test ax, ax

; 3. jump into core

push cs
PUSH_IMMEDIATE_MACRO FF_OPCODE_HANDLER_OFFSET

lodsb
mov  ah, al
mov  word ptr cs:[VARIABLE_core_location], ax


jmp dword ptr cs:[VARIABLE_core_location]


emulator_shutdown:

;INT 21,3E - Close File Using Handle

mov   bx, word ptr cs:[VARIABLE_rom_file_handle]
mov   ah, 03Eh
int   021h


nofileload:
;;; EXIT PROGRAM HERE

quit_exit_program: ;  detect stack mismatch? probably fine if we made it here
push  cs
pop   ss
mov   sp, word ptr cs:[VARIABLE_exit_sp]


pop   es
pop   ds

; EXIT PROGRAM

POPA_MACRO
mov   ax, 04C00h
int   021h

ALIGN 2

BAD_OPCODE_DETECTED:
public BAD_OPCODE_DETECTED
jmp emulator_shutdown




;;; VARIABLES
;;; VARIABLES
;;; VARIABLES

ALIGN 2
VARIABLE_exit_sp:
dw 0

VARIABLE_original_ds:
dw 0

VARIABLE_core_location:
dw CORE1_START, 9
VARIABLE_rom_file_handle:
dw 0

VARIABLE_pointer_to_core_1:
dw CORE1_START, 0 
VARIABLE_pointer_to_core_2:
dw CORE2_START, 0 

VARIABLE_BAD_OPCODE_handler:
dw BAD_OPCODE_DETECTED, SEG INIT


public VARIABLE_pointer_to_core_1
public VARIABLE_pointer_to_core_2
public VARIABLE_BAD_OPCODE_handler

rom_filename:
db "testrom.gb", 0
dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; leave space for filename

ENDS


END