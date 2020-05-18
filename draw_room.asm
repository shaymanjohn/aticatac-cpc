draw_room
    ld a, %11111100     ; pen 7 / 7
    ld (line_pen_number), a
    
    call draw_outline

    ld a, %11111100
    ld a, 0xff    
    ld (line_pen_number), a

    call draw_items

    xor a
    ld (player_drawn), a
    ld (room_changed), a

    ret

draw_outline
    ld a, (room_number)

    ld bc, RoomInfo
    ld l, a
    ld h, 0
    add hl, hl
    add hl, bc
    ld d, (hl)            ; d has room colour

    ld a, 0x07
    call set_ink          ; pen 7 is the room colour

    inc hl
    ld a, (hl)            ; a has room type

    ld bc, RoomTypes
    ld l, a
    ld h, 0
    add hl, hl
    ld d, h
    ld e, l
    add hl, hl
    add hl, de
    add hl, bc            ; hl now points to room info

    ld d, (hl)
    inc hl                
    ld e, (hl)
    inc hl                ; de now has width / height
    ex de, hl
    ld (offset), hl         ; save it
    ex de, hl

    ld e, (hl)
    inc hl
    ld d, (hl)             ; de is vertex data
    inc hl
    ld c, (hl)
    inc hl
    ld b, (hl)             ; bc is line info

    ex de, hl              ; hl is now vertex data
    ld (point_address), hl

    dec bc
    ld ixh, b
    ld ixl, c               ; ix now points to index list - 1

draw1
    inc ix
    ld a, (ix + 0)
    cp 0xff
    ret z

    cp 0xfe                 ; change pen 
    jr nz, draw3

    ld a, (ix + 1)
    ld (line_pen_number), a
    inc ix
    jr draw1

draw3
    ; convert a into a point address stored in bc
    call get_point

draw2
    inc ix
    ld a, (ix + 0)
    cp 0xff
    jr z, draw1

    ; convert a into a point stored in de
    push bc
    call get_point
    ld d, b
    ld e, c
    pop bc

    push bc
    call plot_line
    pop bc
    jr draw2

get_point           ; IN: A = coord number, out: bc = coord
    ld hl, (point_address)
    add a
    ld c, a
    ld b, 0
    add hl, bc
    ld b, (hl)
    inc hl
    ld c, (hl)
    ret

clear_room
    ld hl, &c000
    ld b, num_rows

clear1
    push bc
    push hl
    ld bc, &2f
    ld (hl), 0
    ld d, h
    ld e, l
    inc de
    ldir
    pop hl
    call scr_next_line
    pop bc
    djnz clear1

    ret    

point_address
    defw 0

offset
    defw 0

room_number
    defb 0

room_changed
    defb 0
