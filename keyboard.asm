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
    jr c, key_loop
    ld bc, 0xf782
    out (c), c

; Store up / down / left / right / fire state in 1 byte
    xor a
    ld (keys_pressed), a
    ld b, a

; Start with joystick
    ld a, (keyboard_state + joystick_port_1)
    bit 2, a
    jr nz, check_right_joystick
    set player_left_bit, b

check_right_joystick
    bit 3, a
    jr nz, check_up_joystick
    set player_right_bit, b

check_up_joystick
    bit 0, a
    jr nz, check_down_joystick
    set player_up_bit, b

check_down_joystick
    bit 1, a
    jr nz, check_fire1_joystick
    set player_down_bit, b

check_fire1_joystick
    bit 4, a
    jr nz, check_fire2_joystick
    set player_fire1_bit, b

check_fire2_joystick
    bit 5, a
    jr nz, check_player_keys
    set player_fire2_bit, b

check_player_keys
    ld a, (keyboard_state)

    bit 0, a
    jr nz, check_down_keyboard
    set player_up_bit, b

check_down_keyboard
    bit 2, a
    jr nz, check_right_keyboard
    set player_down_bit, b

check_right_keyboard
    bit 1, a
    jr nz, check_left_keyboard
    set player_right_bit, b

check_left_keyboard
    ld a, (keyboard_state + 1)
    bit 0, a
    jr nz, check_fire_keyboard
    set player_left_bit, b    

check_fire_keyboard
    ld a, (keyboard_state + 5)
    bit 7, a
    jr nz, check_fire2_keyboard
    set player_fire1_bit, b

check_fire2_keyboard
    ld a, (keyboard_state + 6)
    bit 4, a
    jr nz, save_input_state
    set player_fire2_bit, b    

save_input_state
    ld a, (keys_fire2)
    ld c, a

    ld a, b
    ld (keys_pressed), a

    and 0x0f
    jr z, handle_fire
    ld (fire_direction), a               ; save last actual keys pressed, for direction of fire

handle_fire
    ld a, b
    and 1 << player_fire2_bit       ; current fire2
    ld (keys_fire2), a
    ret z

    cp c
    ret nz

    ld a, b
    res player_fire2_bit, a
    ld (keys_pressed), a
	ret

keyboard_state
    defs 10
keys_pressed
    defb 0x00   
fire_direction
    defb 0x00
keys_fire2
    defb 0x00
