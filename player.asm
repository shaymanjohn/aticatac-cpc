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
    call scr_next_line

    djnz dplay2

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

move_player
    ld a, (screen_transition_in_progress)
    and a
    jp z, can_move

    dec a
    ld (screen_transition_in_progress), a
    ret

can_move    
    ld a, (keys_pressed)
    ld c, a
    ld de, 0

    bit player_up_bit, c
    call nz, move_player_up

    bit player_down_bit, c
    call nz, move_player_down

    bit player_left_bit, c
    call nz, move_player_left

    bit player_right_bit, c
    call nz, move_player_right

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
    ld a, d
    xor 1
    ld d, a

    ld a, player_is_going_left
    ld (player_orientation), a
    ld a, (min_x)
    ld h, a    
    ld a, (player_x)
    add -player_horiz_speed
    cp h
    jr nc, minx_ok
    ld a, h

minx_ok    
    ld (player_x), a
    ret    

move_player_right
    ld a, d
    xor 1
    ld d, a
    
    ld a, player_is_going_right
    ld (player_orientation), a

    ld a, (max_x)
    ld h, a
    ld a, (player_x)
    add player_horiz_speed
    cp h
    jr c, maxx_ok
    ld a, h

maxx_ok    
    ld (player_x), a
    ret

move_player_up
    ld a, e
    xor 1
    ld e, a    

    ld a, player_is_going_up
    ld (player_orientation), a

    ld a, (min_y)
    ld h, a
    ld a, (player_y)
    add -player_vert_speed
    cp h
    jr nc, miny_ok
    ld a, h

miny_ok    
    ld (player_y), a
    ret

move_player_down
    ld a, e
    xor 1
    ld e, a

    ld a, player_is_going_down
    ld (player_orientation), a

    ld a, (max_y)
    ld h, a
    ld a, (player_y)
    add player_vert_speed
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
    srl a
    ld c, a
    ld b, 0
    add hl, bc

    ld b, max_player_height           ; hl as screen address, de as gfx
    ld e, 0

dplay_erase_fast_2
    push hl
    
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

    pop hl
    call scr_next_line

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
    srl a
    ld c, a
    ld b, 0
    add hl, bc

    push hl

    ld b, 0
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
    call scr_next_line

    djnz dplay_fast_2

    ret    

player_character
    defb 0

player_x
    defb 0

player_y
    defb 0

actual_player_height
    defb serf_height

player_select_x
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

save_player_frame_c0
    defw 0

save_player_frame_80    
    defw 0    

anim_frames_table
    defw serf_frames_table
