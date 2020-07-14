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

    ld bc, 0x0030               ; col 
    add hl, bc

    push hl                     ; hl is screen address, save it

; clear all lives first
    ld b, max_player_height

clear_lives_loop
    push bc
    push hl    

    ld d, h
    ld e, l
    inc de
    ; ld (hl), 0
    ld bc, (player_width + 1) * 3
    ; ldir
    pop hl
    GET_NEXT_SCR_LINE
    pop bc
    djnz clear_lives_loop

    pop hl

; now draw how many are left...    

    ld a, (num_lives)
    and a
    ret z               ; stop here if 0.

    ld b, a
    inc hl
    inc hl
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

chicken_item    
;        item                x     y    rot
    defb 0x13, 0x00, 0x00, 0xca, 0x78, 0x00

carcass_item
    defb 0x14, 0x00, 0x00, 0xe8, 0x70, 0x00

panel_item
    defb 0x04, 0x00, 0x00, 0xc2, 192, 0x00      ; y is bottom row of item...
 