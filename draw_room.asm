draw_room
    ; ld a, (hidden_screen_base_address)
    ; sra a
    ; ld (scr_offset_value + 1), a

    ld a, room_bank_config
    call set_memory_bank

    call draw_outline
    call draw_items

    ld a, room_bank_config
    call set_memory_bank
    
    call draw_collectables
    ; call draw_transients

    ld a, item_bank_config
    call set_memory_bank

    call calc_dimensions

; Copy room to other screen 
    ld a, (hidden_screen_base_address)
    ld h, a
    ld l, 0
    
    ld ixh, num_rows
    ld ixl, 48

copy_loop    
    push hl
    ld a, h
    xor 0x40
    ld d, a
    ld e, l
    ld b, 0
    ld c, ixl
    ldir
    pop hl
    call scr_next_line
    dec ixh
    jr nz, copy_loop

    xor a
    ld (room_changed), a

    ld hl, 0
    ld (save_player_address_c0), hl
    ld (save_player_address_80), hl

    ld (sprite1 + 8), hl
    ld (sprite1 + 10), hl
    ld (sprite2 + 8), hl
    ld (sprite2 + 10), hl
    ld (sprite3 + 8), hl
    ld (sprite3 + 10), hl
    ld (boss + 8), hl
    ld (boss + 10), hl

    ret

draw_outline
    ld a, (room_number)

    ld bc, room_bank_RoomInfo
    ld l, a
    ld h, 0
    add hl, hl
    add hl, bc
    ld d, (hl)            ; room colour

    push hl

    cp skeleton_room1
    jr z, skeleton_room
    cp skeleton_room2
    jr z, skeleton_room
    cp skeleton_room3
    jr z, skeleton_room
    cp skeleton_room4
    jr nz, not_skeleton_room

skeleton_room
    ld d, 0    

not_skeleton_room
    ld a, d
    and 0x03
    ld c, a
    ld b, 0
    ld hl, room_colour_palette
    add hl, bc
    ld a, (hl)
    ld (line_pen_number + 1), a

    pop hl

    inc hl
    ld a, (hl)            ; a has room type

    ld bc, room_bank_RoomTypes
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
    ld (room_size), hl         ; save it

    ; ret

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
    ld (line_pen_number + 1), a
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
    ld a, (hidden_screen_base_address)

clear_room2    
    ld h, a
    ld l, 0
    ld b, num_rows

clear1
    push bc
    push hl
    ld bc, 0x2f
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

calc_dimensions
    ld hl, (room_size)
    srl h

    ld a, 0x30
    sub h
    sub 4
    ld (min_x), a
    ld a, 0x30
    add h
    sub 3
    ld (max_x), a

    ld a, 0x60
    sub l
    sub 10
    ld (min_y), a
    ld a, 0x60
    add l
    sub 10    
    ld (max_y), a
    ret

point_address
    defw 0

room_size
    defw 0
min_x
    defb 0
max_x
    defb 0
min_y
    defb 0
max_y
    defb 0

room_number
    defb 0

room_changed
    defb 0

next_room_number
    defb 0

room_colour_palette
    defb 0x0c   ; 0x02
    defb 0xfc   ; 0x07
    defb 0x3f   ; 0x0e
    defb 0xcc   ; 0x03
