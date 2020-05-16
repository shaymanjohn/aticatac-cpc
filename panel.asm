draw_panel
    ld hl, 0x1800                   ; x, y of panel
    ld bc, 0x1018                   ; width, height of panel
    ld ix, panel_text

dp2    
    push bc
    push hl
    call get_char_scr_address

dp1
    ld a, (ix + 0)
    call print_char
    inc hl
    inc hl
    inc ix
    djnz dp1

    pop hl
    pop bc

    inc l    
    dec c
    jr nz, dp2

    ret

print_char                  ; IN: a = char to print
    push bc
    push hl

    call get_tile_addr

    ld bc, 0x800 - 1
    ld a, 8
pc1 
    push af
    ld a, (de)
    ld (hl), a
    inc hl
    inc de
    ld a, (de)
    ld (hl), a
    inc de
    add hl, bc
    pop af
    dec a
    jp nz, pc1

    pop hl
    pop bc
    ret

get_tile_addr               ; IN: a = tile number, OUT: de = tile data
    push hl
    ld l, a
    ld h, 0
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld de, panel_gfx
    add hl, de
    ex de, hl
    pop hl
    ret

get_char_scr_address
    push bc

    ld a, h
    ld h, 0
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld de, (scr_addr_table)
    add hl, de
    ld c, (hl)
    inc hl
    ld b, (hl)
    ld l, a
    ld h, 0
    add hl, hl
    add hl, bc

    pop bc
    ret    

