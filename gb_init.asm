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

mov   word ptr cs:[VARIABLE_original_ds], ds

push  ds
push  es

push  cs
pop   es
mov  word ptr cs:[VARIABLE_exit_sp], sp


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
jnc   doloadfile
jmp   nofileload
doloadfile:
mov   word ptr cs:[VARIABLE_rom_file_handle], ax


; INT 21,3F - Read From File or Device Using Handle

xchg  ax, bx
mov   ax, EMULATOR_MEMORY_SEGMENT
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

; INT 1A,0 - Read System Clock Counter
xor   ax, ax
int   01Ah
mov   word ptr cs:[VARIABLE_HOST_START_TIME+0], dx
mov   word ptr cs:[VARIABLE_HOST_START_TIME+2], cx

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
mov  cx, 00200h  ; initial cx, N flag
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

; INT 1A,0 - Read System Clock Counter
xor   ax, ax
int   01Ah
sub   dx, word ptr cs:[VARIABLE_HOST_START_TIME+0]
sbb   cx, word ptr cs:[VARIABLE_HOST_START_TIME+2]
mov   word ptr cs:[VARIABLE_HOST_ELAPSED_TIME+0], dx
mov   word ptr cs:[VARIABLE_HOST_ELAPSED_TIME+2], cx



;INT 21,3E - Close File Using Handle

mov   bx, word ptr cs:[VARIABLE_rom_file_handle]
mov   ah, 03Eh
int   021h

push  cs
pop   ds

IFDEF DEBUG_CYCLE_COUNTER
    
    les   ax, dword ptr ds:[VARIABLE_CYCLE_COUNT]
    mov   dx, es

    mov   di, 1
    mov   si, 086A0h;   di:si 100,000 in hex 
    xor   cx, cx

    loop_sub_100k:
    inc   cx
    sub   ax, si
    sbb   dx, di
    jnc   loop_sub_100k


    add   ax, si
    adc   dx, di
    dec   cx

    ; cx has count in 100,000s. 

    mov   bx, 10
    div   bx
    add   byte ptr ds:[gb_cycles_counted_start+12], dl
    cwd
    div   bx
    add   byte ptr ds:[gb_cycles_counted_start+11], dl
    cwd
    div   bx
    add   byte ptr ds:[gb_cycles_counted_start+10], dl
    cwd
    div   bx
    add   byte ptr ds:[gb_cycles_counted_start+8], dl
    cwd
    div   bx
    add   byte ptr ds:[gb_cycles_counted_start+7], dl

    xchg  ax, cx
    cwd
    div   bx
    add   byte ptr ds:[gb_cycles_counted_start+6], dl
    cwd
    div   bx
    add   byte ptr ds:[gb_cycles_counted_start+4], dl
    cwd
    div   bx
    add   byte ptr ds:[gb_cycles_counted_start+3], dl
    cwd
    div   bx
    add   byte ptr ds:[gb_cycles_counted_start+2], dl
    cwd
    div   bx
    add   byte ptr ds:[gb_cycles_counted_start+0], dl


    les   ax, dword ptr cs:[VARIABLE_HOST_ELAPSED_TIME+0]   
    mov   dx, es
    push  cs
    pop   es

    ; lets count seconds....
    xor   cx, cx
    xor   di, di
    mov   bx, 18
    mov   si, 19

    ; divide by 18.2 (instead of 18.206). good enough?

    sub_more_seconds:
        sub   ax, bx  ; 18
        sbb   dx, di 
        jc    done_counting_seconds
        inc   cx
        sub   ax, bx  ; 18
        sbb   dx, di 
        jc    done_counting_seconds
        inc   cx
        sub   ax, si  ; 19
        sbb   dx, di 
        jc    done_counting_seconds_plusone
        inc   cx
        sub   ax, bx  ; 18
        sbb   dx, di 
        jc    done_counting_seconds
        inc   cx
        sub   ax, bx  ; 18
        sbb   dx, di 
        jc    done_counting_seconds
        inc   cx
        jmp   sub_more_seconds

    done_counting_seconds_plusone:
        inc ax

    done_counting_seconds:
        add   ax, bx  ; 18
        ; we are lazy and dividing by 20 as an approximation... i.e. shift right once and use that digit as the decimal
        shr   ax, 1
        add   byte ptr ds:[host_cycles_counted_start+4], al
        mov   ax, cx
        cwd
        mov   bx, 10
        div   bx
        add   byte ptr ds:[host_cycles_counted_start+2], dl
        cwd
        div   bx
        add   byte ptr ds:[host_cycles_counted_start+1], dl
        cwd
        div   bx
        add   byte ptr ds:[host_cycles_counted_start+0], dl
        cwd


; 0x10000  XT ticks  = 1 hr
; 0x100000 GB cycles = 1 second

; GB cycles * 0xE10E = XT ticks (0x100000 gb cycles = 18.2 xt ticks per second) 
; so ((gb cycles / 0xE10E) * 60) / XTticks) = fps
; or gb cycles / (xt ticks * 0x3c0) = fps

    mov   ax, word ptr cs:[VARIABLE_HOST_ELAPSED_TIME+0]   
    mov   dx, 03C0h 
    mul   dx
    ;dx:ax 

    ;add   byte ptr ds:[host_fps+4], dl

    les   cx, dword ptr ds:[VARIABLE_CYCLE_COUNT]
    mov   si, es


    ;divide dx:ax by si:cx
    xor   di, di

