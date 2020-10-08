init_player
    ld hl, (selected_player)
    ld (anim_frames_table), hl

    ld a, (selected_player_height)
    ld (actual_player_height), a

    ld a, 3
    ld (num_lives), a

make_player_appear
    ld a, default_frame
    ld (player_frame), a

    ld a, 0x2c
    ld (player_x), a

    ld a, 0x57
    ld (player_y), a

    ld a, player_is_going_right
    ld (player_orientation), a

    ld a, player_appearing
    ld (player_growing), a

    ld a, 1
    ld (current_player_height), a

    ld a, (actual_player_height)
    dec a

    ld l, a
    ld h, 0
    add hl, hl
    add hl, hl
    ld c, a
    ld b, 0
    add hl, bc
    ld (current_height_gfx_offset), hl

	ld a, max_health
    ld (health), a    

    ret

make_player_disappear
    ld a, player_disappearing
    ld (player_growing), a

    ld a, (actual_player_height)
    ld (current_player_height), a

    ld hl, 0
    ld (current_height_gfx_offset), hl

    ld ix, sprite1
    ld a, (ix + spr_state)
    cp state_dead
    jr z, kill_2
    call kill_sprite

kill_2
    ld ix, sprite2
    ld a, (ix + spr_state)
    cp state_dead
    jr z, kill_3
    call kill_sprite

kill_3
    ld ix, sprite3
    ld a, (ix + spr_state)
    cp state_dead
    ret z
    jp kill_sprite

draw_player
    ld a, (player_y)    
    ld l, a
    ld h, 0
    add hl, hl
    ld de, (scr_addr_table)
    add hl, de

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a

    ld a, (player_x)
    ld e, a
    srl a
    ld c, a
    ld b, 0
    add hl, bc

    push hl                                ; save screen address

    ld a, (hidden_screen_base_address)
    cp 0xc0
    jp z, save_address_c0
    ld (save_player_address_80), hl        ; save this for erase later
    jp saved_address

save_address_c0
    ld (save_player_address_c0), hl

saved_address
    ld b, 0
    ld a, e
    and 0x01
    jp z, dplay1
    ld b, num_player_frames

dplay1
    ld a, (player_frame)
    srl a
    srl a
    add b

    ld b, a
    ld a, (player_orientation)
    add b

    ld l, a
    ld h, 0
    add hl, hl
    ld de, (anim_frames_table)
    add hl, de
    ld e, (hl)
    inc hl
    ld d, (hl)

    pop hl                                  ; hl is screen, de is gfx

    ld a, (hidden_screen_base_address)
    cp 0xc0
    jp z, save_frame_c0
    ld (save_player_frame_80), de        ; save this for erase later
    jp draw_player_entry2

save_frame_c0
    ld (save_player_frame_c0), de

draw_player_entry2           
    ld a, (actual_player_height)
    ld b, a

dplay2
    push hl
    
    ld a, (de)              ; de is screen
    xor (hl)                ; hl is gfx
    ld (hl), a
    inc l
    inc de

    ld a, (de)
    xor (hl)
    ld (hl), a
    inc l
    inc de

    ld a, (de)
    xor (hl)
    ld (hl), a
    inc l    
    inc de

    ld a, (de)
    xor (hl)
    ld (hl), a
    inc l    
    inc de

    ld a, (de)
    xor (hl)
    ld (hl), a
    inc de

    pop hl
    GET_NEXT_SCR_LINE

    djnz dplay2

    ret

erase_small_player
    ld a, (hidden_screen_base_address)
    cp 0xc0
    jp nz, erase_small_with_80

    ld de, (save_player_frame_c0)
    ld hl, (save_player_address_c0)
    jp erasex_small

erase_small_with_80
    ld de, (save_player_frame_80)
    ld hl, (save_player_address_80)
    
erasex_small
    ld a, h
    or l
    ret z                       ; stop here if not yet set

    jp draw_player_entry2_small

draw_small_player
    ld a, (player_y)
    ld c, a
    ld a, (current_player_height)    
    ld b, a
    ld a, (actual_player_height)
    sub b
    add c

    ld l, a
    ld h, 0
    add hl, hl
    ld de, (scr_addr_table)
    add hl, de

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a

    ld a, (player_x)
    ld e, a
    srl a
    ld c, a
    ld b, 0
    add hl, bc

    push hl                                ; save screen address

    ld a, (hidden_screen_base_address)
    cp 0xc0
    jp z, save_small_address_c0
    ld (save_player_address_80), hl        ; save this for erase later
    jp saved_small_address

save_small_address_c0
    ld (save_player_address_c0), hl

saved_small_address
    ld b, 0
    ld a, e
    and 0x01
    jp z, dplay1_small
    ld b, num_player_frames

