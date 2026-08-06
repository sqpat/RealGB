; gb_init  bootstraps the program.

.8086
.MODEL medium

INCLUDE gb_defs.inc


CORE1 SEGMENT
  ASSUME CS:CORE1
ENDS

CORE2 SEGMENT
  ASSUME CS:CORE2
ENDS



EXTRN CORE1_START
EXTRN CORE2_START

INIT SEGMENT
  ASSUME CS:INIT

init_emulator:
public init_emulator

;; EXE ENTRY POINT
;; EXE ENTRY POINT
;; EXE ENTRY POINT


; general theory: emulator core requires 64kb segments
; and the emulated environment has 64kb space
; so we prepare those segments (load files, etc) in bootstrap then jump in.


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

; todo: set up stack to be in 07000h or some such.

mov  si, 0  ; initial IP

; 3. jump into core
;jmp dword ptr cs:[VARIABLE_core_location]


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


BAD_OPCODE_DETECTED:
public BAD_OPCODE_DETECTED
jmp emulator_shutdown


;;; VARIABLES
;;; VARIABLES
;;; VARIABLES

ALIGN 2
VARIABLE_exit_sp:
dw 0
VARIABLE_core_location:
dw CORE1_START, SEG CORE1
VARIABLE_rom_file_handle:
dw 0

rom_filename:
db "testrom.gb", 0

ENDS


END