include "includes.asm"

start
    call set_pens_off
    call wait_vsync

    di
    ld sp, 0x4000

    SELECT_BANK item_bank_config

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
    ld hl, (current_game_state)
    jp (hl)

current_game_state
    defw 0x00

frame_ready
    defb 0x00

code_end

save"gamecode.bin",0x100,code_end-code_start,DSK,"aticatac.dsk"

include "include_banks.asm"
