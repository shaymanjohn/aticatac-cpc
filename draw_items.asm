draw_items
    xor a
    ld (this_rooms_door_count), a

    ld a, (room_number)
    ld h, 0
    ld l, a
    add hl, hl
    ld de, room_bank_items_per_room
    add hl, de

    ld e, (hl)
    inc hl
    ld d, (hl)

    ex de, hl

draw_item_loop
    ld a, room_bank_config
    call set_memory_bank

    ld e, (hl)                  ; hl = pointer in items_per_room
    inc hl
    ld d, (hl)
    inc hl

    ld a, d
    or e
    jr nz, continue_items       ; de = pointer in BackLocLists

    ld a, item_bank_config
    jp set_memory_bank

continue_items
    ld ixh, d
    ld ixl, e

    ld c, 0
    ld a, (room_number)
    xor (ix + 1)
    jr z, skip_dil

    ld bc, 8
    add ix, bc

skip_dil

    push hl
    call explode_item           ; c has offset in pair
    call draw_item              ; ix points to item in item_list

    pop hl

    jr draw_item_loop

draw_item                       ; ix + 0 = item, 3 = x, 4 = y, 5 = rotation
    ld l, (ix + 0)
    ld h, 0
    add hl, hl
    ld de, item_bank_items      
    add hl, de

    ld b, (ix + 3)
    ld c, (ix + 4)              ; bc has x, y of item
    srl b
    srl b                       ; divide x by 4

    ld a, (ix + 5)              ; a has rotation value
    and 0xfe
    ld (rotation), a

    ld e, a
    push bc
    ld a, item_bank_config
    call set_memory_bank
    pop bc
    ld a, e

    ld e, (hl)
    inc hl
    ld d, (hl)    
    ld ixh, d
    ld ixl, e                   ; ix now points to specific item for drawing

    bit 6, a                    ; check rotation flag
    jr z, portrait_item

landscape_item
    ld a, c
    ld c, (ix + 0)              ; subtract height of item from y pos
    sla c                       ; rotated, so calculate correct height
    sla c
    sub c                       
    inc a                       ; a is now top row

    ld l, a                     ; get start line screen address
    ld h, 0
    add hl, hl
    ld de, (scr_addr_table)
    add hl, de

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a

    ld c, b
    ld b, 0
    add hl, bc                  ; add x, now hl has screen address

    ld e, (ix + 6)
    ld d, (ix + 7)              ; de = gfx data
    
    ld a, (rotation)
    bit 7, a
    jr z, li3

    push hl
    ld l, (ix + 2)
    ld h, (ix + 3)
    add hl, de
    dec hl
    ex de, hl
    pop hl

    ld c, (ix + 0)              ; height
    sla c
    sla c
li2
    ld b, (ix + 1)              ; width
    srl b
    srl b

    jp draw_item_flip

li3
    ld c, (ix + 0)              ; height
    sla c
    sla c

    ld b, (ix + 1)              ; width
    srl b
    srl b

    jp draw_item_noflip

portrait_item
    ld a, c                     ; x, y is bottom left of object so
    ld c, (ix + 1)              ; subtract height of item from y pos
    sub c                       
    inc a                       ; a is now top row

    ld l, a                     ; get start line screen address
    ld h, 0
    add hl, hl
    ld de, (scr_addr_table)
    add hl, de

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a

    ld c, b
    ld b, 0
    add hl, bc                  ; add x, now hl has correct screen address

    ld a, (rotation)
    bit 7, a
    jr nz, port_item

    ld e, (ix + 4)
    ld d, (ix + 5)              ; de = gfx data

    ld c, (ix + 1)              ; height
    ld b, (ix + 0)              ; width

    jp draw_item_noflip

port_item    
    ld b, h
    ld c, l
    ld l, (ix + 4)
    ld h, (ix + 5)             
    ld e, (ix + 2)
    ld d, (ix + 3)              ; start of portrait + size - 1
    add hl, de
    ex de, hl
    dec de                      ; de = end of portrait data
    ld h, b
    ld l, c

    ld c, (ix + 1)              ; height
    ld b, (ix + 0)              ; width

draw_item_flip
    push bc
    push hl
dif1
    ld a, (de)

