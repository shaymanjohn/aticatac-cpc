draw_panel
    call draw_empty_panel
    call add_chicken

; switch to sprite bank
	ld bc, sprite_bank
	out (c), c	    

    call show_lives

; switch back to tile bank
	ld bc, item_bank
	out (c), c	        
    ret

draw_empty_panel
    ld hl, 0x1900                   ; x, y of panel
    ld bc, 0x0e18                   ; width, height of panel
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

add_chicken
    ld ix, chicken_item
    call draw_item

    ret

show_lives
    ld hl, 0x00e8               ; row 0xf0
    ld de, (scr_addr_table)
    add hl, de

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a

    ld bc, 0x0039               ; col 0x39
    add hl, bc

    push hl                     ; hl is screen address, save it

; clear all lives first
    ld b, player_height

clear_lives_loop
    push bc
    push hl    

    ld d, h
    ld e, l
    inc de
    ld (hl), 0
    ld bc, (player_width + 1) * 3
    ldir
    pop hl
    call scr_next_line
    pop bc
    djnz clear_lives_loop

    pop hl

; now draw how many are left...    

    ld a, (num_lives)
    and a
    ret z               ; stop here if 0.

    ld b, a

lives_loop
    push hl
    push bc
    ld de, player_kl_1_0
    ld bc, save_screen_data_c0
    call draw_player_entry2
    pop bc
    pop hl
    ld de, player_width + 1
    add hl, de
    djnz lives_loop
    ret

chicken_item
    defb 0x13, 0x00, 0x00, 0xe8, 0x70, 0x00

carcass_item
    defb 0x14, 0x00, 0x00, 0xe8, 0x70, 0x00

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
    jr nz, pc1

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

panel_drawn
    defb 0