loop_count_fps:
    sub   cx, ax
    sbb   si, dx
    inc   di
    jnc   loop_count_fps
    add   cx, ax 
    adc   si, dx 
    dec   di

    mov   ax, di
    cwd
    div   bx
    add   byte ptr ds:[host_fps+2], dl
    cwd
    div   bx
    add   byte ptr ds:[host_fps+1], dl
    cwd
    div   bx
    add   byte ptr ds:[host_fps+0], dl

    push  cs
    pop   es

    mov   dx, OFFSET gb_cycles_counted
    mov   ah, 09h
    push  cs
    pop   ds
    int   021h



ENDIF


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

; dword in debug for profiling total cycles
VARIABLE_CYCLE_COUNT:
dw 0, 0

VARIABLE_HOST_START_TIME:
dw 0, 0

VARIABLE_HOST_ELAPSED_TIME:
dw 0, 0

VARIABLE_pending_cycle_count:
dw 0
VARIABLE_IME_flag:
db 0

ALIGN 2

VARIABLE_cycles_since_last_handler:
dw 1  ; default value

VARIABLE_cycles_until_next_int_vblank:
dw 17559  ; minus one for jc logic
VARIABLE_cycles_until_next_int_stat:
dw 0FFFFh
VARIABLE_cycles_until_next_int_timer:
dw 0FFFFh
VARIABLE_cycles_until_next_int_serial:
dw 0FFFFh

VARIABLE_cycles_of_last_DIV_reset:
dw 0
VARIABLE_cycles_of_last_TIMA_reset:
dw 0
VARIABLE_TAC_clock_select_cycles_per_increment:
dw 00
VARIABLE_TAC_clock_select_cycles_per_increment_modulo:
db 0 
VARIABLE_TAC_clock_select_cycles_per_increment_mask:
db 0

; write in one word.
VARIABLE_IE_interrupt_enable_FFFF:
db 0
VARIABLE_interrupt_pending_flags:
db 0


VARIABLE_IF_interrupt_flag_FF0F:
db 0E1h, 00  ; vblank on by default.
VARIABLE_current_timer_control_ticks:
dw 256 * 64
VARIABLE_pending_cx_in_interrupt:
dw 0
VARIABLE_CACHED_DIV_FF04: ; 
db 018h, 0  ; default 018h? i guess. likely not imporant.
VARIABLE_CACHED_TMA_FF06: ; not sure if needed
db 0, 0  ; default 0
VARIABLE_CACHED_TIMA_TIMES_TMA:
dw 0  ; 256 * 256 
VARIABLE_FF00_joypad:
db 0CFh, 0
VARIABLE_serial_countdown_active:
db 0
VARIABLE_TIMA_countdown_active:
db 0
VARIABLE_stat_countdown_active:
db 0, 0

VARIABLE_cpu_in_halt:
dw 0

VARIABLE_EMULATOR_MEMORY_SEGMENT:
dw EMULATOR_MEMORY_SEGMENT

TABLE_TIMER_MUL_LOOKUP:
dw 00100h, 00004h, 00010h, 00040h
; lo byte modulo, hi byte mask
TABLE_TIMER_MODULO_LOOKUP:
dw 000FFh, 0FC03h, 0F00Fh, 0C03Fh


VARIABLE_cycles_before_io_readwrite:
dw 0



gb_cycles_counted:
db 0Ah, 0Dh, "Game Boy Cycles: "
gb_cycles_counted_start:
db '0,000,000,000'

host_cycles_counted:
db "   Host Runtime: "
host_cycles_counted_start:
db '000.0 sec   FPS: '
host_fps:
db '000.0$'

public VARIABLE_TAC_clock_select_cycles_per_increment_mask
public VARIABLE_cycles_before_io_readwrite
public VARIABLE_TAC_clock_select_cycles_per_increment_modulo
public VARIABLE_TAC_clock_select_cycles_per_increment
public VARIABLE_cycles_of_last_TIMA_reset
public VARIABLE_cycles_of_last_DIV_reset
public TABLE_TIMER_MUL_LOOKUP
public TABLE_TIMER_MODULO_LOOKUP
public VARIABLE_cpu_in_halt
public VARIABLE_stat_countdown_active
public VARIABLE_serial_countdown_active
public VARIABLE_TIMA_countdown_active
public VARIABLE_CACHED_TIMA_TIMES_TMA
public VARIABLE_interrupt_pending_flags
public VARIABLE_EMULATOR_MEMORY_SEGMENT
public VARIABLE_pending_cx_in_interrupt
public VARIABLE_IE_interrupt_enable_FFFF
public VARIABLE_IF_interrupt_flag_FF0F
public VARIABLE_current_timer_control_ticks
public VARIABLE_cycles_until_next_int_vblank
public VARIABLE_cycles_until_next_int_stat
public VARIABLE_cycles_until_next_int_timer
public VARIABLE_cycles_until_next_int_serial
public VARIABLE_FF00_joypad




public VARIABLE_cycles_since_last_handler
public VARIABLE_CYCLE_COUNT
public VARIABLE_pointer_to_core_1
public VARIABLE_pointer_to_core_2
public VARIABLE_BAD_OPCODE_handler
public VARIABLE_pending_cycle_count
public VARIABLE_IME_flag

rom_filename:
db "testrom.gb", 0
dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; leave space for filename

ENDS


END