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
    ld hl, menu_tasks
    ld (current_game_state), hl

    ld hl, atic_title_Start
    call init_sound_system

    ld hl, menu_interrupts
    ld (current_interrupts), hl

    call wait_vsync
    call set_pens_off

    ld a, 0x08
    ld (pen_delay), a

    call clear_screens
    jp init_menu

select_game
    ld hl, game_tasks
    ld (current_game_state), hl

    ld hl, game_interrupts
    ld (current_interrupts), hl

    SET_MODE 0
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

    call init_player
    call init_health
    call init_food
    call init_doors
    call init_collectables
    call init_score

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

    ld bc, 0
    call add_to_score

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
    ld hl, falling_tasks
    ld (current_game_state), hl

    ld hl, falling_interrupts
    ld (current_interrupts), hl

    call clear_room

    ld a, (hidden_screen_base_address)
    xor 0x40
    call clear_room2

    call reset_sprites
    call reset_weapon

    xor a
    ld (save_fall_data), a
    ld (save_fall_data + 1), a

    ld a, 1
    ld (still_falling), a

    ld a, -1
    ld (fall_index), a

    ld e, sound_menu
    jp play_sfx

select_end
    ld hl, end_tasks
    ld (current_game_state), hl
    ld hl, end_game_interrupts
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
    jp init_endgame