flip_pixels           ; swap left and right pixels
    push bc

    ld c, a
    and %10101010
    ld b, a
    srl b
    ld a, c
    and %01010101
    sla a
    or b

    pop bc

    ld (hl), a
    inc l
    dec de
    djnz dif1

    pop hl
    call scr_next_line
    pop bc
    dec c
    jp nz, draw_item_flip

    ret

draw_item_noflip
    push bc
    push hl
dinf1
    ld a, (de)
    ld (hl), a
    inc l
    inc de
    djnz dinf1

    pop hl
    call scr_next_line
    pop bc
    dec c
    jp nz, draw_item_noflip

    ret

; type, x, y, item pointer (to get paired), actual width, actual height, pair offset 
;
; constructs a temporary list in this_rooms_door_list with this structure:
; 0 = item type 
; 1 = x
; 2 = y
; 3 = item_pointer_lo in room_bank_item_list
; 4 = item_pointer_hi in room_bank_item_list
; 5 = width
; 6 = height
; 7 = offset in item pair

explode_item                      ; IN: ix = item address in room_bank_item_list
    ld a, c
    ld (item_offset), a           ; which of the item pair we've got

    ld a, (this_rooms_door_count)
    ld l, a
    ld h, 0
    add hl, hl
    add hl, hl
    add hl, hl                      ; structure is 8 bytes long, so x8
    ld de, this_rooms_door_list
    add hl, de

    ld a, (ix + 7)
    ld (item_is_door), a

    ld a, (ix + 0)                  
    ld d, a
    ld iyl, a

    ld (hl), a                      ; type (0)
    inc hl
    ld a, (ix + 3)
    srl a
    ld (hl), a                      ; x (1)
    inc hl
    ld a, (ix + 4)                  ; y (2)
    ld (hl), a
    inc hl
    ld a, ixl
    ld (hl), a
    inc hl
    ld a, ixh
    ld (hl), a                      ; item pointer (3 & 4)
    inc hl

    ld b, h
    ld c, l                         ; bc now item pointer (+ 5)

; get item metadata for width / height
    ld l, d
    ld h, 0
    add hl, hl
    ld de, item_bank_items
    add hl, de

    ld a, (ix + 5)
    ld iyh, a                       ; save rotation value in iyh

    push bc
    ld a, item_bank_config
    call set_memory_bank
    pop bc

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a                           ; hl now at this items metadata

    ld a, iyh
    bit 6, a
    jr z, expl_portrait

; landscape rotation
    ld a, (hl)                  ; width
    sla a                       
    sla a                       ; x 4
    ld e, a

    inc hl
    ld a, (hl)                  ; height
    srl a
    srl a                       ; / 4
    ld (bc), a                 ; save width
    inc bc
    ld a, e
    ld (bc), a                 ; save height

    jr inc_list                 ; e = height

expl_portrait
    ld a, (hl)
    ld (bc), a                  ; width
    inc hl
    inc bc
    ld a, (hl)
    ld (bc), a                  ; height
    ld e, a

inc_list
    inc bc
    ld a, (item_offset)
    ld (bc), a
    dec bc
    dec bc                      ; finally, subtract height from y pos
    dec bc
    dec bc
    dec bc
    ld a, (bc)
    sub e
    inc a
    ld (bc), a

    ; Some doors depend on which character player is (clock, bookcase, barrel)...
    ld a, iyl
    cp item_clock
    call z, check_clock_is_door
    
    cp item_bookcase
    call z, check_bookcase_is_door

    cp item_barrel    
    call z, check_barrel_is_door

    ld a, (item_is_door)        ; only save in list if it's a door...
    and a
    jr z, skip_save

    ld hl, this_rooms_door_count
    inc (hl)

skip_save
    ld a, room_bank_config
    jp set_memory_bank

check_clock_is_door
    ld b, a
    ld a, (player_character)
    cp character_knight
    jr z, player_is_knight
    xor a
    ld (item_is_door), a
player_is_knight
    ld a, b
    ret

check_bookcase_is_door
    ld b, a
    ld a, (player_character)
    cp character_wizard
    jr z, player_is_wizard
    xor a
    ld (item_is_door), a
player_is_wizard
    ld a, b
    ret

check_barrel_is_door
    ld b, a
    ld a, (player_character)
    cp character_serf
    jr z, player_is_serf
    xor a
    ld (item_is_door), a
player_is_serf
    ld a, b
    ret    
        
rotation
    defb 0x00

item_offset
    defb 0

item_is_door
    defb 0

