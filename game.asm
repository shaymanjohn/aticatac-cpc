game_tasks
    SELECT_BANK item_bank_config
    
    ld a, (room_changed)
	and a
    jp nz, room_has_changed
    
    BORDER_ON hw_orange
    ld a, (tell_time)
    and a
    call nz, show_clock

    BORDER_ON hw_pink
    call update_chicken

    BORDER_ON hw_brightWhite
    ld a, (do_pockets)
    and a
    jp z, no_pockets
    
    dec a
    ld (do_pockets), a
    call draw_pockets

no_pockets
    BORDER_ON hw_brightYellow
    SELECT_BANK sprite_bank_config    
    call move_player
	call erase_player
    call draw_player

    BORDER_ON hw_brightRed
    call erase_weapon
    call move_weapon
    call draw_weapon

    BORDER_ON hw_brightBlue
    SELECT_BANK baddie_bank_config
    call do_sprites

    BORDER_ON hw_brightGreen
    SELECT_BANK room_bank_config
	call check_doors

	ld a, (keys_pressed)
	bit player_fire2_bit, a
	call nz, pickup_tapped

    SELECT_BANK item_bank_config
    BORDER_OFF

    ld a, (keyboard_state + 4)          ; m for menu
    bit 6, a
    ret nz

    ld b, state_menu
    jp switch_game_state

do_sprites
    ; ld ix, boss
    ; call do_sprite

    ld ix, sprite1
    call do_sprite

    ld ix, sprite2
    call do_sprite

    ld ix, sprite3
    jp do_sprite

room_has_changed
    di
    call clear_room 
    call draw_room

	ld a, interrupt_notReady
	ld (interrupt_index), a
    ei
    
    ret
    