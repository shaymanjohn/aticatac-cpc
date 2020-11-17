init_collectables
    SELECT_BANK item_bank_config
    
    ld a, 0xff                      ; empty the pockets
    ld (pocket1), a
    ld (pocket2), a
    ld (pocket3), a

    ld ix, col_key_yellow           ; move 'fixed' items back
init_coll1
    ld a, (ix + 0)
    cp 0xff
    jr z, do_random_collectables

    ld a, (ix + 5)
    ld (ix + 0), a                  ; reset room number
    ld a, (ix + 6)
    ld (ix + 3), a                  ; reset x
    ld a, (ix + 7)
    ld (ix + 4), a                  ; reset y

    ld de, 8
    add ix, de
    jr init_coll1

do_random_collectables
    ld a, r
    ld (random_seed), a

    RANDOM_IN_A
    and 0x07                        ; random 0 to 7

    ld l, a
    ld h, 0
    add hl, hl
    ld de, random_place_table
    add hl, de
    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a                         ; hl has address of random data
    ld ix, collectable_items
    
    ld b, 6                         ; 6 items are randomly placed (3 key parts, 3 keys)
    ld de, 8

random_place_loop
    ld a, (hl)
    ld (ix + 0), a
    inc hl
    ld a, (hl)
    ld (ix + 3), a
    inc hl
    ld a, (hl)
    ld (ix + 4), a
    inc hl
    add ix, de
    djnz random_place_loop

    ld a, (col_key_red)
    ld (mummy_room), a

    ld a, room_dracula
    ld (dracula_room), a
    
    ret

draw_collectables
    ld a, (room_number)
    ld c, a

    ld ix, collectable_items

collectable_loop
    ld a, (ix + 0)
    cp 0xff
    ret z

    cp c                            ; only draw if in this room
    call z, draw_this_collectable

    ld de, 8
    add ix, de
    jr collectable_loop

pickup_tapped
    ld e, sound_collect
    call play_sfx

    ld a, (room_number)
    ld c, a

    ld ix, collectable_items
    ld b, 0

pickup_loop
    ld a, (ix + 0)
    cp 0xff
    jr z, shuffle_pockets

    ld d, 0
    cp c                        ; can only pick things up that are in this room
    call z, collect_this_collectable
    
    ld a, d
    and a                       ; stop now if colllected something
    jr nz, shuffle_pockets

    inc b                       ; b holds collectable item index
    ld de, 8
    add ix, de
    jr pickup_loop

shuffle_pockets                 ; if nothing collected, a is 0xff, else b has collected item index
    ld c, a

    ld a, (pocket3)
    ld e, a
    ld a, (pocket2)
    ld (pocket3), a
    ld a, (pocket1)
    ld (pocket2), a
    ld a, 0xff
    ld (pocket1), a

    ld a, c
    cp 0xff
    jr z, pockets_done

    ld a, b
    ld (pocket1), a
    ld (ix + 0), 0xfe           ; take out of current room

    cp the_red_key
    jr nz, not_collected_red

    ld a, (mummy_room)
    ld c, a
    ld a, (room_number)
    cp c
    jr nz, not_in_mummy_room
    
    ld a, 1
    ld (mummy_angry), a    

not_in_mummy_room
    ld a, b

not_collected_red
    push de
    
    SELECT_BANK room_bank_config

    call draw_this_collectable              ; and erase from both screens
    ld hl, (save_collectable_screen_loc)
    ld a, h
    xor 0x40
    ld h, a
    call draw_this_collectable2
    pop de
    
pockets_done
    ld a, e                     ; drop an item?
    cp 0xff
    jr z, no_drop

    ; move item with this index into current room and draw it on both screens...
    ld l, a
    ld h, 0
    add hl, hl
    add hl, hl
    add hl, hl        ; x 8
    ld de, collectable_items
    add hl, de

    ex de, hl
    ld ixh, d
    ld ixl, e
    ex de, hl
    
    ld a, (room_number)
    ld (ix + 0), a
    ld a, (player_x)
    srl a
    ld (ix + 3), a

    ld a, (player_y)
    add 4
    ld (ix + 4), a

    SELECT_BANK room_bank_config

    call draw_this_collectable
    ld hl, (save_collectable_screen_loc)
    ld a, h
    xor 0x40
    ld h, a
    call draw_this_collectable2

no_drop
    ld a, 2
    ld (do_pockets), a

    call update_collision_grid_for_items
    ret

draw_pockets
    ld de, (scr_addr_table)
    ld hl, 0x0022          ; pocket item y
    add hl, hl
    add hl, de
    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a
    ld de, 0x0032           ; first pocket item x
    add hl, de

    SELECT_BANK room_bank_config

    push hl
    ld a, (pocket1)
    call draw_this_pocket
    pop hl
    inc l
    inc l
    inc l
    inc l
    push hl
    ld a, (pocket2)
    call draw_this_pocket
    pop hl
    inc l
    inc l
    inc l
    inc l
    ld a, (pocket3)

draw_this_pocket            ; hl = screen address, a = collectable item index
    cp 0xff
    jr z, draw_empty_pocket

draw_full_pocket
    push hl

    ld l, a
    ld h, 0
    add hl, hl
    add hl, hl
    add hl, hl              ; x8
    ld de, collectable_items
    add hl, de

    inc hl
    ld e, (hl)
    inc hl
    ld d, (hl)

    pop hl
    ld b, 16
dfpl1
    ld a, (de)
    ld (hl), a
    inc l
    inc de

    ld a, (de)    
    ld (hl), a
    inc l
    inc de

    ld a, (de)
    ld (hl), a    
    inc l
    inc de

    ld a, (de)
    ld (hl), a
    inc de

    dec l
    dec l
    dec l
    GET_NEXT_SCR_LINE
    djnz dfpl1

    ret

draw_empty_pocket
    ld b, 16
    ld e, 0x00
depl1
    ld (hl), e
    inc l
    ld (hl), e
    inc l
    ld (hl), e    
    inc l
    ld (hl), e    
    
    dec l
    dec l
    dec l
    GET_NEXT_SCR_LINE
    djnz depl1

    ret

draw_this_collectable
    ld de, (scr_addr_table)
    ld l, (ix + 4)
    ld h, 0
    add hl, hl
    add hl, de

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a

    ld e, (ix + 3)
    ld d, 0
    add hl, de

    ld (save_collectable_screen_loc), hl

draw_this_collectable2
    ld e, (ix + 1)
    ld d, (ix + 2)

    push bc

draw_this_collectable_entry2
    ld b, 16

collectable_draw_loop
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
    dec l
    dec l
    dec l

    GET_NEXT_SCR_LINE
    djnz collectable_draw_loop    

    pop bc
    ret

collect_this_collectable        ; compare centers and a tolerance
    ld a, (player_x)
    srl a
    add 2
    ld e, a
    ld a, (ix + 3)
    add 2
    sub e

    bit 7, a
    jr z, not_neg_x
    neg

not_neg_x
    cp 4
    ret nc

    ld a, (player_y)
    add average_player_height / 2    
    ld e, a
    ld a, (ix + 4)
    add 8
    sub e

    bit 7, a
    jr z, not_neg_y
    neg

not_neg_y
    cp 8
    ret nc

    ld d, 1
    ret

do_pockets
    defb 0x00

pocket1
    defb 0xff
pocket2
    defb 0xff
pocket3
    defb 0xff

mummy_room
    defb 0x00

dracula_room
    defb 0x00

save_collectable_screen_loc
    defw 0

