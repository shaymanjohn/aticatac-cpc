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

    ld (save_player_address), hl        ; save this for erase later

    ld b, 0
    ld a, (player_x)
    and 1
    jp z, dplay1
    ld b, num_player_frames

dplay1
    ld a, (player_frame)
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

    ld hl, (save_player_address)

draw_player_entry2                  ; hl as screen address, de as gfx    
    ld ixh, player_height
    ld bc, save_screen_data

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
    inc bc

    ex de, hl

    pop hl
    call scr_next_line

    dec ixh
    jp nz, dplay2

    ld a, 1
    ld (player_drawn), a
    ret

erase_player
    ld a, (player_drawn)
    and a
    ret z

    ld hl, (save_player_address)
    ld b, player_height
    ld de, save_screen_data

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
    inc de

    pop hl
    call scr_next_line
    djnz eplay2

    ret

check_doors
    ld a, (current_list_item)
    and a
    ret z

    ld ix, room_list
    ld a, (current_list_item)
    ld b, a

;   collision if:
;   player.x < door.x + door.width &&
;   player.x + player.width > door.x &&
;   player.y < door.y + door.height &&
;   player.y + player.height > door.y
;

cd1
    ld a, (ix + 0)
    cp 16
    jp nc, cd2              ; only basic doors for now...
    
    ld a, (ix + 1)          ; get door x + width
    add (ix + 5)
    ld d, a
    ld a, (player_x)
    cp d
    jp nc, cd2

    add player_width
    cp (ix + 1)
    jp c, cd2

    ld a, (ix + 2)
    add (ix + 6)
    ld d, a
    ld a, (player_y)
    cp d
    jp nc, cd2

    add player_height
    cp (ix + 2)
    jp c, cd2

    ld l, (ix + 3)
    ld h, (ix + 4)

    ld bc, -8
    ld a, (ix + 7)
    cp 8
    jp z, collide1
    ld bc, 8

collide1
    add hl, bc              ; hl points to item to move to 1 = room number, 3 = x, 4 = y, 5 = rotation

    inc hl
    ld a, (hl)
    ld (room_number), a
    ld a, 1
    ld (room_changed), a

    inc hl
    inc hl
    ld b, (hl)              ; x of new door
    srl b
    inc hl
    ld a, (ix + 6)
    ld c, a
    ld a, (hl)              ; y of new door (bottom y)
    sub c
    inc a                   
    ld c, a                 ; y of new door (top y)
    inc hl
    ld a, (hl)              ; rotation

; Use width and height from previous algo (ix + 5 and +6)    

    cp rotation_top
    jp z, por_coll_top
    cp rotation_bottom
    jp z, por_coll_bot
    cp rotation_left
    jp z, lan_coll_left

; b = door x, c = door y, ix+5 = width, ix+6 = height

lan_coll_right
    ld a, b
    sub 6
    ld (player_x), a

    ld a, c
    ld c, (ix + 5)
    srl c
    add c
    add 4
    ld (player_y), a
    ret    

lan_coll_left
    ld a, b
    add 12
    ld (player_x), a

    ld a, c
    ld c, (ix + 5)
    srl c
    add c
    add 4
    ld (player_y), a
    ret    

por_coll_bot
    ld a, c
    sub (ix + 6)
    sub 3
    ld (player_y), a

    ld a, b
    ld c, (ix + 5)
    srl c
    add c
    ld (player_x), a
    ret    

por_coll_top
    ld a, c
    add (ix + 6)
    ld (player_y), a

    ld a, b
    ld c, (ix + 5)
    srl c
    add c
    ld (player_x), a
    ret

cd2
    ld de, 8
    add ix, de
    dec b
    jp nz, cd1
    ret

move_player
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

    xor a
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

room_list
    defs max_items * 8

player_drawn
    defb 0

show_vsync
    defb 1

save_player_address
    defw 0
    
save_screen_data
    defs player_height * player_width

anim_frames_table
    defw knight_frames_table
