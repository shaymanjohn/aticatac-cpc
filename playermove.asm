move_player
    ld a, (screen_transition_in_progress)
    and a
    jp nz, update_transition_time

    ld a, (keys_pressed)
    ld c, a
    ld de, 0

    bit player_up_bit, c
    call nz, move_up

    bit player_down_bit, c
    call nz, move_down

    bit player_left_bit, c
    call nz, move_left

    bit player_right_bit, c
    call nz, move_right

    bit player_fire1_bit, c
    call nz, fire_weapon

    ld a, d
    or e
    jp nz, inc_frame                    ; only animate if something pressed

    ld a, default_frame
    ld (player_frame), a
    ret

update_transition_time
    dec a
    ld (screen_transition_in_progress), a
    ret

move_up
    ld e, 1

    ld a, player_is_going_up
    ld (player_orientation), a

    ld a, (player_x)
    ld (updated_x), a

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
    ld a, e
    xor 1
    ld e, a

    ld a, player_is_going_down
    ld (player_orientation), a

    ld a, (player_x)
    ld (updated_x), a

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
    ld d, 1

    ld a, player_is_going_left
    ld (player_orientation), a

    ld a, (player_x)
    add -player_horiz_speed
    ld (updated_x), a

    ld a, (player_y)
    ld (updated_y), a

    call check_collision
    and a
    ret nz

    ld a, (updated_x)
    ld (player_x), a
    ret

move_right
    ld a, d
    xor 1
    ld d, a

    ld a, player_is_going_right
    ld (player_orientation), a

    ld a, (player_x)
    add player_horiz_speed
    ld (updated_x), a

    ld a, (player_y)
    ld (updated_y), a

    call check_collision
    and a
    ret nz

    ld a, (updated_x)
    ld (player_x), a
    ret

inc_frame
    ld a, (player_frame)
    inc a
    and 0x0f
    ld (player_frame), a
    ret

check_collision
    push de
    ld iyh, c

    xor a
    ld (collision_state), a

    ld a, (updated_x)
    ld b, a
    ld a, (updated_y)
    call check_corner_collision
    ld (collision_info + 0), a

    ld a, (updated_x)
    add player_width + 2
    ld b, a
    ld a, (updated_y)
    call check_corner_collision
    ld (collision_info + 1), a

    ld a, (updated_x)
    ld b, a
    ld a, (actual_player_height)
    sub 2
    ld c, a
    ld a, (updated_y)
    add c
    call check_corner_collision
    ld (collision_info + 2), a    

    ld a, (updated_x)
    add player_width + 2
    ld b, a
    ld a, (actual_player_height)
    sub 2
    ld c, a
    ld a, (updated_y)
    add c
    call check_corner_collision
    ld (collision_info + 3), a

    ld a, (collision_state)
    ld c, iyh    
    pop de
    ret

check_corner_collision
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

    ld a, (hl)
    cp item_table
    jp z, solid_block

    cp 0xff
    ret nz

solid_block
    ld b, a
    ld a, 1
    ld (collision_state), a
    ld a, b
    ret

collision_state
    defb 0x00

collision_info
    defs 4