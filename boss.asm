init_boss
    ld a, (room_number)

    cp room_frankenstein
    jp z, init_frank

    ld hl, mummy_room
    cp (hl)
    jp z, init_mummy

    cp room_hunchback
    jp z, init_hunchback

    cp room_devil
    jp z, init_devil

    ld hl, dracula_room
    cp (hl)
    jp z, init_dracula    

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
    ld a, (frank_dead)
    and a
    ret nz

    ld hl, move_devil
    ld (boss_mover), hl

    ld iy, boss_frankie
    jp common_boss_init

init_dracula
    ld hl, move_dracula
    ld (boss_mover), hl

    ld iy, boss_dracula
    jp common_boss_init

teleport_dracula
    RANDOM_IN_A
    and 0x7f
    ld c, a
    call get_room_type
    cp 3
    ret z

    ld a, c
    ld (dracula_room), a
    ret

get_room_type
    ld l, a
    ld h, 0
    ld de, room_bank_RoomInfo
    add hl, de
    inc hl
    ld a, (hl)
    ret

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

    xor a
    ld (devil_timer), a

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
    ld a, (devil_timer)
    inc a
    ld (devil_timer), a
    cp 3
    ret nz

    xor a
    ld (devil_timer), a

    ld de, 0x0000                   ; d = x motion, e = y motion

    ld a, (player_x)
    ld b, (ix + spr_x)
    cp b
    jp z, check_devil_y

    ld d, -1
    jp c, check_devil_y
    ld d, 1
    
check_devil_y
    ld a, (player_y)
    ld b, (ix + spr_y)
    cp b
    jp z, move_devil_now

    ld e, -1
    jp c, move_devil_now
    ld e, 1

move_devil_now
    ld a, (player_growing)
    and a
    jp z, update_boss_within_bounds

    ld a, d
    neg 
    ld d, a
    ld a, e
    neg
    ld e, a
    jp update_boss_within_bounds

update_boss_within_bounds
    ld a, (player_growing)
    and a
    jp z, ubwb1

    ld de, 0xff01               ; move to corner if player growing

ubwb1
    ld a, (min_x)
    ld b, a
    ld a, (max_x)
    ld c, a

    ld a, (ix + spr_x)
    add d

    cp b
    jp c, move_boss_y

    cp c
    jp nc, move_boss_y

    ld (ix + spr_x), a

move_boss_y
    ld a, (min_y)
    ld b, a
    ld a, (max_y)
    ld c, a

    ld a, (ix + spr_y)
    add e

    cp b
    jp c, do_boss_anim

    cp c
    jp nc, do_boss_anim

    ld (ix + spr_y), a

do_boss_anim
    ANIMATE_SPRITE
    ret

frank_dead
    defb 0x00
devil_timer
    defb 0x00
mummy_inc
    defb 0x00
mummy_count
    defb 0x00