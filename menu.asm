init_menu
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

    call set_pens

    ld a, player_is_going_left
    ld (player_orientation), a

    ld a, 1
    ld (characters_moving), a    

    ret

update_menu
    ld a, (characters_moving)
    and a
    jr z, check_keys

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

    ld ix, knight_text
    cp character_mid
    jr z, character_named
    ld ix, serf_text
    cp character_left
    jr z, character_named
    ld ix, wizard_text

character_named
    call show_text    

    xor a
    ld (characters_moving), a

    ld a, 5
    ld (player_frame), a

    ld a, knight_height
    ld (actual_player_height), a    ; TODO: change this per character...    

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

    call draw_player_select

	ld a, (player_select_x)
	add character_gap
	ld (player_select_x), a
	call draw_player_select

	ld a, (player_select_x)
	add character_gap
	ld (player_select_x), a
	call draw_player_select

	pop af
	ld (player_select_x), a

    ret

characters_moving
    defb 0x00

characters_target
    defb 0x00

text_for_menu
    defw play_game_text
    defw cursors_text
    defw menu_text
    defw interrupts_text
    defw next_screen_text
    defw previous_screen_text
text_for_menu_end

