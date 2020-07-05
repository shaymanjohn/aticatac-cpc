draw_weapon
    ld a, (weapon_active)
    and a
    ret z

    ld a, (weapon_frame)
    srl a
    srl a

    add a
    ld c, a
    ld b, 0
    ld hl, (weapon_type)
    add hl, bc

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a                     ; hl now pointing to frame specific info

    ex de, hl
    ld ixh, d
    ld ixl, e                   ; store this pointer in ix

    ld a, (weapon_y)
    add (ix + 3)
    ld l, a
    ld h, 0
    add hl, hl
    ld de, (scr_addr_table)
    add hl, de

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a

    ld a, (weapon_x)
    srl a
    add (ix + 2)
    ld c, a
    ld b, 0
    add hl, bc              ; hl has screen address

    ; save ix and hl here...
    ld a, (hidden_screen_base_address)
    cp 0xc0
    jp nz, store_weapon_with_80

    ld (save_weapon_address_c0), hl
    ld (save_weapon_pointer_c0), ix
    jp draw_weapon_entry2

store_weapon_with_80
    ld (save_weapon_address_80), hl
    ld (save_weapon_pointer_80), ix

draw_weapon_entry2
    ld de, (ix + 4)         ; de has graphics
    ld b, (ix + 1)          ; b has height

    ld a, (ix + 6)
    ld (gfx_call + 1), a
    ld a, (ix + 7)
    ld (gfx_call + 2), a

gfx_call
    call 0x0000             ; modified above

    ld bc, item_bank_config
    out (c), c    

    ret

erase_weapon
    ld a, (hidden_screen_base_address)
    cp 0xc0
    jp nz, erase_weapon_with_80

    ld hl, (save_weapon_address_c0)
    ld de, (save_weapon_pointer_c0)
    jp eraseweaponx

erase_weapon_with_80
    ld hl, (save_weapon_address_80)
    ld de, (save_weapon_pointer_80)
    
eraseweaponx
    ld a, h
    or l
    ret z                       ; stop here if not yet set

    ld ixh, d
    ld ixl, e

    call draw_weapon_entry2

    ld a, (weapon_active)
    and a
    ret nz

    call weapon_off
    ret

kill_weapon_with_80
    ld (save_weapon_address_80), hl
    ret

weapon_off
    xor a
    ld (weapon_active), a

    ld hl, 0
    ld (save_weapon_address_c0), hl
    ld (save_weapon_address_80), hl
    ret

fire_weapon
    ld a, (weapon_active)
    and a
    ret nz

    ld a, (fire_delay)
    and a    
    jp z, can_fire
    dec a
    ld (fire_delay), a

    ret

can_fire
    ld a, fire_decay
    ld (weapon_active), a

    ld a, (player_x)
    ld (weapon_x), a
    
    ld a, (player_y)
    ld (weapon_y), a

    ld a, (fire_direction)
    ld de, 0x0000

    bit player_left_bit, a
    jp z, fire_right
    ld d, -fire_horizontal_speed

fire_right
    bit player_right_bit, a
    jp z, fire_down
    ld d, fire_horizontal_speed

fire_down
    bit player_down_bit, a
    jp z, fire_up
    ld e, fire_vertical_speed

fire_up
    bit player_up_bit, a
    jp z, fire_checked
    ld e, -fire_vertical_speed

fire_checked
    ld a, d
    or e
    jp nz, something_fired
    ld d, fire_horizontal_speed

something_fired 
    ld a, d
    ld (weapon_x_inc), a
    ld a, e
    ld (weapon_y_inc), a

    ret

move_weapon
    ld a, (weapon_active)
    and a
    ret z

    dec a
    ld (weapon_active), a

    and a
    jp nz, move_weapon_2

    ld a, 2
    ld (fire_delay), a

move_weapon_2
    ld a, (weapon_frame_inc)
    ld b, a
    ld a, (weapon_frame)
    add b
    and 0x1f                     ; valid frames: 0 -> 31
    ld (weapon_frame), a

    ld a, (weapon_x_inc)
    ld b, a
    ld a, (weapon_x)
    add b
    ld (weapon_x), a
    ld b, a                     ; b has updated weapon_x

    ld a, (weapon_y_inc)
    ld c, a
    ld a, (weapon_y)
    add c
    ld (weapon_y), a
    ld c, a                     ; c has updated weapon_y    

    ld a, (min_x)
    ld d, a
    cp b
    jp nc, bounce_weapon_x

    ld a, (max_x)
    ld d, a
    cp b
    jp nc, check_weapon_y

bounce_weapon_x
    ld a, (weapon_x_inc)
    neg
    ld (weapon_x_inc), a

    ld a, d
    ld (weapon_x), a
    
