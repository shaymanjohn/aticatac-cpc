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

check_doors
    ld a, (screen_transition_in_progress)
    and a
    ret nz

    ld a, (this_rooms_item_count)
    and a
    ret z

    ld ix, this_rooms_item_list
    ld b, a

;   collision if:
;   player.x < door.x + door.width &&
;   player.x + player.width > door.x &&
;   player.y < door.y + door.height &&
;   player.y + player.height > door.y
;

collision_loop
    ld a, (ix + 0)
    cp 16
    jp nc, no_collision     ; only basic doors for now...
    
    ld a, (ix + 1)          ; get door x + width * 2
    add (ix + 5)
    add (ix + 5)
    sub 4                   ; tolerance
    ld d, a
    ld a, (player_x)
    cp d
    jp nc, no_collision

    add player_width
    sub 2                   ; tolerance
    cp (ix + 1)
    jp c, no_collision

    ld a, (ix + 2)          ; now height
    add (ix + 6)
    sub 8
    ld d, a
    ld a, (player_y)
    cp d
    jp nc, no_collision

    add player_height
    sub 8                   ; tolerance
    cp (ix + 2)
    jp nc, do_collision

no_collision
    ld de, 8
    add ix, de              ; go to next item
    djnz collision_loop

    ret    

do_collision
    ld l, (ix + 3)
    ld h, (ix + 4)          ; hl is pointer to item in room_bank_item_list

    ld bc, -8               ; We want this items twin now to work out new position of player
    ld a, (ix + 7)
    and a
    jp nz, collide1
    ld bc, 8

collide1
    add hl, bc              ; hl now points to item to move to 1 = room number, 3 = x, 4 = y, 5 = rotation, etc

    call get_new_door_dimensions

    inc hl
    ld a, (hl)              ; move to room this item is in
    ld (room_number), a
    ld a, 1
    ld (room_changed), a

    ld a, 1
    ld (screen_transition_in_progress), a

    inc hl
    inc hl
    ld b, (hl)              ; x of new door
    srl b                   ; divide by 2
    inc hl
    ld a, (this_item_height)
    ld c, a
    ld a, (hl)              ; y of new door (bottom y)
    sub c
    inc a                   
    ld c, a                 ; y of new door (top y)
    inc hl
    ld a, (hl)              ; rotation of new door

; b has new door x, c has new door y, a has new door rotation, hl pointer to new door
    cp rotation_top
    jp z, portrait_coll_top
    cp rotation_bottom
    jp z, portrait_coll_bot
    cp rotation_left
    jp z, landscape_coll_left

landscape_coll_right
    ld a, b
    sub player_width
    dec a
    ld (player_x), a

    ld a, c
    ld (player_y), a
    ret    

landscape_coll_left
    ld a, (this_item_width)
    add b
    add b
    ld (player_x), a

    ld a, c
    ld (player_y), a
    ret    

portrait_coll_bot
    ld a, c
    sub player_height
    dec a
    add 8
    ld (player_y), a

    ld a, (this_item_width)
    add b
    sub player_width
    ld (player_x), a
    ret    

portrait_coll_top
    ld a, (this_item_height)
    add c
    sub 8    
    ld (player_y), a

    ld a, (this_item_width)
    add b
    sub player_width
    ld (player_x), a
    ret

get_new_door_dimensions             ; hl is pointer to item in room_bank_item_list
    push hl
    push bc
    
    ld a, (hl)      ; item type
    ld l, a
    ld h, 0
    add hl, hl
    ld de, item_bank_items
    add hl, de

	ld bc, item_bank_config
	out (c), c

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a         ; hl now has our item

    ld a, (hl)
    ld (this_item_width), a
    inc hl
    ld a, (hl)
    ld (this_item_height), a

	ld bc, room_bank_config
	out (c), c        

    pop bc
    pop hl
    ret

move_player
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
    call z, player_vert

    bit 2, c
    ld b, player_vert_speed
    call z, player_vert    

    ld a, (keyboard_state + 1)
    bit 0, a
    ld b, -player_horiz_speed
    call z, player_hori

    bit 1, c
    ld b, player_horiz_speed
    call z, player_hori

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

player_hori
    ld a, d
    xor 1
    ld d, a
    bit 7, b
    jp z, ph2
    ld a, player_is_going_left
    ld (player_orientation), a
    ld a, (min_x)
    ld h, a    
    ld a, (player_x)
    add b
    cp h
    ret c
    ld (player_x), a
    ret
ph2
    ld a, player_is_going_right
    ld (player_orientation), a

    ld a, (max_x)
    ld h, a
    ld a, (player_x)
    add b
    cp h
    ret nc
    ld (player_x), a
    ret    

player_vert
    ld a, e
    xor 1
    ld e, a
    ld a, player_is_going_down
    bit 7, b
    jp z, pv2
    ld a, player_is_going_up
pv2    
    ld (player_orientation), a

    ld a, (player_y)
    add b
    cp 174
    ret nc
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

player_x
    defb 0

player_y
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

this_rooms_item_list
    defs max_items * 8

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
