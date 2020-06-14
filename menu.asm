init_menu
    ld hl, font_data_mode1
    ld (font_type), hl
    ld b, (text_for_menu_end - text_for_menu) / 2
    ld hl, text_for_menu

menu_text_loop
    push hl
    push bc

    ld c, (hl)
    inc hl
    ld b, (hl)

    ld ixh, b
    ld ixl, c
    call show_text

    pop bc
    pop hl

    inc hl
    inc hl
    djnz menu_text_loop

    ld hl, font_data_mode0
    ld (font_type), hl
    ld ix, select_marker
    call show_text

    ld bc, room_bank_config     ; page room info in
    out (c), c

    ld hl, (scr_addr_table)

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a

    ld bc, 14
    add hl, bc
    push hl
    call draw_logo
    pop hl
    ld a, h
    xor 0x40
    ld h, a
    call draw_logo

    ld bc, item_bank_config     ; page room info in
    out (c), c    

    call set_pens

    ld a, player_is_going_left
    ld (player_orientation), a

    ld a, 1
    ld (characters_moving), a       ; say they're moving, so 1st frame will set name

    ld a, 0x7a
    ld (player_select_y), a

    ret

draw_logo       ; hl = screen address
    ld b, 57
    ld de, logo_mode1

logo_loop
    push bc
    push hl

    ex de, hl
    ld bc, 52
    ldir

    ex de, hl
    pop hl
    call scr_next_line
    pop bc
    djnz logo_loop

    ret

update_menu
    ld a, (characters_moving)
    and a
    jp z, check_keys

    ld a, (characters_target)
    ld b, a
    ld a, (player_select_x)
    ld e, -1
    cp b
    jr nc, character_moving_right

    ld e, 1

character_moving_right
    add e
    ld (player_select_x), a
    ld c, a

	ld a, (player_frame)
	inc a
	and 0x0f
	ld (player_frame), a

    ld a, c
    cp b
    ret nz

    ld c, 0
    ld a, b
    cp character_mid
    jr z, character_selected

    ld c, 2
    cp character_left
    jr z, character_selected

    ld c, 1

character_selected
    xor a
    ld (characters_moving), a

    ld a, 5
    ld (player_frame), a

    ld a, c
    cp 0
    jr z, selected_knight
    cp 1
    jr z, selected_wizard

    ld hl, sprite_bank_player_sl_1_1
    ld (selected_sprite_frame), hl    

    ld hl, serf_frames_table
    ld a, serf_height
    ld b, character_serf
    jr save_selection

selected_knight
    ld hl, sprite_bank_player_kl_1_1
    ld (selected_sprite_frame), hl

    ld hl, knight_frames_table
    ld a, knight_height
    ld b, character_knight
    jr save_selection

selected_wizard
    ld hl, sprite_bank_player_wl_1_1
    ld (selected_sprite_frame), hl    

    ld hl, wizard_frames_table
    ld a, wizard_height
    ld b, character_wizard

save_selection
    ld (selected_player), hl
    ld (selected_player_height), a
    ld a, b
    ld (player_character), a
    ret

check_keys    
    ld a, (keyboard_state + 1)
    bit 0, a
    jr nz, menu_keyboard_right

    ld a, (player_select_x)
    cp character_left
    ret z

    cp character_mid
    jr z, check_left_right
    ld a, character_mid
    jr point_left    

check_left_right
    ld a, character_left
    
point_left    
    ld (characters_target), a
    ld a, player_is_going_left
    ld (player_orientation), a

    ld a, 1
    ld (characters_moving), a 
    ret

menu_keyboard_right
	ld a, (keyboard_state)
    bit 1, a
    ret nz

    ld a, (player_select_x)
    cp character_right
    ret z

    cp character_mid
    jr z, check_right_left
    ld a, character_mid
    jr point_right

check_right_left
    ld a, character_right
    
point_right
    ld (characters_target), a
    ld a, player_is_going_right
    ld (player_orientation), a

    ld a, 1
    ld (characters_moving), a 
    ret

clear_character_selects
	ld a, (player_select_x)
	push af

    call erase_player_select

	ld a, (player_select_x)
	add character_gap
	ld (player_select_x), a
	call erase_player_select

	ld a, (player_select_x)
	add character_gap
	ld (player_select_x), a
	call erase_player_select

	pop af
	ld (player_select_x), a
    ret

update_character_selects    
	ld a, (player_select_x)
	push af

    ld hl, wizard_frames_table
    ld (anim_frames_table), hl

    ld a, wizard_height
    ld (actual_player_height), a

    call draw_player_select

	ld a, (player_select_x)
	add character_gap
	ld (player_select_x), a

    ld hl, knight_frames_table    
    ld (anim_frames_table), hl

    ld a, knight_height    
    ld (actual_player_height), a    
	call draw_player_select

	ld a, (player_select_x)
	add character_gap
	ld (player_select_x), a

    ld hl, serf_frames_table
    ld (anim_frames_table), hl    

    ld a, serf_height
    ld (actual_player_height), a        
	call draw_player_select

	pop af
	ld (player_select_x), a

    ret

characters_moving
    defb 0x00

characters_target
    defb 0x00

selected_player
    defw 0

selected_player_height
    defb 0

selected_sprite_frame
    defw 0

text_for_menu
    defw copyright_text
    defw play_game_text
    defw select_player_text
    defw job_titles
    defw dev_names
text_for_menu_end

