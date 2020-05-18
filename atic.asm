include "includes.asm"

start
    xor a
    call scr_set_mode

    call set_pens_off

    ld d, hw_black
    call set_border                ; border to black

    call set_screen_size
    call setup_game_data
    
    call draw_panel
    
    call install_interrupts 

    call wait_vsync
    call set_pens       

    jp $                            ; spin here, interrupts will handle flow

setup_game_data
    xor a
    ld (room_number), a

    inc a
    ld (room_changed), a

    ld a, 0x2c
    ld (player_x), a

    ld a, 0x57
    ld (player_y), a

    call make_scr_table
    ld hl, scr_addr_table_c0
    ld (scr_addr_table), hl

    ret
