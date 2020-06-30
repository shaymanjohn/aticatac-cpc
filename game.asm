game_tasks
    ld a, item_bank_config
    call set_memory_bank

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
	ld a, sprite_bank_config
	call set_memory_bank

    BORDER_ON hw_brightBlue

	call erase_player

    BORDER_ON hw_brightRed

    call draw_player

    ld a, room_bank_config
    call set_memory_bank

    BORDER_ON hw_brightGreen

	call check_doors

	ld a, (keys_pressed)
	bit player_fire2_bit, a
	call nz, pickup_tapped

    ld a, item_bank_config
    call set_memory_bank

    BORDER_OFF

    ret