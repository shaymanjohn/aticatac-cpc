game_tasks
    SELECT_BANK item_bank_config

    ld a, (room_changed)
	and a
    jp z, skip_room_change

    di
    call clear_room 
    call draw_room

	ld a, interrupt_notReady
	ld (interrupt_index), a
    ei
    
    ret

skip_room_change
    BORDER_ON hw_brightYellow
    call move_player

    BORDER_ON hw_orange
    call show_clock

; switch to sprite bank
    SELECT_BANK sprite_bank_config

    BORDER_ON hw_brightBlue

	call erase_player

    BORDER_ON hw_brightRed

    call draw_player

    SELECT_BANK room_bank_config

    BORDER_ON hw_brightGreen

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
