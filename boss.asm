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

    ld hl, move_devil_and_frank
    ld (boss_mover), hl

    ld iy, boss_frankie
    jp common_boss_init

init_dracula
    ld hl, move_dracula
    ld (boss_mover), hl

    ld iy, boss_dracula
    jp common_boss_init

try_teleport_dracula
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
    ld hl, move_devil_and_frank
    ld (boss_mover), hl

    xor a
    ld (boss_timer), a

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
    ld a, (dracula_timer)
    inc a
    ld (dracula_timer), a    
    cp 2
    ret nz

    xor a
    ld (dracula_timer), a

    ld de, 0xff01
    ld a, (player_growing)              ; move boss to bottom left corner if player not active
    and a
    jp nz, update_boss_within_bounds
    
    ld a, crucifix

    ld hl, (pocket1)
    cp h
    jp z, dracula_avoid_player
    cp l
    jp z, dracula_avoid_player
    ld a, (pocket3)
    cp crucifix
    jp z, dracula_avoid_player

    jp normal_boss_move_towards

dracula_avoid_player
    ld de, 0x0000

    ld a, (player_x)
    cp (ix + spr_x)

    ld d, 1
    jp c, check_dracula_y
    ld d, -1
    
check_dracula_y
    ld a, (player_y)
    cp (ix + spr_y)

    ld e, 1
    jp c, update_boss_within_bounds
    ld e, -1
    jp update_boss_within_bounds

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

move_devil_and_frank
    ld a, (boss_timer)
    inc a
    and 0x03
    ld (boss_timer), a

    ret nz

    ld de, 0xff01
    ld a, (player_growing)              ; move boss to bottom left corner if player not active
    and a
    jp nz, update_boss_within_bounds

normal_boss_move_towards
    ld de, 0x0000

    ld a, (player_x)
    cp (ix + spr_x)
    jp z, check_devil_and_frank_y

    ld d, -1
    jp c, check_devil_and_frank_y
    ld d, 1
    
check_devil_and_frank_y
    ld a, (player_y)
    cp (ix + spr_y)
    jp z, update_boss_within_bounds

    ld e, -1
    jp c, update_boss_within_bounds
    ld e, 1

update_boss_within_bounds
    ld bc, (min_x)

    ld a, (ix + spr_x)
    add d

    cp c
    jp c, move_boss_y

    cp b
    jp nc, move_boss_y

    ld (ix + spr_x), a

move_boss_y
    ld bc, (min_y)

    ld a, (ix + spr_y)
    add e

    cp c
    jp c, do_boss_anim

    cp b
    jp nc, do_boss_anim

    ld (ix + spr_y), a

do_boss_anim
    ANIMATE_SPRITE
    ret

frank_dead
    defb 0x00
boss_timer
    defb 0x00
dracula_timer
    defb 0x00
mummy_inc
    defb 0x00
mummy_count
    defb 0x00