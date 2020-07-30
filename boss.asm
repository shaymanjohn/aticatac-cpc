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
    ret