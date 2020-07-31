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

common_boss_init
    ld ix, boss

    ld a, state_active
    ld (ix + spr_state), a

    ld a, (iy + 14)
    ld (ix + spr_x), a

    ld a, (iy + 15)
    ld (ix + spr_y), a

    jp init_sprite

init_frank
    ld hl, move_frankie
    ld (boss_mover), hl

    ld iy, boss_frankie
    jp common_boss_init

init_dracula
    ld hl, move_dracula
    ld (boss_mover), hl

    ld iy, boss_dracula
    jp common_boss_init

init_mummy
    ld hl, move_mummy
    ld (boss_mover), hl

    ld iy, boss_mummy
    call common_boss_init

    ld a, 1
    ld (mummy_inc), a

    ld a, mummy_count_max / 2
    ld (mummy_count), a
    ret

init_hunchback
    ld hl, move_hunchback
    ld (boss_mover), hl

    ld iy, boss_hunchback
    jp common_boss_init

init_devil
    ld hl, move_devil
    ld (boss_mover), hl

    ld iy, boss_devil
    jp common_boss_init

update_boss
    ld hl, (boss_mover)
    jp (hl)

boss_mover
    defw 0x00

move_frankie
    ANIMATE_SPRITE
    ret

move_dracula
    ANIMATE_SPRITE
    ret

move_mummy
    ld a, (heartbeat)
    bit 0, a
    ret z

    ld a, (mummy_inc)
    ld b, a

    ld a, (ix + spr_x)
    add b
    ld (ix + spr_x), a

    ld a, (ix + spr_y)
    add b
    ld (ix + spr_y), a

    ld a, (mummy_count)
    inc a
    ld (mummy_count), a

    cp mummy_count_max
    jp nz, no_bounce_mummy

    ld a, b
    neg
    ld (mummy_inc), a
    xor a
    ld (mummy_count), a    

no_bounce_mummy
    ANIMATE_SPRITE
    ret

move_hunchback
    ret

move_devil
    ld a, (heartbeat)
    bit 0, a
    ret z

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

    ANIMATE_SPRITE
    ret

mummy_inc
    defb 0x00
mummy_count
    defb 0x00