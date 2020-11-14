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
    jr z, no_pockets_to_update
    
    dec a
    ld (do_pockets), a
    call draw_pockets

no_pockets_to_update
    ld a, (erase_food_with_index + 1)
    and a
    jr z, tombstone_draw

    ld ixh, a
    ld a, (erase_food_with_index)
    ld ixl, a
    SELECT_BANK sprite_bank_config 
    call draw_food_item2

    ld hl, 0
    ld (erase_food_with_index), hl

tombstone_draw
    ld a, (draw_tombstone_with_index + 1)
    and a
    jr z, no_food_removal

    ld ixh, a
    ld a, (draw_tombstone_with_index)
    ld ixl, a
    SELECT_BANK sprite_bank_config 
    call draw_food_item2

    ld hl, 0
    ld (draw_tombstone_with_index), hl    

no_food_removal
    SELECT_BANK sprite_bank_config

    ld a, (player_growing)
    and a
    jp nz, continue_player_transition

    ld a, (heartbeat)
    cp 31
    call z, health_decay

    SELECT_BANK sprite_bank_config
    call erase_player
    call draw_player

    SELECT_BANK room_bank_config
    call move_player    
    call check_doors

skip_some_others
    SELECT_BANK sprite_bank_config
    call erase_weapon
    call move_weapon
    call draw_weapon

    SELECT_BANK baddie_bank_config
    
    ld ix, boss
    DO_SPRITE

    ld ix, sprite1
    DO_SPRITE    

    ld ix, sprite2
    DO_SPRITE    

    ld ix, sprite3
    DO_SPRITE

    call check_weapon_hit
    call check_player_hit_baddie

    ld a, (this_rooms_food_count)
    and a
    call nz, check_food_collision    

    SELECT_BANK room_bank_config

    ld de, (door_to_toggle)
    ld a, d
    or e
    jr z, skip_door_toggle

    ld hl, 0
    ld (door_to_toggle), hl

    ld ixh, d
    ld ixl, e
    call draw_item

skip_door_toggle
    ld a, (heartbeat)
    cp 25
    call z, update_doors    

ignore_doors
	ld a, (keys_pressed)
	bit player_fire2_bit, a
	call nz, pickup_tapped

    SELECT_BANK item_bank_config

    ld a, (game_over)
    and a
    jr nz, all_over

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

continue_player_transition
    call erase_small_player
    call draw_small_player

    ld a, (player_growing)
    cp player_disappearing
    jr z, player_shrinking

    ld a, (heartbeat)
    and 0x03
    cp 0x03
    jr nz, continue_game    

    ld a, (current_player_height)
    ld b, a
    ld a, (actual_player_height)
    cp b
    jr z, transition_complete    

    ld a, b
    inc a
    ld (current_player_height), a
    ld hl, (current_height_gfx_offset)
    ld bc, -5
    add hl, bc
    ld (current_height_gfx_offset), hl
    jr continue_game

player_shrinking
    ld a, (current_player_height)
    dec a
    jr nz, still_shrinking

    call add_tombstone
    call make_player_appear
    jr continue_game

still_shrinking
    ld a, (heartbeat)
    and 0x03
    cp 0x03
    jr nz, continue_game

    ld a, (current_player_height)
    dec a
    ld (current_player_height), a
    ld hl, (current_height_gfx_offset)
    ld bc, 5
    add hl, bc
    ld (current_height_gfx_offset), hl
    jr continue_game

transition_complete
    xor a
    ld (player_growing), a

continue_game
    SELECT_BANK room_bank_config    
    jp skip_some_others    
    