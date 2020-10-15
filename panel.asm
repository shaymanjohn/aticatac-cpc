draw_panel
    ld ix, panel_item
    call draw_item

    ld ix, chicken_item
    call draw_item

    SELECT_BANK sprite_bank_config
    call show_lives

    SELECT_BANK item_bank_config
    ret

show_lives
    ld hl, 246
    ld de, (scr_addr_table)
    add hl, de

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a

    ld bc, 0x0032               ; col 
    add hl, bc

    ld b, 3
lives_loop
    push hl
    push bc
    ld de, (selected_sprite_frame)
    call draw_player_entry2
    pop bc
    pop hl
    ld de, player_width - 1
    add hl, de
    djnz lives_loop

    ret

remove_life
    ld hl, 246
    ld de, (scr_addr_table)
    add hl, de

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a

    ex de, hl

    ld a, (num_lives)
    ld l, a
    ld h, 0
    add hl, hl
    ld bc, life_table
    add hl, bc

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a
    add hl, de

    ld a, (actual_player_height)
    ld b, a

clear_life_loop
    push hl

    push hl
    ld (hl), 0
    inc hl
    ld (hl), 0
    inc hl
    ld (hl), 0
    inc hl
    ld (hl), 0

    pop hl
    ld a, h
    xor 0x40
    ld h, a

    ld (hl), 0
    inc hl
    ld (hl), 0
    inc hl
    ld (hl), 0
    inc hl
    ld (hl), 0

    pop hl
    GET_NEXT_SCR_LINE
    djnz clear_life_loop

    ret

life_table
    defw 50, 54, 58

chicken_item    
;        item                x     y    rot
    defb 0x13, 0x00, 0x00, 0xca, 0x78, 0x00

carcass_item
    defb 0x14, 0x00, 0x00, 0xe8, 0x70, 0x00

panel_item
    defb 0x04, 0x00, 0x00, 0xc2, 192, 0x00      ; y is bottom row of item...
 