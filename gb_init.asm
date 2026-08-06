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
EXTRN pointer_to_core_1
EXTRN pointer_to_core_2
EXTRN BAD_OPCODE

INIT SEGMENT
  ASSUME CS:INIT

init_emulator:
public init_emulator

;; EXE ENTRY POINT
;; EXE ENTRY POINT
;; EXE ENTRY POINT



PUSHA_MACRO   ; todo how much of this reg storage is necessary
push  ds
push  es

push  cs
push  cs
pop   ds
pop   es
mov  word ptr ds:[VARIABLE_exit_sp], sp


;;; BOOTSTRAP EMULATOR HERE

; 0. init EMS page frame

; TODO. For now just shove it in segment 0x8000 until 

; 1. load rom into EMS page frame

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
sub   ax, 02000h
mov   word ptr cs:[VARIABLE_core_location+2], ax
mov   es, ax
add   ax, 01000h
mov   word ptr es:[BAD_OPCODE+2], cs
mov   di, OFFSET pointer_to_core_2+2
stosw
mov   es, ax
sub   ax, 01000h
mov   di, OFFSET pointer_to_core_1+2
stosw


mov  si, 0100h    ; initial PC
mov  di, 0FFFEh  ; initial SP
mov  bp, 00013h  ; initial BC
mov  dx, 000D8h  ; initial DE
mov  bx, 0014Dh  ; initial HL
xor  ax, ax
test ax, ax

; 3. jump into core

push cs
mov  ax, OFFSET FF_OPCODE_HANDLER_CORE1
push ax 
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

ALIGN 2
FF_OPCODE_HANDLER_CORE1:

push cs
mov  ax, OFFSET FF_OPCODE_HANDLER_CORE1
push ax 

mov    word ptr ds:[di], si  ; store IP
lea    di, [di - 2] ; push to stack.
mov    si, 038h
INCREMENT_CYCLES 4
lodsb
mov    ah, al
mov    word ptr cs:[VARIABLE_core_location], ax

db 02Eh, 0ffh, 02eh
dw OFFSET VARIABLE_core_location
;jmp    dword ptr cs:[VARIABLE_core_location]


ALIGN 2
FF_OPCODE_HANDLER_CORE2:
push cs
mov  ax, OFFSET FF_OPCODE_HANDLER_CORE1 
push ax 

lahf
or    cl, (1 SHL 7)
sahf
INCREMENT_CYCLES 2
lodsb
mov    ah, al
mov    word ptr cs:[VARIABLE_core_location], ax
jmp dword ptr cs:[VARIABLE_core_location]


PUBLIC FF_OPCODE_HANDLER_CORE1
PUBLIC FF_OPCODE_HANDLER_CORE2


;;; VARIABLES
;;; VARIABLES
;;; VARIABLES

ALIGN 2
VARIABLE_exit_sp:
dw 0
VARIABLE_core_location:
dw CORE1_START
dw SEG CORE1
VARIABLE_rom_file_handle:
dw 0

rom_filename:
db "testrom.gb", 0

ENDS


END