dplay1_small
    ld a, (player_frame)
    srl a
    srl a
    add b

    ld b, a
    ld a, (player_orientation)
    add b

    ld l, a
    ld h, 0
    add hl, hl
    ld de, (anim_frames_table)
    add hl, de
    ld e, (hl)
    inc hl
    ld d, (hl)

    ld hl, (current_height_gfx_offset)
    add hl, de
    ex de, hl

    pop hl                                  ; hl is screen, de is gfx

    ld a, (hidden_screen_base_address)
    cp 0xc0
    jp z, save_frame_c0_small
    ld (save_player_frame_80), de        ; save this for erase later
    jp draw_player_entry2_small

save_frame_c0_small
    ld (save_player_frame_c0), de

draw_player_entry2_small
    ld a, (current_player_height)
    ld b, a

dplay2_small
    push hl
    
    ld a, (de)              ; de is screen
    xor (hl)                ; hl is gfx
    ld (hl), a
    inc l
    inc de

    ld a, (de)
    xor (hl)
    ld (hl), a
    inc l
    inc de

    ld a, (de)
    xor (hl)
    ld (hl), a
    inc l    
    inc de

    ld a, (de)
    xor (hl)
    ld (hl), a
    inc l    
    inc de

    ld a, (de)
    xor (hl)
    ld (hl), a
    inc de

    pop hl
    GET_NEXT_SCR_LINE

    djnz dplay2_small
    ret    

erase_player
    ld a, (hidden_screen_base_address)
    cp 0xc0
    jp nz, erase_with_80

    ld de, (save_player_frame_c0)
    ld hl, (save_player_address_c0)
    jp erasex

erase_with_80
    ld de, (save_player_frame_80)
    ld hl, (save_player_address_80)
    
erasex
    ld a, h
    or l
    ret z                       ; stop here if not yet set

    jp draw_player_entry2

decrease_lives
    ld a, (num_lives)
    and a
    jr nz, still_alive

    ld a, game_finished
    ld (game_over), a
    ret        

still_alive
    dec a
    ld (num_lives), a
    jp remove_life

erase_player_select
    ld l, character_select_y
    ld h, 0
    add hl, hl
    ld de, (scr_addr_table)
    add hl, de

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a

    ld a, (player_select_x)
    dec a                           ; subtract 1 so we don't leave a trail when moving
    dec a
    srl a
    ld c, a
    ld b, 0
    add hl, bc

    ld b, max_player_height           ; hl has screen address
    ld e, 0

dplay_erase_fast_2    
    ld (hl), e
    inc l
    ld (hl), e
    inc l
    ld (hl), e
    inc l
    ld (hl), e
    inc l
    ld (hl), e
    inc l
    ld (hl), e
    inc l    
    ld (hl), e                      ; clear an extra column, again to stop moving trails

    dec l
    dec l
    dec l
    dec l
    dec l
    dec l
    GET_NEXT_SCR_LINE
    djnz dplay_erase_fast_2
    ret

draw_player_select              ; don't save background or mask here
    ld hl, character_select_y
    add hl, hl
    ld de, (scr_addr_table)
    add hl, de

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a

    ld a, (player_select_x)
    ld e, a
    srl a
    ld c, a
    ld b, 0
    add hl, bc

    push hl

    ld b, 0
    ld a, e
    and 1
    jp z, dplay_fast1
    ld b, num_player_frames

dplay_fast1
    ld a, (player_frame)
    srl a
    srl a
    add b

    ld b, a
    ld a, (player_orientation)
    add b

    ld l, a
    ld h, 0
    add hl, hl
    ld de, (anim_frames_table)
    add hl, de
    ld e, (hl)
    inc hl
    ld d, (hl)

    pop hl

    ld a, (actual_player_height)
    ld b, a                     ; hl as screen address, de as gfx

dplay_fast_2
    push hl

    ex de, hl
    ldi
    ldi
    ldi
    ldi
    ldi
    ex de, hl

    pop hl
    GET_NEXT_SCR_LINE

    djnz dplay_fast_2
    ret

reset_player
    ld hl, 0
    ld (save_player_address_c0), hl
    ld (save_player_address_80), hl
    ret

player_character
    defb 0

player_growing
    defb 0

player_x
    defb 0

player_y
    defb 0

updated_x
    defb 0x00

updated_y
    defb 0x00

transition_keypress
    defb 0x00    

actual_player_height
    defb serf_height

current_player_height
    defb 0

score
    defs 3

current_height_gfx_offset
    defw 0

player_select_x
    defb 0

player_orientation
    defb 0

player_frame
    defb 0

num_lives
    defb 0

health
    defb 0

drawn_health
    defb 0

game_over
    defb 0

magic_door
    defb item_clock

this_rooms_door_count
    defb 0    

this_rooms_door_list
    defs max_doors * 8

this_rooms_food_list
    defs max_food * 2

this_rooms_food_count
    defb 0

this_item_width
    defb 0

this_item_height
    defb 0        

show_vsync
    defb 1

screen_transition_in_progress
    defb 0

save_player_address_c0
    defw 0

save_player_address_80    
    defw 0

save_player_frame_c0
    defw 0

save_player_frame_80    
    defw 0    

anim_frames_table
    defw serf_frames_table
