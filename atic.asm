include "includes.asm"

start
    di
    ld sp, 0x4000

    call set_pens_off
    call wait_vsync

    call set_screen_properties
    call setup_game_data
    call install_interrupts

    ld hl, frame_ready

main_loop    
    ld a, (hl)              ; wait for frame_ready
    and a
    jr nz, main_loop

current_game_state
    call 0                  ; modified by state_manager

    ld hl, frame_ready
    ld (hl), 1
    jr main_loop

frame_ready
    defb 0x00

code_end

save "gamecode.bin", 0x100, code_end-code_start, DSK, "aticatac.dsk"

include "include_banks.asm"
