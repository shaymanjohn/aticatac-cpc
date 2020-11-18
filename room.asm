draw_room
    call clear_room
    
    SELECT_BANK room_bank_config
    call draw_outline
    call draw_items

    SELECT_BANK room_bank_config
    call draw_collectables
    
    call draw_food

    SELECT_BANK item_bank_config
    call calc_room_dimensions

    call copy_room_to_other_screen

    SELECT_BANK room_bank_config
    call calculate_collision_grid
    call update_collision_grid_for_items

    call try_teleport_dracula

; Reset data for new room.
    xor a
    ld (room_changed), a

; Temporarily save current room sprite data
    ld hl, sprite1
    ld de, temp_sprite_data
    ld bc, sprite_end - sprite1
    ldir

    ld a, (saved_room_number)
    ld b, a
    ld a, (room_number)

    cp b
    jr z, has_gone_back

    call reset_sprites
    jr gb1

has_gone_back
    ld hl, old_room_sprites
    ld de, sprite1
    ld bc, sprite_end - sprite1
    ldir

    call partial_reset_sprites

gb1
    ld hl, temp_sprite_data
    ld de, old_room_sprites
    ld bc, sprite_end - sprite1
    ldir
    
    ld a, (last_room_number)
    ld (saved_room_number), a

ngb1
    ld a, r
    ld (random_seed), a

    ld hl, 0
    ld (door_to_toggle), hl    
    
    call reset_player
    call init_boss    
    call reset_weapon
    call reset_food_collected

    call set_pens

    ld a, (room_number)
    cp end_room
    ret nz

    ld a, game_completed
    ld (game_over), a
    ret

copy_room_to_other_screen
    ld a, (hidden_screen_base_address)
    ld h, a
    ld l, 0
    
    ld ixh, num_rows

copy_room_loop    
    push hl
    ld a, h
    xor 0x40
    ld d, a
    ld e, l
    ld bc, 48
    ldir
    pop hl
    GET_NEXT_SCR_LINE
    dec ixh
    jr nz, copy_room_loop
    ret

draw_outline
    ld a, (room_number)

    ld bc, room_bank_RoomInfo
    ld l, a
    ld h, 0
    add hl, hl
    add hl, bc
    ld d, (hl)            ; room colour
    set 7, (hl)

    push hl

    cp skeleton_room1
    jr z, skeleton_room
    cp skeleton_room2
    jr z, skeleton_room
    cp skeleton_room3
    jr z, skeleton_room
    cp skeleton_room4
    jr nz, not_skeleton_room

skeleton_room
    ld d, 0    

not_skeleton_room
    ld a, d
    and 0x03
    ld c, a
    ld b, 0
    ld hl, room_colour_palette
    add hl, bc
    ld a, (hl)
    ld (line_pen_number + 1), a

    pop hl

    inc hl
    ld a, (hl)            ; a has room type
    ld (room_type), a

    ld bc, room_bank_RoomTypes
    ld l, a
    ld h, 0
    add hl, hl
    ld d, h
    ld e, l
    add hl, hl
    add hl, de
    add hl, bc            ; hl now points to room info

    ld d, (hl)
    inc hl                
    ld e, (hl)
    inc hl                ; de now has width / height
    ex de, hl
    ld (room_size), hl         ; save it

    ex de, hl

    ld e, (hl)
    inc hl
    ld d, (hl)             ; de is vertex data
    inc hl
    ld c, (hl)
    inc hl
    ld b, (hl)             ; bc is line info

    ex de, hl              ; hl is now vertex data
    ld (point_address), hl

    dec bc
    ld ixh, b
    ld ixl, c               ; ix now points to index list - 1

draw1
    inc ix
    ld a, (ix + 0)
    cp 0xff
    ret z

draw3
    ; convert a into a point address stored in bc
    call get_point

draw2
    inc ix
    ld a, (ix + 0)
    cp 0xff
    jr z, draw1

    ; convert a into a point stored in de
    push bc
    call get_point
    ld d, b
    ld e, c
    pop bc

    push bc
    call plot_line
    pop bc
    jr draw2

get_point           ; IN: A = coord number, out: bc = coord
    ld hl, (point_address)
    add a
    ld c, a
    ld b, 0
    add hl, bc
    ld b, (hl)
    inc hl
    ld c, (hl)
    ret

clear_room
    ld a, (hidden_screen_base_address)

clear_room2    
    ld h, a
    ld l, 0
    ld b, num_rows

