init_food
    SELECT_BANK sprite_bank_config

    ld ix, food_items
    ld b, (food_items_end - food_items) / 8
    ld de, 8

food_init_loop
    ld (ix + 2), 0
    add ix, de
    djnz food_init_loop
    ret

check_food_collision
    ld c, a
    SELECT_BANK sprite_bank_config

    ld b, c
    ld hl, this_rooms_food_list
    ld iyh, 0

check_next_food_item_collision
    ld a, (hl)
    ld ixl, a
    inc hl
    ld a, (hl)
    ld ixh, a

    ld a, (ix + 2)
    and a
    call z, check_food

    ld a, iyh               ; exit early if collected food
    and a
    ret nz

    inc hl
    djnz check_next_food_item_collision
    ret

check_food
    push hl
    push bc

    ld a, (player_x)
    srl a
    add 2
    ld e, a
    ld a, (ix + 3)
    add 1
    sub e

    bit 7, a
    jp z, food_not_neg_x
    neg

food_not_neg_x
    cp 4
    jp nc, cant_find_food

    ld a, (player_y)
    add average_player_height / 2    
    ld e, a
    ld a, (ix + 4)
    ld c, (ix + 7)
    srl c
    sub c
    sub e

    bit 7, a
    jp z, food_not_neg_y
    neg

food_not_neg_y
    cp 12
    jp nc, cant_find_food

    ld a, (ix + 0)
    cp type_mushroom
    jp nz, remove_food

    ; decrease health only, don't remove mushrooms...
    jp cant_find_food

remove_food
    call draw_food_item2

    SELECT_BANK sprite_bank_config
    ld a, 1
    ld (ix + 2), a
    ld (erase_food_with_index), ix

    ld e, sound_collect
    call play_sfx

    call health_up

    ld iyh, 1

cant_find_food
    pop bc
    pop hl
    ret

reset_food_collected
    ld hl, 0
    ld (erase_food_with_index), hl
    ret

draw_food
    xor a
    ld (this_rooms_food_count), a

    call create_food_list

    SELECT_BANK room_bank_config

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

draw_food_item              ; hl pointer in food_items
    SELECT_BANK sprite_bank_config

    ld a, (hl)
    ld ixl, a
    inc hl
    ld a, (hl)
    ld ixh, a

draw_food_item2
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

    ld c, (ix + 3)
    ld b, 0
    add hl, bc                  ; add x, now hl has screen address
    ex de, hl

    ld a, (ix + 0)
    sub 0x50
    add a
    ld l, a
    ld h, 0
    ld bc, food_table
    add hl, bc
    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a                             ; hl has food gfx

    ex de, hl

    ld c, (ix + 7)
    SELECT_BANK room_bank_config
    ld b, c

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
    SELECT_BANK sprite_bank_config

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

erase_food_with_index
    defw 0x00