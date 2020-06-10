include "includes.asm"

start
    xor a
    call scr_set_mode    

    call set_pens_off
    call wait_vsync

    di
    ld sp, 0x7fff

    ld d, hw_black
    call set_border                ; border to black

    call set_screen_properties
    call setup_game_data

    call install_interrupts

    jp $                            ; spin here, interrupts will handle flow

setup_game_data
    call make_scr_table
    ld hl, scr_addr_table_c0
    ld (scr_addr_table), hl

; Create copy of sprites, rotated a pixel to the left

	ld bc, sprite_bank_config           ; page in sprite bank
	out (c), c    

    ld ix, sprite_bank_player_kd_0_0
    ld de, sprite_bank_player_kd_0_1
    ld b, player_width
    ld c, 240
    call rotate_gfx                 ; (& ignore mask)

; and then generate a new mask for them.
    ld hl, sprite_bank_player_kd_0_1
    ld b, player_width
    ld c, 240
    call gen_mask

	ld bc, item_bank_config             ; default page back in
	out (c), c    

    ld b, state_game
    ld b, state_menu
    call switch_game_state    

    ret

switch_game_state
	ld a, interrupt_notReady
	ld (interrupt_index), a

    ld a, b
    cp state_menu
    jp z, select_menu

    cp state_game
    jp z, select_game

    cp state_falling
    jp z, select_falling

    cp state_end
    jp z, select_end

    ret

select_menu
    ld hl, menu_interrupts
    ld (current_interrupts), hl

    call wait_vsync
    call set_pens_off

    call clear_screen
    call init_menu
    ret

select_game
    ld hl, game_interrupts
    ld (current_interrupts), hl

    call wait_vsync
    call set_pens_off

    call clear_screen

    xor a    
    ld (room_number), a
    ld (player_orientation), a
    ld (game_over), a

    inc a
    ld (room_changed), a

    ld a, 5                     ; second frame - 5 because each frame is shown 4 times
    ld (player_frame), a

    ld a, 0x2c
    ld (player_x), a

    ld a, 0x57
    ld (player_y), a

    ld a, player_is_going_right
    ld (player_orientation), a

    ld a, 3
    ld (num_lives), a

    ld a, max_energy
    ld (energy), a

    call draw_panel

    ld a, (hidden_screen_base_address)
    ld h, a
    ld l, 0
    xor 0x40
    ld d, a
    ld e, 0
    ld bc, 0x3fff
    ldir

    call set_pens
    ret

select_falling
    ld hl, falling_interrupts
    ld (current_interrupts), hl

    call clear_room

    ld a, (hidden_screen_base_address)
    xor 0x40
    call clear_room2

    xor a
    ld (save_fall_data), a
    ld (save_fall_data + 1), a

    ld a, 1
    ld (still_falling), a

    ld a, -1
    ld (fall_index), a

    ret

select_end
    ld hl, end_interrupts
    ld (current_interrupts), hl

    ret

clear_screen
    ld hl, 0xc000
    ld de, 0xc001
    ld bc, 0x3fff
    ld (hl), 0
    ldir

    ld hl, 0x8000
    ld de, 0x8001
    ld bc, 0x3fff
    ld (hl), 0
    ldir

    ret

include "include_banks.asm"
