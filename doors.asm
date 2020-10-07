init_doors
;
;   ix + 2
;   bit 7           0 = open, 1 = closed or locked
;   bit 6           0 = keyed door, 1 = automatic door
;   bit 5, 4, 3     open / close time (0 = 3, 1 = 4, 2 = 5, 3 = 6)
;   bit 2, 1, 0     current time

    SELECT_BANK room_bank_config

    ld bc, (end_room_bank_item_list - room_bank_item_list) / 16 ; (8 bytes per item, but they're in pairs so do both together)
    ld ix, room_bank_item_list
    ld de, 16
    ld iyl, 0

    ld a, r
    ld (random_seed), a    

    ld hl, magic_door    

init_door_loop
    push bc

    ld a, (ix + 7)              ; is this actually a door?
    and a
    jr z, init_next_door

    set 7, (ix + 2)
    set 7, (ix + 10)            ; lock or close the door and its twin to begin with

    ld c, (ix + 0)              ; item type
    ld a, c

    cp active_door_trapdoor
    jr z, automatic_door        ; trapdoors are always automatic

    cp active_door_big + 1      ; catches items 1 and 2 and 3
    jr c, not_a_locked_door

    cp (hl)
    jr z, ignore_different_doors

    res 6, (ix + 2)
    res 6, (ix + 10)
    jr init_next_door

not_a_locked_door
    cp (ix + 8)
    jr nz, ignore_different_doors

    RANDOM_IN_A
    cp 179                                 ; randomly select roughly 70% of the automatic doors to work 
    jr c, automatic_door

ignore_different_doors
    res 7, (ix + 2)
    res 7, (ix + 10)
    res 6, (ix + 2)
    res 6, (ix + 10)
    jr init_next_door

automatic_door
    set 6, (ix + 2)
    set 6, (ix + 10)

    RANDOM_IN_A
    and 0x07
    sla a
    sla a
    sla a

    or iyl

    or (ix + 2)
    ld (ix + 2), a
    ld (ix + 10), a

    inc iyl
    ld a, iyl
    and 0x07
    ld iyl, a

init_next_door
    add ix, de

    pop bc
    dec bc
    ld a, b
    or c
    jp nz, init_door_loop

    ret

check_doors
    ld hl, (collision_info)          ; are all corners of player are touching same door?
    ld a, l
    and a
    ret z

    cp h
    ret nz

    ld hl, (collision_info + 2)

    cp l
    ret nz
    cp h
    ret nz

    dec a                           ; If so, a has the door index in this_rooms_door_list we're fully stood on
    ld ixl, a
    ld ixh, 0
    add ix, ix
    add ix, ix
    add ix, ix
    ld de, this_rooms_door_list
    add ix, de                      ; ix now pointing to correct door

    ld a, (ix + 0)
    cp active_door_trapdoor
    jp z, trapdoor_collision        ; special case for trapdoor - if open, go into falling state if open

    ld a, (keys_pressed)            ; Even though we're on a door, only exit if pressing into door...
    and 0x0f
    ret z

    ld c, a

    ld e, (ix + 3)                  ; get orientation of door
    ld d, (ix + 4)
    ld hl, 5
    add hl, de

    SELECT_BANK room_bank_config

    ld a, (hl)
    and 0xc0                        ; mask off the rotation bits

    or c                            ; merge in the key press

    cp 0x42                         ; rotation right + left pressed
    jp z, do_collision

    cp 0xc1                         ; rotation left + right pressed
    jp z, do_collision

    cp 0x88                         ; rotation bottom + up pressed
    jp z, do_collision

    cp 0x04
    jp z, do_collision              ; rotation top + down pressed

    ret

trapdoor_collision
    ld e, (ix + 3)
    ld d, (ix + 4)
    inc de
    inc de

    SELECT_BANK room_bank_config
    ld a, (de)

    bit 7, a
    ret nz

    ld l, (ix + 3)
    ld h, (ix + 4)

    ld bc, -8               ; We want this items twin now to work out new position of player
    ld a, (ix + 7)
    and a
    jp nz, trapdoor_coll_1
    ld bc, 8

trapdoor_coll_1    
    add hl, bc              ; hl now points to item to move to 1 = room number, 3 = x, 4 = y, 5 = rotation, etc
    inc hl

    ld a, (hl)              ; move to room this item is in
    ld (room_number), a
    
    ld b, state_falling
    call switch_game_state
    ret

do_collision
    ld a, c
    ld (transition_keypress), a

    ld l, (ix + 3)
    ld h, (ix + 4)          ; hl is pointer to item in room_bank_item_list

    inc hl
    inc hl
    res 7, (hl)             ; set door to unlocked - safe to do this for all door types

    ld bc, -8               ; We want this items twin now to work out new position of player
    ld a, (ix + 7)
    and a
    jp nz, collide1
    ld bc, 8

collide1
    add hl, bc              ; hl now points to item to move to 1 = room number, 3 = x, 4 = y, 5 = rotation, etc
    res 7, (hl)             ; also set twin door to unlocked...
    dec hl
    dec hl

    call get_new_door_dimensions

    ld a, (room_number)
    ld (last_room_number), a

    inc hl
    ld a, (hl)              ; move to room this item is in
    ld (room_number), a
    
    ld a, 1
    ld (room_changed), a

    ld a, transition_time
    ld (screen_transition_in_progress), a

    inc hl
    inc hl
    ld b, (hl)              ; x of new door
    srl b                   ; divide by 2
    inc hl
    ld c, (hl)              ; y of new door (bottom y)
    inc hl

    ld a, (hl)              ; rotation of new door
    and 0xfe                ; ignore smallest bit

    ld hl, collision_info   ; clear collision info
    ld (hl), 0
    ld hl, collision_info + 2
    ld (hl), 0

; b has new door x, c has new door bottom y, a has new door rotation, hl pointer to new door
    cp rotation_top
    jp z, portrait_coll_top
    cp rotation_bottom
    jp z, portrait_coll_bot
    cp rotation_left    
    jp z, landscape_coll_left

landscape_coll_right
    ld a, b
    sub player_width - 1
    add 2
    ld (player_x), a

    ld a, (this_item_width)
    sla a
    ld b, a
    ld a, c
    sub b
    sub average_player_height / 2
    ld (player_y), a
    ret    

landscape_coll_left
    ld a, (this_item_height)
    srl a
    srl a
    add b
    ld (player_x), a

    ld a, (this_item_width)
    sla a
    ld b, a
    ld a, c
    sub b
    sub average_player_height / 2
    ld (player_y), a
    ret    

portrait_coll_bot
    ld a, (this_item_height)
    ld d, a
    ld a, c
    sub d
    sub average_player_height
    add 12
    ld (player_y), a

    ld a, (this_item_width)
    add b
    sub player_width
    inc a
    ld (player_x), a
    ret    

portrait_coll_top
    ld a, c
    sub 12
    ld (player_y), a

    ld a, (this_item_width)
    add b   
    sub player_width
    inc a
    ld (player_x), a
    ret

get_new_door_dimensions             ; hl is pointer to item in room_bank_item_list
    push hl
    push bc
    
    ld a, (hl)      ; item type
    ld l, a
    ld h, 0
    add hl, hl
    ld de, item_bank_items
    add hl, de

    SELECT_BANK item_bank_config

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a         ; hl now has our item

    ld a, (hl)
    ld (this_item_width), a
    inc hl
    ld a, (hl)
    ld (this_item_height), a

    SELECT_BANK room_bank_config

    pop bc
    pop hl
    ret

;
;   ix + 2
;
;   bit 7           0 = open, 1 = closed or locked
;   bit 6           0 = keyed door, 1 = automatic door
;   bit 5, 4, 3     open / close time (0 = 3, 1 = 4, 2 = 5, 3 = 6)
;   bit 2, 1, 0     current time    
    
update_doors
    ld a, (player_x)                    ; Don't do anything if player is stood in a doorway...
    ld b, a
    ld a, (min_x)
    inc b
    cp b
    ret nc
    ld a, (max_x)
    dec b
    cp b
    ret c

    ld a, (player_y)
    ld b, a
    ld a, (min_y)
    cp b
    ret nc
    ld a, (max_y)
    cp b
    ret c

    ld a, (this_rooms_door_count)
    ld b, a
    ld ix, this_rooms_door_list         ; list of items in 'exploded' format

update_doors_loop
    ld l, (ix + 3)
    ld h, (ix + 4)              ; get real item pointer
    inc hl
    inc hl                      ; increment by 2 to get to door control byte (eg. ix + 2)

    ld a, (hl)
    bit 6, a                   ; is door an automatic door?
    jp z, do_next_door

    ld e, a
    ld c, a

    inc a
    and 0x07

    ld d, a
    ld a, c
    and %00111000
    srl a
    srl a
    srl a
    cp d
    jp nz, door_not_hit_counter

    ld a, e
    and %11111000               ; keep the original values, set count to 0
    xor %10000000               ; and toggle the open/close status
    ld (hl), a

    ; and do this doors twin...

    ld c, a
    ld de, 8
    ld a, (ix + 7)              ; offset of item pair
    cp 8
    jp nz, set_twin
    ld de, -8

set_twin
    add hl, de
    ld (hl), c

    ld a, c

    call update_collision_grid_for_door

    ld e, (ix + 3)
    ld d, (ix + 4)

    ld ixh, d
    ld ixl, e

    ld a, (ix + 0)                  ; special case for trapdoor - have to xor the grill image
    cp active_door_trapdoor
    jp z, xor_the_trapdoor_grill

    ld (door_to_toggle), de    
    jp draw_item

door_not_hit_counter
    ld a, e
    and %11111000
    or d
    ld (hl), a

do_next_door
    ld de, 8
    add ix, de
    djnz update_doors_loop
    ret

xor_the_trapdoor_grill
    ld a, (ix + 4)
    sub 22
    ld h, 0
    ld l, a
    add hl, hl
    ld de, (scr_addr_table)
    add hl, de

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a

    ld a, (ix + 3)
    srl a
    srl a
    add 2
    ld e, a
    ld d, 0
    add hl, de

    SELECT_BANK item_bank_config

    push hl
    call do_the_grill

    pop hl
    ld a, h
    xor 0x40
    ld h, a

do_the_grill
    ld de, trapdoor_grill
    ld b, 14

xor_grill_loop
    ld a, (de)
    xor (hl)
    ld (hl), a
    inc l
    inc de

    ld a, (de)
    xor (hl)
    ld (hl), a
    inc l
    inc de

    ld a, (de)
    xor (hl)
    ld (hl), a
    inc l
    inc de

    ld a, (de)
    xor (hl)
    ld (hl), a
    inc de    

    dec l
    dec l
    dec l
    GET_NEXT_SCR_LINE
    djnz xor_grill_loop
    ret

update_collision_grid_for_items
    ld a, (this_rooms_door_count)
    ld b, a
    ld ix, this_rooms_door_list

next_door_loop                      ; we only need to consider if there are any doors that could be locked...
    push bc
    
    ld a, (ix + 0)
    cp door_acg
    jr z, check_acg_open

    ld e, (ix + 3)
    ld d, (ix + 4)
    inc de
    inc de
    ex de, hl                       ; get status of door

    bit 6, (hl)
    jr nz, next_door_loop2           ; ignore automatic doors

    bit 7, (hl)                     ; ignore if already open
    jr z, next_door_loop2

    ; Only need to consider door numbers 8 to 15 (door number in a).
    cp 16
    jr nc, next_door_loop2

    cp 7
    jr c, next_door_loop2

    ; got a locked door in the right range...
    ; ignore bit 2, so can do only 4 check_keys
    res 2, a

    ld c, 3
    cp door_blue
    jr z, found_door_locked

    ld c, 4
    cp door_green
    jr z, found_door_locked

    ld c, 5
    cp door_red
    jr z, found_door_locked

    ld c, 6
    cp door_yellow
    jr z, found_door_locked

next_door_loop2
    pop bc
    ld de, 8
    add ix, de
    djnz next_door_loop

    ret

check_acg_open
    set 7, e

    ld hl, (pocket1)    
    ld a, (pocket3)
    cp 2
    jr nz, not_got_acg
    ld a, h
    cp 1
    jr nz, not_got_acg
    ld a, l
    and a
    jr nz, not_got_acg
    res 7, e

not_got_acg
    call update_collision_grid_for_door
    call correction_for_acg
    jr next_door_loop2

found_door_locked                   ; if any pocket contains value in c, remove collision for door, else set collision
    res 7, e                        ; assume we've got the right key

    ld a, (pocket1)
    cp c
    jr z, got_the_right_key
    ld a, (pocket2)
    cp c
    jr z, got_the_right_key
    ld a, (pocket3)
    cp c
    jr z, got_the_right_key

    set 7, e                        ; not carrying the right key - collision close

got_the_right_key
    ld a, e
    call update_collision_grid_for_door
    jr next_door_loop2

update_collision_grid_for_door
    bit 7, a
    jp nz, upcgrid_2

    ld a, (this_rooms_door_count)
    sub b
    inc a
    jp upcgrid_3

upcgrid_2
    ld a, 0xff
    
upcgrid_3
    ld l, (ix + 2)          ; y
    srl l
    srl l
    srl l

    ld h, 0
    add hl, hl
    add hl, hl
    add hl, hl
    ld d, h
    ld e, l                 ; de = y * 8
    add hl, hl
    add hl, de              ; hl = (y * 16) + (y * 4) = y * 24

    ld e, (ix + 1)
    srl e
    srl e
    ld d, 0
    add hl, de

    ld de, collision_grid
    add hl, de              ; hl is first char in collision grid for this item

    ld c, (ix + 6)          ; height of item
    srl c
    srl c
    srl c

update_coll_item_loop2 
    ld b, (ix + 5)
    srl b
    push hl

update_coll_item_loop
    ld (hl), a
    inc hl
    djnz update_coll_item_loop

    pop hl
    ld de, 24
    add hl, de

    dec c    
    jp nz, update_coll_item_loop2    

    ret

correction_for_acg
    ld hl, collision_grid + (24 * 8) + 19
    ld b, 8
    ld de, 24

correct_acg    
    ld (hl), 0x00
    add hl, de
    djnz correct_acg
    ret

door_to_toggle
    defw 0x0000