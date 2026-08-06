; gb_init  bootstraps the program.

.8086
.MODEL medium

INCLUDE gb_defs.inc


CORE1 SEGMENT
  ASSUME CS:CORE1
ENDS


EXTRN CORE1_START

INIT SEGMENT
  ASSUME CS:INIT



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


; 2. load emulator core segment(s)

; TODO allocate from dos. for now just shove it in segment 0x4000

; 3. jump into core


mov ax, 08000h
mov ds, ax   ; emulator lives in 0x8000
; todo: set up stack to be in 07000h or some such.

;jmp dword ptr cs:[VARIABLE_core_location]


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



;;; VARIABLES
;;; VARIABLES
;;; VARIABLES

ALIGN 2
VARIABLE_exit_sp:
dw 0
VARIABLE_core_location:
dw CORE1_START, SEG CORE1

ENDS


END