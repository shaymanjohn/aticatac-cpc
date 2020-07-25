init_food
    ld ix, food_items
    ld b, (food_items_end - food_items) / 8
    ld de, 8

food_init_loop
    ld (ix + 2), 0
    add ix, de
    djnz food_init_loop
    ret

draw_food
    xor a
    ld (this_rooms_food_count), a
    call create_food_list

    ld a, (this_rooms_food_count)
    and a
    ret z

    ld hl, this_rooms_food_list    
    ld b, a

draw_food_loop
    push hl
    push bc
    call draw_food_item
    pop bc
    pop hl

    inc hl
    inc hl
    djnz draw_food_loop
    ret

draw_food_item              ; ix pointer in food_items
    ld a, (hl)
    ld ixl, a
    inc hl
    ld a, (hl)
    ld ixh, a
    ld a, (ix + 0)
    sub 0x50
    add a
    ld l, a
    ld h, 0
    ld de, food_table
    add hl, de
    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a                             ; hl has food gfx
    push hl

    ld b, (ix + 3)
    srl b
    srl b

    ld a, (ix + 4)
    ld c, (ix + 7)
    sub c
    ld l, a
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
    pop de

    ld b, (ix + 7)
draw_food_item_loop
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

    djnz draw_food_item_loop
    ret

create_food_list
    ld a, (room_number)
    ld c, a
    ld ix, food_items
    ld b, (food_items_end - food_items) / 8

list_food_loop
    push bc

    ld a, (ix + 1)
    cp c
    jp nz, skip_food_item

    ld a, (ix + 2)
    and a
    jp nz, skip_food_item

    ; add to food list here
    ld a, (this_rooms_food_count)
    add a
    ld l, a
    ld h, 0
    ld bc, this_rooms_food_list
    add hl, bc

    ld a, ixl
    ld (hl), a
    inc hl
    ld a, ixh
    ld (hl), a

    ld hl, this_rooms_food_count
    inc (hl)

skip_food_item
    pop bc

    ld de, 8
    add ix, de
    djnz list_food_loop
    ret

food_table
    defw item_can, item_candycane
    defw item_ham, item_lolly
    defw item_icecream, item_bowl
    defw item_apple, item_milk
    defw item_mushroom