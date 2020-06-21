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

    ret

pickup_tapped
    ld a, (room_number)
    ld c, a

    ld ix, collectable_items
    ld b, 0

pickup_loop
    ld a, (ix + 0)
    cp 0xff
    jr z, shuffle_pockets

    ld d, 0
    cp c                        ; can only pick things up in this room
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

    push de
    ld bc, room_bank_config
    out (c), c

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
    add hl, hl        
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

    ld bc, room_bank_config
    out (c), c

    call draw_this_collectable
    ld hl, (save_collectable_screen_loc)
    ld a, h
    xor 0x40
    ld h, a
    call draw_this_collectable2

no_drop    
    call draw_pockets
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
    ld de, 0x0037           ; first pocket item x
    add hl, de

    push hl                 ; save screen address for later copy

    ld bc, room_bank_config
    out (c), c    

    push hl
    ld a, (pocket1)
    call draw_this_pocket
    pop hl
    ld bc, 4
    add hl, bc
    push hl
    ld a, (pocket2)
    call draw_this_pocket
    pop hl
    ld bc, 4
    add hl, bc
    ld a, (pocket3)
    call draw_this_pocket

    ld bc, item_bank_config
    out (c), c    

    pop hl

    ld a, 16            ; finally copy pocket to other screen
copy_pocket_loop    
    push af
    push hl

    ld a, h
    xor 0x40
    ld d, a
    ld e, l
    ld bc, 12
    ldir

    pop hl
    call scr_next_line
    pop af    
    dec a
    jr nz, copy_pocket_loop

    ret

draw_this_pocket            ; hl = screen address, a = collectable item index
    cp 0xff
    jr nz, draw_full_pocket

    call draw_empty_pocket
    ret

draw_full_pocket
    push hl

    ld l, a
    ld h, 0
    add hl, hl
    add hl, hl
    add hl, hl        
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

    dec hl
    dec hl
    dec hl
    call scr_next_line
    djnz dfpl1

    ret

draw_empty_pocket
    ld b, 16
    ld e, 0x00
depl1
    push hl    
    ld (hl), e
    inc hl
    ld (hl), e
    inc hl
    ld (hl), e    
    inc hl
    ld (hl), e    
    pop hl
    call scr_next_line
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
    push hl

    ld a, (de)
    xor (hl)
    ld (hl), a
    inc hl
    inc de

    ld a, (de)
    xor (hl)
    ld (hl), a
    inc hl
    inc de

    ld a, (de)
    xor (hl)
    ld (hl), a
    inc hl
    inc de

    ld a, (de)
    xor (hl)
    ld (hl), a
    inc de

    pop hl
    call scr_next_line
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
    jr nc, cant_collect

    ld a, (player_y)
    ld e, a
    add average_player_height / 2
    ld a, (ix + 4)
    add 8
    sub e

    bit 7, a
    jr z, not_neg_y
    neg

not_neg_y
    cp 16
    jr nc, cant_collect

    ld d, 1

cant_collect
    ret    


collectable_items
; room - 0xfe if in a pocket
; item_gfx address
; x, y
; 3 bytes fill

col_acgkey1
    defb 0x00
    defw item_acgkey1
    defb 0x10, 0x30
    defb 0x00, 0x00, 0x00

col_acgkey2
    defb 0x00
    defw item_acgkey2
    defb 0x15, 0x30
    defb 0x00, 0x00, 0x00

col_acgkey3
    defb 0x00
    defw item_acgkey3
    defb 0x1a, 0x30
    defb 0x00, 0x00, 0x00

col_key_blue
    defb 0x07
    defw key_blue
    defb 0x10, 0x60
    defb 0x00, 0x00, 0x00

col_key_green
    defb 0x00
    defw key_green
    defb 0x18, 0x62
    defb 0x00, 0x00, 0x00

col_key_red
    defb 0x00
    defw key_red
    defb 0x0a, 0x76
    defb 0x00, 0x00, 0x00

col_key_yellow
    defb 0x00
    defw key_yellow
    defb 0x18, 0x70
    defb 0x00, 0x00, 0x00

end_colls
    defb 0xff

pocket1
    defb 0xff
pocket2
    defb 0xff
pocket3
    defb 0xff

save_collectable_screen_loc
    defw 0

