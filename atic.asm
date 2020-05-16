include "includes.asm"

start
    call set_pens_off

    xor a
    call scr_set_mode

    ld bc, 0
    call scr_set_border

    call set_screen_size
    call setup_data
    
    call draw_panel
    call set_pens

loop
    call draw_room

loop2
    call wait_vblank
    call update_player

    ld a, (room_number)
    ld hl, old_room_number
    cp (hl)
    jp z, loop2

    call clear_room 
    jp loop

setup_data
    xor a
    ld (room_number), a

    ld a, 0x2c
    ld (player_x), a

    ld a, 0x57
    ld (player_y), a

    call make_scr_table
    ld hl, scr_addr_table_c0
    ld (scr_addr_table), hl
    ret