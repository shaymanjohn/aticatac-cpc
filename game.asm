game_tasks
    SELECT_BANK item_bank_config
    
    ld a, (room_changed)
	and a
    jp nz, room_has_changed
    
    ld a, (tell_time)
    and a
    call nz, show_clock

    call update_chicken

    ld a, (do_pockets)
    and a
    jp z, no_pockets_to_update
    
    dec a
    ld (do_pockets), a
    call draw_pockets

no_pockets_to_update
    ld a, (erase_food_with_index + 1)
    and a
    jp z, no_food_removal

    ld ixh, a
    ld a, (erase_food_with_index)
    ld ixl, a
    SELECT_BANK room_bank_config 
    call draw_food_item2

    ld hl, 0
    ld (erase_food_with_index), hl

no_food_removal
    SELECT_BANK sprite_bank_config

    ld a, (player_appearing)
    and a
    jp nz, make_player_appear

    SELECT_BANK sprite_bank_config
    call erase_player
    call draw_player

    SELECT_BANK room_bank_config
    call move_player    
    call check_doors

    BORDER_ON hw_brightRed
    SELECT_BANK sprite_bank_config
    call erase_weapon
    call move_weapon
    call draw_weapon

    BORDER_ON hw_brightBlue
    SELECT_BANK baddie_bank_config
    
    ld ix, boss
    DO_SPRITE

    ld ix, sprite1
    DO_SPRITE    

    ld ix, sprite2
    DO_SPRITE    

    ld ix, sprite3
    DO_SPRITE

    BORDER_ON hw_brightWhite
    call check_weapon_hit

    BORDER_ON hw_brightGreen
    SELECT_BANK room_bank_config

    ld a, (this_rooms_food_count)
    and a
    call nz, check_food_collision    

    ; ld a, (screen_transition_in_progress)
    ; and a
    ; jp nz, ignore_doors

skip_all_others
    ld de, (door_to_toggle)
    ld a, d
    or e
    jp z, skip_door_toggle

    ld hl, 0
    ld (door_to_toggle), hl

    ld ixh, d
    ld ixl, e
    call draw_item

skip_door_toggle
	; call check_doors

    ld a, (heartbeat)
    cp 25
    call z, update_doors    

ignore_doors
	ld a, (keys_pressed)
	bit player_fire2_bit, a
	call nz, pickup_tapped

    SELECT_BANK item_bank_config
    BORDER_OFF

    ld a, (game_over)
    and a
    jp nz, all_over

    ld a, (keyboard_state + 4)          ; m for menu
    bit 6, a
    ret nz

all_over
    ld b, state_end
    jp switch_game_state

room_has_changed
    call draw_room

	ld a, interrupt_notReady
	ld (interrupt_index), a    
    ret

make_player_appear
    dec a
    ld (player_appearing), a

    call erase_small_player
    call draw_small_player

    ld a, (current_player_height)
    ld b, a
    ld a, (actual_player_height)
    cp b
    jp z, player_full

    ld a, (heartbeat)
    and 0x07
    cp 0x07
    jp nz, player_full

    ld a, b
    inc a
    ld (current_player_height), a
    ld hl, (current_height_gfx_offset)
    ld bc, -5
    add hl, bc
    ld (current_height_gfx_offset), hl

player_full
    SELECT_BANK room_bank_config    
    jp skip_all_others    
    