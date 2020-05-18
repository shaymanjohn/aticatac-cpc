include "includes.asm"

start
    xor a
    call scr_set_mode

    call set_pens_off

    ld d, hw_black
    call set_border                ; border to black

    call set_screen_size
    call setup_data
    
    call draw_panel
    
    call install_interrupts 

    call wait_vsync
    call set_pens       

    jp $                            ; spin here

setup_data
    xor a
    ld (room_number), a

    ld a, -1
    ld (old_room_number), a

    ld a, 0x2c
    ld (player_x), a

    ld a, 0x57
    ld (player_y), a

    call make_scr_table
    ld hl, scr_addr_table_c0
    ld (scr_addr_table), hl

    ret
