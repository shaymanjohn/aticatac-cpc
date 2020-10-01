move_player
    ld a, (keys_pressed)
    ld c, a

    ld a, (screen_transition_in_progress)
    and a
    jp z, not_transitioning

    dec a
    ld (screen_transition_in_progress), a

    ld a, (transition_keypress)
    ld (keys_pressed), a
    ld c, a

not_transitioning
    ld a, (player_x)
    ld (updated_x), a    

    bit player_up_bit, c
    call nz, move_up

    bit player_down_bit, c
    call nz, move_down

    ld a, (player_y)
    ld (updated_y), a    

    bit player_left_bit, c
    call nz, move_left

    bit player_right_bit, c
    call nz, move_right

    bit player_fire1_bit, c
    call nz, fire_weapon

; Finally store what we're stood on top of at current position
    call check_collision_squares

    ld a, (screen_transition_in_progress)
    and a
    jp nz, inc_frame
    
    ld a, (keys_pressed)
    and 0x0f
    jp nz, inc_frame                    ; only animate if something pressed

    ld a, default_frame
    ld (player_frame), a
    ret

inc_frame
    ld a, (player_frame)
    inc a
    and 0x0f
    ld (player_frame), a
    ret

move_up
    ld a, player_is_going_up
    ld (player_orientation), a

    ld a, (player_y)
    add -player_vert_speed

    ld (updated_y), a

    call check_collision
    and a
    ret nz

    ld a, (updated_y)
    ld (player_y), a
    ret

move_down
    ld a, player_is_going_down
    ld (player_orientation), a

    ld a, (player_y)
    add player_vert_speed
    ld (updated_y), a

    call check_collision
    and a
    ret nz

    ld a, (updated_y)
    ld (player_y), a
    ret

move_left
    ld a, player_is_going_left
    ld (player_orientation), a

    ld a, (player_x)
    add -player_horiz_speed
    ld (updated_x), a

    call check_collision
    and a
    ret nz

    ld a, (updated_x)
    ld (player_x), a
    ret

move_right
    ld a, player_is_going_right
    ld (player_orientation), a

    ld a, (player_x)
    add player_horiz_speed
    ld (updated_x), a

    call check_collision
    and a
    ret nz

    ld a, (updated_x)
    ld (player_x), a
    ret

check_collision
    ld a, (updated_x)
    ld b, a
    ld a, (updated_y)
    call check_corner_collision

    ld a, b
    and a
    ret nz

    ld a, (updated_x)
    add 3
    ld b, a
    ld a, (updated_y)
    call check_corner_collision

    ld a, b
    and a
    ret nz

    ld a, (updated_x)
    add player_width + 2
    ld b, a
    ld a, (updated_y)
    call check_corner_collision

    ld a, b
    and a
    ret nz

    ld a, (updated_x)
    ld b, a
    ld a, (actual_player_height)
    sub 2
    ld e, a
    ld a, (updated_y)
    add e
    call check_corner_collision

    ld a, b
    and a
    ret nz

    ld a, (updated_x)
    add 3
    ld b, a
    ld a, (actual_player_height)
    sub 2
    ld e, a
    ld a, (updated_y)
    add e
    call check_corner_collision

    ld a, b
    and a
    ret nz    

    ld a, (updated_x)
    add player_width + 2
    ld b, a
    ld a, (actual_player_height)
    sub 2
    ld e, a
    ld a, (updated_y)
    add e
    call check_corner_collision

    ld a, b
    ret

check_collision_squares
    ld a, (player_x)
    ld b, a
    ld a, (player_y)
    call check_corner_collision
    ld (collision_info + 0), a

    ld a, (player_x)
    add player_width + 2
    ld b, a
    ld a, (player_y)
    call check_corner_collision
    ld (collision_info + 1), a

    ld a, (player_x)
    ld b, a
    ld a, (actual_player_height)
    sub 2
    ld e, a
    ld a, (player_y)
    add e
    call check_corner_collision
    ld (collision_info + 2), a    

    ld a, (player_x)
    add player_width + 2
    ld b, a
    ld a, (actual_player_height)
    sub 2
    ld e, a
    ld a, (player_y)
    add e
    call check_corner_collision
    ld (collision_info + 3), a
    ret

check_corner_collision      ; IN: a = y, b = x
    srl a
    srl a
    srl a
    ld l, a
    ld h, 0
    add hl, hl
    ld de, collision_rows
    add hl, de

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a    

    ld e, b
    srl e
    srl e
    ld d, 0
    add hl, de

    ld b, 0
    ld a, (hl)
    cp 0xff
    ret nz

    ld b, 1
    ret

collision_info
    defs 4