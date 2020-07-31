switch_game_state
	ld a, interrupt_notReady
	ld (interrupt_index), a    

    ld a, b
    ld (current_game_state), a

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
    ld hl, atic_title_Start
    call init_sound_system

    ld hl, menu_interrupts
    ld (current_interrupts), hl

    call wait_vsync
    call set_pens_off

    ld a, 0x08
    ld (pen_delay), a

    call clear_screens
    call init_menu

    ret

select_game
    ld hl, game_interrupts
    ld (current_interrupts), hl

	ld bc, 0x7f00 + 128 + 4 + 8 + 0		; mode 0
	out (c), c    

    call clear_screens

    xor a    
    ld (room_number), a
    ld (player_orientation), a
    ld (game_over), a
    ld (heartbeat), a

    inc a
    ld (room_changed), a

    ; ld a, 23
    ; ld (room_number), a

    ld a, default_frame
    ld (player_frame), a

    ld a, 0x2c
    ld (player_x), a

    ld a, 0x57
    ld (player_y), a

    ld a, player_is_going_right
    ld (player_orientation), a

    ld hl, (selected_player)
    ld (anim_frames_table), hl

    ld a, (selected_player_height)
    ld (actual_player_height), a

    ld a, 3
    ld (num_lives), a

    xor a
    ld (hunger_index), a

    call init_food
    call init_collectables

    call draw_panel

    ld hl, font_0 - 256
    ld (font_type), hl

    call reset_clock

; reset rooms visited flag
    SELECT_BANK room_bank_config

    ld hl, room_bank_RoomInfo
    ld b, (end_room_bank - room_bank_RoomInfo) / 2
reset_room_count_loop
    res 7, (hl)
    inc hl
    inc hl
    djnz reset_room_count_loop

    SELECT_BANK item_bank_config    

    ld ix, time_text
    call show_text

    ld ix, score_text
    call show_text

    ld a, (hidden_screen_base_address)
    ld h, a
    ld l, 0
    xor 0x40
    ld d, a
    ld e, 0
    ld bc, 0x4000
    ldir

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

    ld e, sound_menu
    call play_sfx    

    ret

select_end
    ld hl, end_interrupts
    ld (current_interrupts), hl

    ld a, (game_over)
    cp game_completed
    jr z, dont_clear_screens

    call clear_room

    ld a, (hidden_screen_base_address)
    xor 0x40
    call clear_room2
    jr do_ending

dont_clear_screens
    SELECT_BANK sprite_bank_config
    call erase_player

do_ending
    call init_endgame
    ret
