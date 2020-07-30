include "includes.asm"

start
    call set_pens_off
    call wait_vsync

    di
    ld sp, 0x4000

    ld d, hw_black
    call set_border

    call set_screen_properties
    call setup_game_data

    call install_interrupts

main_loop
    ld a, (frame_ready)
    and a
    jp nz, main_loop

    call perform_current_state

    ld a, 1
    ld (frame_ready), a

    jp main_loop

perform_current_state
    ld a, (current_game_state)
    add a
    ld e, a
    ld d, 0
    ld hl, jump_table
    add hl, de
    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a
    jp (hl)

jump_table
    defw menu_tasks
    defw game_tasks
    defw falling_tasks
    defw end_tasks

current_game_state
    defb 0x00

frame_ready
    defb 0x00

code_end

save"gamecode.bin",0x100,code_end-code_start,DSK,"aticatac.dsk"

include "include_banks.asm"
