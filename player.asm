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
    srl a
    ld c, a
    ld b, 0
    add hl, bc

    push hl

    ld a, (hidden_screen_base_address)
    cp 0xc0
    jp z, save_address_c0
    ld (save_player_address_80), hl        ; save this for erase later
    ld bc, save_screen_data_80
    jp saved_address

save_address_c0
    ld (save_player_address_c0), hl
    ld bc, save_screen_data_c0    

saved_address
    push bc

    ld b, 0
    ld a, (player_x)
    and 1
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

    pop bc
    pop hl

draw_player_entry2                  
    ld ixh, player_height           ; hl as screen address, de as gfx

dplay2
    push hl

    ex de, hl
    
    ld a, (de)              ; de is screen
    ld (bc), a              ; bc is save space
    and (hl)                ; hl is gfx
    inc hl
    or (hl)
    inc hl
    ld (de), a
    inc de
    inc bc

    ld a, (de)
    ld (bc), a
    and (hl)
    inc hl
    or (hl)
    inc hl
    ld (de), a
    inc de
    inc bc

    ld a, (de)
    ld (bc), a
    and (hl)
    inc hl
    or (hl)
    inc hl
    ld (de), a
    inc de
    inc bc

    ld a, (de)
    ld (bc), a
    and (hl)
    inc hl
    or (hl)
    inc hl
    ld (de), a
    inc de
    inc bc

    ld a, (de)
    ld (bc), a 
    and (hl)
    inc hl
    or (hl)
    inc hl
    ld (de), a
    inc bc

    ex de, hl

    pop hl
    call scr_next_line

    dec ixh
    jp nz, dplay2

    ret

erase_player
    ld a, (hidden_screen_base_address)
    cp 0xc0
    jp nz, erase_with_80

    ld hl, (save_player_address_c0)
    ld de, save_screen_data_c0 
    jp erasex

erase_with_80
    ld hl, (save_player_address_80)
    ld de, save_screen_data_80    
    
erasex
    ld a, h
    or l
    ret z                       ; stop here if not yet set

    ld b, player_height

eplay2
    push hl
    
    ld a, (de)
    ld (hl), a
    inc hl
    inc de
    ld a, (de)
    ld (hl), a
    inc hl
    inc de
    ld a, (de)
    ld (hl), a
    inc hl
    inc de    
    ld a, (de)
    ld (hl), a
    inc hl
    inc de
    ld a, (de)
    ld (hl), a
    inc de

    pop hl
    call scr_next_line
    djnz eplay2

    ret

move_player
    xor a
    ld (keys_pressed), a

    ld a, (screen_transition_in_progress)
    and a
    jp z, can_move

    dec a
    ld (screen_transition_in_progress), a
    ret

can_move    
    ld a, (keyboard_state)
    ld c, a
    ld d, 0
    ld e, 0

    bit 0, c
    ld b, -player_vert_speed
    call z, move_player_up

    bit 2, c
    ld b, player_vert_speed
    call z, move_player_down

    ld a, (keyboard_state + 1)
    bit 0, a
    ld b, -player_horiz_speed
    call z, move_player_left

    bit 1, c
    ld b, player_horiz_speed
    call z, move_player_right

    ld a, d
    or e
    jp nz, inc_frame

    ld a, 5
    ld (player_frame), a
    ret

inc_frame
    ld a, (player_frame)
    inc a
    and 0x0f
    ld (player_frame), a    

    ret

move_player_left
    ld hl, keys_pressed
    set keypress_left, (hl)

    ld a, d
    xor 1
    ld d, a

    ld a, player_is_going_left
    ld (player_orientation), a
    ld a, (min_x)
    ld h, a    
    ld a, (player_x)
    add b
    cp h
    jr nc, minx_ok
    ld a, h

minx_ok    
    ld (player_x), a
    ret    

move_player_right
    ld hl, keys_pressed
    set keypress_right, (hl)

    ld a, d
    xor 1
    ld d, a
    
    ld a, player_is_going_right
    ld (player_orientation), a

    ld a, (max_x)
    ld h, a
    ld a, (player_x)
    add b
    cp h
    jr c, maxx_ok
    ld a, h

maxx_ok    
    ld (player_x), a
    ret

move_player_up
    ld hl, keys_pressed
    set keypress_up, (hl)

    ld a, e
    xor 1
    ld e, a    

    ld a, player_is_going_up
    ld (player_orientation), a

    ld a, (min_y)
    ld h, a
    ld a, (player_y)
    add b
    cp h
    jr nc, miny_ok
    ld a, h

miny_ok    
    ld (player_y), a
    ret

move_player_down
    ld hl, keys_pressed
    set keypress_down, (hl)

    ld a, e
    xor 1
    ld e, a

    ld a, player_is_going_down
    ld (player_orientation), a

    ld a, (max_y)
    ld h, a
    ld a, (player_y)
    add b
    cp h
    jr c, maxy_ok
    ld a, h
    
maxy_ok    
    ld (player_y), a
    ret

decrease_lives
    ld a, (num_lives)
    and a
    jr nz, still_alive

    ld a, 1
    ld (game_over), a

    ret        

still_alive
    dec a
    ld (num_lives), a

    push hl
    push ix
    call show_lives
    pop ix
    pop hl

    ret

player_character
    defb 0

player_x
    defb 0

player_y
    defb 0

player_collision_x
    defb 0

player_collision_y
    defb 0

player_orientation
    defb 0

player_frame
    defb 0

num_lives
    defb 0

energy
    defb 0

keys_pressed
    defb 0

game_over
    defb 0

this_rooms_door_list
    defs max_doors * 8

this_rooms_door_count
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
    
save_screen_data_c0
    defs player_height * player_width

save_screen_data_80
    defs player_height * player_width    

anim_frames_table
    defw knight_frames_table
