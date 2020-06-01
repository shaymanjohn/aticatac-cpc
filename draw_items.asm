draw_items
    call clear_room_list_data

    ld a, (room_number)    

    ld h, 0
    ld l, a
    add hl, hl
    ld de, room_bank_items_per_room
    add hl, de

    ld e, (hl)
    inc hl
    ld d, (hl)

    ex de, hl

draw_item_loop
    ld bc, room_bank_config     ; page room info in
    out (c), c

    ld e, (hl)                  ; hl = pointer in items_per_room
    inc hl
    ld d, (hl)
    inc hl

    ld a, d
    or e
    jr nz, continue_items       ; de = pointer in BackLocLists

    ld bc, item_bank_config     ; page default bank back in
    out (c), c 
    ret   

continue_items
    ld ixh, d
    ld ixl, e

    ld c, 0
    ld a, (room_number)
    xor (ix + 1)
    jr z, skip_dil

    ld bc, 8
    add ix, bc

skip_dil

    push hl
    call explode_item           ; c has offset in pair
    call draw_item              ; ix points to item in item_list

    pop hl

    jr draw_item_loop

draw_item                       ; ix + 0 = item, 3 = x, 4 = y, 5 = rotation
    ld l, (ix + 0)
    ld h, 0
    add hl, hl
    ld de, item_bank_items
    add hl, de

    ld b, (ix + 3)
    ld c, (ix + 4)              ; bc has x, y of item
    srl b
    srl b                       ; divide x by 4

    ld a, (ix + 5)              ; a has rotation value
    and 0xfe
    ld (rotation), a

    push bc
    ld bc, item_bank_config
    out (c), c
    pop bc

    ld e, (hl)
    inc hl
    ld d, (hl)    
    ld ixh, d
    ld ixl, e                   ; ix now points to specific item for drawing

    cp rotation_top
    jp z, portrait_item
    cp rotation_table
    jr z, portrait_item
    cp rotation_trapdoor
    jr z, portrait_item
    cp rotation_bottom
    jr z, portrait_item

landscape_item
    ld a, c
    ld c, (ix + 0)              ; subtract height of item from y pos
    sla c                       ; rotated, so calculate correct height
    sla c
    sub c                       
    inc a                       ; a is now top row

    ld l, a                     ; get start line screen address
    ld h, 0
    add hl, hl
    ld de, (scr_addr_table)
    add hl, de

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a

    ld c, b
    ld b, 0
    add hl, bc                  ; add x, now hl has screen address

    ld e, (ix + 6)
    ld d, (ix + 7)              ; de = gfx data

    ld a, (rotation)
    cp rotation_right
    jr z, li3
    cp rotation_right2
    jr z, li3

    push hl
    ld l, (ix + 2)
    ld h, (ix + 3)
    add hl, de
    dec hl
    ex de, hl
    pop hl

    ld c, (ix + 0)              ; height
    sla c
    sla c
li2
    ld b, (ix + 1)              ; width
    srl b
    srl b

    jp draw_item_flip

li3
    ld c, (ix + 0)              ; height
    sla c
    sla c

    ld b, (ix + 1)              ; width
    srl b
    srl b

    jp draw_item_noflip

portrait_item
    ld a, c                     ; x, y is bottom left of object so
    ld c, (ix + 1)              ; subtract height of item from y pos
    sub c                       
    inc a                       ; a is now top row

    ld l, a                     ; get start line screen address
    ld h, 0
    add hl, hl
    ld de, (scr_addr_table)
    add hl, de

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a

    ld c, b
    ld b, 0
    add hl, bc                  ; add x, now hl has correct screen address

    ld a, (rotation)
    cp rotation_bottom
    jr z, port_item

    ld e, (ix + 4)
    ld d, (ix + 5)              ; de = gfx data

    ld c, (ix + 1)              ; height
    ld b, (ix + 0)              ; width

    jp draw_item_noflip

port_item    
    ld b, h
    ld c, l
    ld l, (ix + 4)
    ld h, (ix + 5)             
    ld e, (ix + 2)
    ld d, (ix + 3)              ; start of portrait + size - 1
    add hl, de
    ex de, hl
    dec de                      ; de = end of portrait data
    ld h, b
    ld l, c

    ld c, (ix + 1)              ; height
    ld b, (ix + 0)              ; width

draw_item_flip
    push bc
    push hl
dif1
    ld a, (de)

flip_pixels           ; swap left and right pixels
    push bc

    ld c, a
    and %10101010
    ld b, a
    srl b
    ld a, c
    and %01010101
    sla a
    or b

    pop bc

    ld (hl), a
    inc hl
    dec de
    djnz dif1

    pop hl
    call scr_next_line
    pop bc
    dec c
    jp nz, draw_item_flip

    ret

draw_item_noflip
    push bc
    push hl
dinf1
    ld a, (de)
    ld (hl), a
    inc hl
    inc de
    djnz dinf1

    pop hl
    call scr_next_line
    pop bc
    dec c
    jp nz, draw_item_noflip

    ret

clear_room_list_data
    ld b, max_items * 8         ; clear door list for this room: x, y, w, h, dest
    ld hl, room_list
    xor a

clear_room_items
    ld (hl), a
    inc hl
    djnz clear_room_items

    ld hl, current_list_item
    ld (hl), a
    ret

; type, x, y, item pointer (to get paired), actual width, actual height, pair offset 
explode_item        ; IN: ix = item address
    ld a, c
    ld (item_offset), a           ; which of the item pair we've got

    ld a, (current_list_item)
    ld l, a
    ld h, 0
    add hl, hl
    add hl, hl
    add hl, hl
    ld de, room_list
    add hl, de

    ld a, (ix + 0)
    ld d, a
    ld (hl), a                      ; type (0)
    inc hl
    ld a, (ix + 3)
    srl a
    ld (hl), a                      ; x (1)
    inc hl
    ld a, (ix + 4)                  ; y (2)
    ld (hl), a
    inc hl
    ld a, ixl
    ld (hl), a
    inc hl
    ld a, ixh
    ld (hl), a                      ; item pointer (3 & 4)
    inc hl

    ld b, h
    ld c, l

; get item metadata for width / height
    ld l, d
    ld h, 0
    add hl, hl
    ld de, item_bank_items
    add hl, de

    ld a, (ix + 5)
    ld iyh, a

    push bc
    ld bc, item_bank_config
    out (c), c
    pop bc

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a                 ; hl now at item metadata

    ld a, iyh
    and 0xfe
    cp rotation_top
    jr z, expl_portrait
    cp rotation_bottom
    jr z, expl_portrait
    cp rotation_table
    jr z, expl_portrait
    cp rotation_trapdoor
    jr z, expl_portrait

; landscape rotation
    ld a, (hl)
    sla a
    sla a
    ld e, a

    inc hl
    ld a, (hl)
    srl a
    srl a
    ld d, a

    ld a, d
    ld (bc), a
    inc bc
    ld a, e
    ld (bc), a

    jr inc_list

expl_portrait
    ld a, (hl)
    ld (bc), a                  ; width
    inc hl
    inc bc
    ld a, (hl)
    ld (bc), a                  ; height
    ld e, a

inc_list
    inc bc
    ld a, (item_offset)
    ld (bc), a
    dec bc

    dec bc                      ; finally, subtract height from y pos
    dec bc
    dec bc
    dec bc
    ld a, (bc)
    sub e
    inc a
    ld (bc), a  

    ld hl, current_list_item
    inc (hl)

    ld bc, room_bank_config
    out (c), c

    ret

current_list_item
    defb 0x00
        
rotation
    defb 0x00

item_offset
    defb 0