check_weapon_y
    ld a, (min_y)
    ld d, a
    cp c
    jp nc, bounce_weapon_y

    ld a, (max_y)
    ld d, a
    cp c
    ret nc

bounce_weapon_y
    ld a, (weapon_y_inc)
    neg
    ld (weapon_y_inc), a
    
    ld a, d
    ld (weapon_y), a

    ret

weapon2
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
    call scr_next_line
    djnz weapon2

    ret

weapon3
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
    call scr_next_line
    djnz weapon3

    ret

weapon4
    ld c, h

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
    ld h, c

    call scr_next_line
    djnz weapon4

    ret

weapon_type
    defw spell_data

weapon_x
    defb 0x38

weapon_y
    defb 0x80

weapon_active
    defb 0x00

weapon_x_inc
    defb 0x00

weapon_y_inc
    defb 0x00

weapon_frame
    defb 0x00

weapon_frame_inc
    defb 0x01

fire_delay
    defb 0x00

save_weapon_address_c0
    defw 0x00
save_weapon_pointer_c0
    defw 0x00
save_weapon_address_80
    defw 0x00
save_weapon_pointer_80
    defw 0x00

sword_data
    defw sword_frame7, sword_frame6
    defw sword_frame5, sword_frame4
    defw sword_frame3, sword_frame2
    defw sword_frame1, sword_frame0

sword_datax
    defw sword_frame0, sword_frame1
    defw sword_frame2, sword_frame3
    defw sword_frame4, sword_frame5
    defw sword_frame6, sword_frame7

spell_data
    defw spell_frame3, spell_frame2
    defw spell_frame1, spell_frame0
    defw spell_frame3, spell_frame2
    defw spell_frame1, spell_frame0

axe_data
    defw axe_frame7, axe_frame6
    defw axe_frame5, axe_frame4
    defw axe_frame3, axe_frame2
    defw axe_frame1, axe_frame0    

axe_datax
    defw axe_frame0, axe_frame1
    defw axe_frame2, axe_frame3
    defw axe_frame4, axe_frame5
    defw axe_frame6, axe_frame7

sword_frame0
    defb 0x02, 0x10                     ; x, y
    defb 0x01, 0x00                     ; offset x, offset y
    defw weapon_sword_0                 ; graphics data
    defw weapon2                        ; draw routine

sword_frame1
    defb 0x03, 0x0b
    defb 0x00, 0x03
    defw weapon_sword_1
    defw weapon3

sword_frame2
    defb 0x04, 0x06
    defb 0x00, 0x06
    defw weapon_sword_2
    defw weapon4

sword_frame3
    defb 0x03, 0x0b
    defb 0x00, 0x03
    defw weapon_sword_3
    defw weapon3

sword_frame4
    defb 0x02, 0x10
    defb 0x01, 0x00
    defw weapon_sword_4
    defw weapon2

sword_frame5
    defb 0x03, 0x0b
    defb 0x00, 0x02
    defw weapon_sword_5
    defw weapon3

sword_frame6
    defb 0x04, 0x06
    defb 0x00, 0x04
    defw weapon_sword_6
    defw weapon4

sword_frame7
    defb 0x03, 0x0b
    defb 0x00, 0x02
    defw weapon_sword_7
    defw weapon3

spell_frame0
    defb 0x04, 0x0e
    defb 0x00, 0x00
    defw weapon_spell_0
    defw weapon4

spell_frame1
    defb 0x04, 0x0e
    defb 0x00, 0x00
    defw weapon_spell_1
    defw weapon4

spell_frame2
    defb 0x04, 0x0e
    defb 0x00, 0x00
    defw weapon_spell_2
    defw weapon4

spell_frame3
    defb 0x04, 0x0e
    defb 0x00, 0x00
    defw weapon_spell_3
    defw weapon4

axe_frame0
    defb 0x04, 0x07
    defb 0x00, 0x04
    defw weapon_axe_0
    defw weapon4

axe_frame1
    defb 0x04, 0x0b
    defb 0x00, 0x02
    defw weapon_axe_1
    defw weapon4

axe_frame2
    defb 0x02, 0x10
    defb 0x01, 0x00
    defw weapon_axe_2
    defw weapon2

axe_frame3
    defb 0x03, 0x0e
    defb 0x00, 0x02
    defw weapon_axe_3
    defw weapon3

axe_frame4
    defb 0x04, 0x07
    defb 0x00, 0x04
    defw weapon_axe_4
    defw weapon4

axe_frame5
    defb 0x04, 0x0b
    defb 0x00, 0x04
    defw weapon_axe_5
    defw weapon4

axe_frame6
    defb 0x02, 0x10
    defb 0x01, 0x00
    defw weapon_axe_6
    defw weapon2

axe_frame7
    defb 0x03, 0x0e
    defb 0x00, 0x00
    defw weapon_axe_7
    defw weapon3