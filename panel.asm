draw_panel
    ld ix, panel_item
    call draw_item

    ld ix, chicken_item
    call draw_item

	ld bc, sprite_bank_config
	out (c), c	    

    call show_lives

	ld bc, item_bank_config
	out (c), c	        
    ret

show_lives
    ld hl, 0x00fa               ; row 0xf0
    ld de, (scr_addr_table)
    add hl, de

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a

    ld bc, 0x0035               ; col 0x39
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
    ; ld (hl), 0
    ld bc, (player_width + 1) * 3
    ; ldir
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
    inc hl
    inc hl
lives_loop
    push hl
    push bc
    ld de, sprite_bank_player_kl_1_1
    ld bc, save_screen_data_c0
    call draw_player_entry2
    pop bc
    pop hl
    ld de, player_width
    add hl, de
    djnz lives_loop
    ret

chicken_item    
;        item                x     y    rot
    defb 0x13, 0x00, 0x00, 0xde, 0x7b, 0x00

carcass_item
    defb 0x14, 0x00, 0x00, 0xe8, 0x70, 0x00

panel_item
    defb 0x04, 0x00, 0x00, 0xd4, 192, 0x00      ; y is bottom row of item...
 
panel_drawn
    defb 0