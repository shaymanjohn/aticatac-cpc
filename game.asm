game_tasks
    ld a, item_bank_config
    call set_memory_bank

    ld a, (room_changed)
	and a
    jp z, skip_room_1

    di
    call clear_room 
    call draw_room

	ld a, interrupt_notReady
	ld (interrupt_index), a
    ei
    
    ret

skip_room_1    
    call move_player

; switch to sprite bank
	ld a, sprite_bank_config
	call set_memory_bank

	call erase_player
    call draw_player

    ld a, room_bank_config
    call set_memory_bank

	call check_doors

	ld a, (keys_pressed)
	bit player_fire2_bit, a
	call nz, pickup_tapped    

    ld a, item_bank_config
    call set_memory_bank

    ret