clear1
    push bc
    push hl
    ld bc, 0x2f
    ld (hl), 0
    ld d, h
    ld e, l
    inc de
    ldir
    pop hl
    GET_NEXT_SCR_LINE
    pop bc
    djnz clear1

    ret

calc_room_dimensions
    ld hl, (room_size)
    srl h

    ld a, 0x30
    sub h
    sub 4
    ld (min_x), a
    ld a, 0x30
    add h
    sub 4
    ld (max_x), a

    ld a, 0x60
    sub l
    sub 9
    ld (min_y), a
    ld a, 0x60
    add l
    sub 12
    ld (max_y), a
    ret

calculate_collision_grid
    ld hl, collision_grid
    ld de, collision_grid + 1
    ld bc, (collision_grid_size * collision_grid_size) - 1
    ld (hl), 0xff
    ldir

    call block_items
    call block_room
    ; call draw_collision_grid
    ret

block_room
    ld bc, 0                        ; set all collision tiles based on min-max x and y
    ld hl, collision_grid

set_grid                            ; b is y, c is x
    ld a, (min_y)                   ; divide by 8
    srl a
    srl a
    srl a
    cp b
    jr nc, skip_this_element

    ld a, (max_y)                   ; divide by 8
    srl a
    srl a
    srl a
    inc a
    inc a
    cp b
    jr c, skip_this_element    

    ld a, (min_x)                   ; divide by 4
    srl a
    srl a
    dec a
    cp c
    jr nc, skip_this_element    

    ld a, (max_x)                   ; divide by 4
    srl a
    srl a
    inc a
    cp c
    jr c, skip_this_element

set_grid_element
    ld a, (hl)

    call get_type_for_collision_index       ; is this element a table or trapdoor?
    cp active_door_trapdoor
    jr z, skip_this_element

    cp item_table
    jr nz, clear_the_floor

    ld (hl), 0xff
    jr skip_this_element

clear_the_floor
    ld (hl), 0

skip_this_element    
    inc hl

    inc c
    ld a, c
    cp collision_grid_size
    jr nz, set_grid

    ld c, 0 
    inc b
    ld a, b
    cp collision_grid_size
    jr nz, set_grid
    ret

get_type_for_collision_index    ;   IN: A = door index + 1
    push de
    push hl
    dec a
    ld l, a
    ld h, 0
    add hl, hl
    add hl, hl
    add hl, hl
    ld de, this_rooms_door_list
    add hl, de
    ld a, (hl)
    pop hl
    pop de
    ret

block_items
    ld a, (this_rooms_door_count)
    ld b, a
    ld ix, this_rooms_door_list

collision_list_loop
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

    push bc

    ld a, (this_rooms_door_count)
    sub b
    inc a
    ld (this_doors_index), a

    call block_out_item
    pop bc

    ld de, 8
    add ix, de
    djnz collision_list_loop
    ret

block_out_item
    call is_door_locked_or_closed

    ld c, (ix + 6)          ; height of item
    srl c
    srl c
    srl c

coll_item_loop2 
    ld b, (ix + 5)
    srl b

    ld a, (ix + 0)
    cp item_clock
    jr nz, not_a_clock
    dec b                   ; adjust width if a clock

not_a_clock
    push hl    
    ld a, (this_doors_index)

coll_item_loop
    ld (hl), a
    inc hl
    djnz coll_item_loop

    pop hl
    ld de, 24
    add hl, de

    dec c    
    jr nz, coll_item_loop2
    ret

is_door_locked_or_closed    ; IN: ix = item, OUT: a=0xff if so, otherwise a unchanged
    ld e, (ix + 3)
    ld d, (ix + 4)

    ld a, (de)
    cp item_table
    ret z

    inc de
    inc de

    ld a, (de)
    bit 7, a  
    ret z

    ld a, 0xff
    ld (this_doors_index), a
    ret

point_address
    defw 0

room_size
    defw 0
min_x
    defb 0
max_x
    defb 0
min_y
    defb 0
max_y
    defb 0

this_doors_index
    defb 0x00

room_number
    defb 0x00
last_room_number
    defb 0x00
saved_room_number
    defb 0x00

room_changed
    defb 0

room_type
    defb 0

next_room_number
    defb 0

room_colour_palette
    defb 0x0c   ; 0x02
    defb 0xfc   ; 0x07
    defb 0x3f   ; 0x0e
    defb 0xcc   ; 0x03
