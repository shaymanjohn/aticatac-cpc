init_boss
    ld a, (room_number)

    cp room_frankenstein
    jp z, init_frank

    cp room_dracula
    jp z, init_dracula

    ld hl, mummy_room
    cp (hl)
    jp z, init_mummy

    cp room_hunchback
    jp z, init_hunchback

    cp room_devil
    jp z, init_devil

    ret

init_frank
    ld iy, boss_frankie
    ld ix, boss
    call init_sprite

    ld a, state_active
    ld (ix + spr_state), a

    ld a, 44
    ld (ix + spr_x), a

    ld a, 84
    ld (ix + spr_y), a

    ld hl, move_frankie
    ld (boss_mover), hl
    ret

init_dracula
    ld iy, boss_dracula
    ld ix, boss
    call init_sprite

    ld a, state_active
    ld (ix + spr_state), a

    ld a, 44
    ld (ix + spr_x), a

    ld a, 84
    ld (ix + spr_y), a

    ld hl, move_dracula
    ld (boss_mover), hl
    ret

init_mummy
    ld iy, boss_mummy
    ld ix, boss
    call init_sprite

    ld a, state_active
    ld (ix + spr_state), a

    ld a, 44
    ld (ix + spr_x), a

    ld a, 84
    ld (ix + spr_y), a

    ld hl, move_mummy
    ld (boss_mover), hl    
    ret

init_hunchback
    ld iy, boss_hunchback
    ld ix, boss    
    call init_sprite

    ld a, state_active
    ld (ix + spr_state), a

    ld a, 44
    ld (ix + spr_x), a

    ld a, 84
    ld (ix + spr_y), a

    ld hl, move_hunchback
    ld (boss_mover), hl    
    ret

init_devil
    ld iy, boss_devil
    ld ix, boss    
    call init_sprite

    ld a, state_active
    ld (ix + spr_state), a

    ld a, 44
    ld (ix + spr_x), a

    ld a, 84
    ld (ix + spr_y), a

    ld hl, move_devil
    ld (boss_mover), hl    
    ret

update_boss
    ld a, (heartbeat)
    and 0x01
    ret z

    ANIMATE_SPRITE    

    ld hl, (boss_mover)
    jp (hl)

boss_mover
    defw 0x00

move_frankie
    ret

move_dracula
    ret

move_mummy
    ret

move_hunchback
    ret

move_devil
    ld de, 0x0000           ; d = x motion, e = y motion

    ld a, (player_x)
    ld b, (ix + spr_x)
    cp b
    jp z, check_devil_y

    ld d, 1
    jp nc, check_devil_y
    ld d, -1
    
check_devil_y
    ld a, (player_y)
    ld b, (ix + spr_y)
    cp b
    jp z, move_devil_now

    ld e, 1
    jp nc, move_devil_now
    ld e, -1

move_devil_now
    ld a, (ix + spr_x)
    add d
    ld (ix + spr_x), a
    ld a, (ix + spr_y)
    add e
    ld (ix + spr_y), a

    ret