update_player
    call erase_player
    call check_keys    
    call draw_player

    call check_doors
    ret

check_doors
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

    ld (save_player_address), hl

    ld de, player_right_sprite

    ld a, (player_x)
    and 1
    jp nz, dplay1
    ld de, player_left_sprite

dplay1
    ld ixh, player_height
    ld bc, save_screen

dplay2
    push hl
    
    ld a, (hl)
    ld (bc), a
    ld a, (de)
    ld (hl), a
    inc hl
    inc de
    inc bc
    ld a, (hl)
    ld (bc), a
    ld a, (de)
    ld (hl), a
    inc hl
    inc de
    inc bc
    ld a, (hl)
    ld (bc), a
    ld a, (de)
    ld (hl), a
    inc hl
    inc de
    inc bc
    ld a, (hl)
    ld (bc), a
    ld a, (de)
    ld (hl), a
    inc de
    inc bc

    pop hl
    call scr_next_line

    dec ixh
    jp nz, dplay2

    ld a, 1
    ld (drawn), a
    ret

erase_player
    ld a, (drawn)
    and a
    ret z

    ld hl, (save_player_address)
    ld b, player_height
    ld de, save_screen

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

check_keys
    ld a, 8					    ; cursor left
    call km_test_key
    ld b, -player_horiz_speed
    call nz, player_hori

    ld a, 1					    ; cursor right
    call km_test_key
    ld b, player_horiz_speed
    call nz, player_hori

    xor a    
    call km_test_key
    ld b, -player_vert_speed
    call nz, player_vert

    ld a, 2
    call km_test_key
    ld b, player_vert_speed
    call nz, player_vert

    ld a, 44                    ; h key
    call km_test_key
    ret z

    xor a
    ld (room_number), a

    ld a, 0x2c
    ld (player_x), a

    ld a, 0x57
    ld (player_y), a    

    ret

player_hori
    ld a, (player_x)
    add b
    cp 88
    ret nc
    ld (player_x), a
    ret

player_vert
    ld a, (player_y)
    add b
    cp 174
    ret nc
    ld (player_y), a
    ret

player_x
    defb 0

player_y
    defb 0

room_list
    defs max_items * 8

drawn
    defb 0

save_player_address
    defw 0
    
save_screen
    defs player_height * 4
