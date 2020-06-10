read_keys
    ld hl, keyboard_state
    ld bc, 0xf782
    out (c), c
    ld bc, 0xf40e
    ld e, b
    out (c), c
    ld bc, 0xf6c0
    ld d, b
    out (c), c
    ld c, 0x00
    out (c), c
    ld bc, 0xf792
    out (c), c
    ld a, 0x40
    ld c, 0x4a

key_loop
    ld b, d
    out (c), a
    ld b, e
    ini
    inc a
    cp c
    jp c, key_loop
    ld bc, 0xf782
    out (c), c

    ret

poll_master_keys
    ld a, (keyboard_state + 4)          ; m for menu
    bit 6, a
    jr z, show_menu

    ld a, (keyboard_state + 6)			; g for game
    bit 4, a
    jr z, show_game

    ld a, (keyboard_state + 6)          ; v for timing bars
    bit 7, a
    jr z, toggle_sync_bars

	ld a, (keyboard_state + 5)			; n for next screen
	bit 6, a
	jr z, show_next_screen

	ld a, (keyboard_state + 6)
	bit 6, a
	jr z, show_previous_screen

    ret

toggle_sync_bars
    ld a, (show_vsync)
    xor 1
    ld (show_vsync), a
	ret

show_menu
    ld b, state_menu
    call switch_game_state
    ret

show_game
    ld b, state_game
    call switch_game_state
    ret

show_next_screen
	ld hl, room_number
	inc (hl)
	jr room_change

show_previous_screen
	ld a, (room_number)
	and a
	ret z

dec_room
	dec a
	ld (room_number), a

room_change
	ld a, 1
	ld (room_changed), a
	ret


keyboard_state
    defs 10