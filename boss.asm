init_boss
    ld a, (room_number)

    cp room_frankenstein
    jr z, init_frank

    ld hl, mummy_room
    cp (hl)
    jr z, init_mummy

    cp room_hunchback
    jp z, init_hunchback

    cp room_devil
    jp z, init_devil

    ld hl, dracula_room
    cp (hl)
    jr z, init_dracula

; Turn boss off if not in a boss room.
    xor a
    ld ix, boss
    ld (ix + spr_state), state_dead
    ld de, 0
    ld (ix + spr_scr80), de
    ld (ix + spr_scrc0), de

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
    jr common_boss_init

init_dracula
    ld hl, move_dracula
    ld (boss_mover), hl

    ld iy, boss_dracula
    jr common_boss_init

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

    ld a, (mummy_angry)
    and a
    ret nz

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
    jr z, dracula_avoid_player
    ld a, (pocket3)
    cp crucifix
    jr z, dracula_avoid_player

    jp normal_boss_move_towards

dracula_avoid_player
    ld de, 0x0000

    ld a, (player_x)
    cp (ix + spr_x)

    ld d, 1
    jr c, check_dracula_y
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

    ld a, (mummy_angry)
    and a
    jr nz, mummy_is_mad

    ; check if leaf is in the room...
    ld a, (room_number)
    ld b, a
    ld a, (col_leaf)            ; first byte of collectable is current room number
    cp b
    jr nz, mummy_is_bouncing

    ld a, 1
    ld (mummy_angry), a
    ret

mummy_is_bouncing
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
    jr nz, no_bounce_mummy

    ld a, b
    neg
    ld (mummy_inc), a
    xor a
    ld (mummy_count), a    

no_bounce_mummy
    ANIMATE_SPRITE
    ret

mummy_is_mad
    ld a, (room_number)
    ld b, a
    ld a, (col_leaf)            ; first byte of collectable is current room number
    cp b
    jp nz, move_devil_and_frank_and_mummy

    ld de, 0x0000

    ld a, (col_leaf + 3)
    sla a
    cp (ix + spr_x)
    jr z, check_leaf_y

    ld d, -1
    jr c, check_leaf_y
    ld d, 1
    
check_leaf_y
    ld a, (col_leaf + 4)
    cp (ix + spr_y)
    jr z, update_mummy_pos

    ld e, -1
    jr c, update_mummy_pos
    ld e, 1

update_mummy_pos
    ld a, (ix + spr_x)
    add d
    ld (ix + spr_x), a

    ld a, (ix + spr_y)
    add e
    ld (ix + spr_y), a

    ANIMATE_SPRITE

    ld a, d
    or e
    ret nz

    push ix

    ; remove leaf and move to another room
    SELECT_BANK room_bank_config
    ld ix, col_leaf

    call draw_this_collectable              ; and erase from both screens
    ld hl, (save_collectable_screen_loc)
    ld a, h
    xor 0x40
    ld h, a
    call draw_this_collectable2

    ld (ix + 0), 0x6b    

    SELECT_BANK baddie_bank_config
    pop ix
    ret

move_hunchback
    ld a, (boss_timer)
    inc a
    and 0x03
    ld (boss_timer), a
    ret nz

    ld iy, 0
    ld bc, 0x2c20               ; b = 44, c = 32
    ld a, (player_growing)
    and a
    jr nz, aim_for_target

    ; food on floor (8 possible items)
    ; aim for food, then collect it

    ld a, (room_number)
    ld c, a

    ld iy, col_money
    ld de, 8
    ld b, 10

check_hunch_items
    ld a, b
    cp 5                        ; ignore leaf
    jr z, skip_hunch_item
    cp 8                        ; ignore crucifix
    jr z, skip_hunch_item

    ld a, (iy + 0)
    cp c
    jr z, found_hunch_item_in_room

skip_hunch_item
    add iy, de
    djnz check_hunch_items
    ret

found_hunch_item_in_room
    ld b, (iy + 3)
    sla b
    ld c, (iy + 4)                          ; b is target x, c is target y

aim_for_target
    ld de, 0x0000
    ld a, b
    cp (ix + spr_x)
    jr z, check_hunch_y

    ld d, -1
    jr c, check_hunch_y
    ld d, 1
    
check_hunch_y
    ld a, c
    cp (ix + spr_y)
    jr z, update_hunchy

    ld e, -1
    jr c, update_hunchy
    ld e, 1

update_hunchy
    ld a, (ix + spr_x)
    add d
    ld (ix + spr_x), a
    ld b, a    

    ld a, (ix + spr_y)
    add e
    ld (ix + spr_y), a
    
    push iy
    ld iy, boss_hunchback
    ld (iy + 14), b
    ld (iy + 15), a
    pop iy

    ld a, d
    or e
    jr nz, animate_hunchy

    ld a, iyh
    or iyl
    ret z

    push ix
    push iy

    ; remove item 
    SELECT_BANK room_bank_config
    pop ix

    call draw_this_collectable              ; and erase from both screens
    ld hl, (save_collectable_screen_loc)
    ld a, h
    xor 0x40
    ld h, a
    call draw_this_collectable2
    ld (ix + 0), 0xfe

    SELECT_BANK baddie_bank_config
    pop ix
    ret

animate_hunchy
    ANIMATE_SPRITE
    ret

move_devil_and_frank
    ld a, (boss_timer)
    inc a
    and 0x03
    ld (boss_timer), a

    ret nz

move_devil_and_frank_and_mummy
    ld de, 0xff01
    ld a, (player_growing)              ; move boss to bottom left corner if player not active
    and a
    jr nz, update_boss_within_bounds

normal_boss_move_towards
    ld de, 0x0000

    ld a, (player_x)
    cp (ix + spr_x)
    jr z, check_devil_and_frank_y

    ld d, -1
    jr c, check_devil_and_frank_y
    ld d, 1
    
check_devil_and_frank_y
    ld a, (player_y)
    cp (ix + spr_y)
    jr z, update_boss_within_bounds

    ld e, -1
    jr c, update_boss_within_bounds
    ld e, 1

update_boss_within_bounds
    ld bc, (min_x)

    ld a, (ix + spr_x)
    add d

    cp c
    jr c, move_boss_y

    cp b
    jr nc, move_boss_y

    ld (ix + spr_x), a

move_boss_y
    ld bc, (min_y)

    ld a, (ix + spr_y)
    add e

    cp c
    jr c, do_boss_anim

    cp b
    jr nc, do_boss_anim

    ld (ix + spr_y), a

do_boss_anim
    ANIMATE_SPRITE
    ret

try_teleport_dracula
    RANDOM_IN_A
    and 0x7f
    ret z                   ; not room 0
    ld c, a
    call get_room_type
    cp 3
    ret z

    ld a, c
    ld (dracula_room), a
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
mummy_angry
    defb 0x00