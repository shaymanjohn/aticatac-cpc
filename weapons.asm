draw_weapon
    SELECT_BANK sprite_bank_config

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
    add (ix + 2)
    ld c, a
    ld b, 0
    add hl, bc              ; hl has screen address

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
    ld a, (weapon_y)
    dec a
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
    ld c, a
    ld b, 0
    add hl, bc              ; hl has screen address
    ld c, 0x00
    ld b, 0x11

erase_weapon_loop
    push hl

    ld (hl), c
    inc l

    ld (hl), c
    inc l

    ld (hl), c
    inc l

    ld (hl), c

    pop hl
    call scr_next_line
    djnz erase_weapon_loop

    ret

move_weapon
    ld a, (weapon_frame_inc)
    ld b, a
    ld a, (weapon_frame)
    add b
    and 0x1f                     ; valid frames: 0 -> 31
    ld (weapon_frame), a

    ret

weapon2
    ld a, (de)
    ld (hl), a
    inc l
    inc de

    ld a, (de)
    ld (hl), a
    inc de

    dec l
    call scr_next_line
    djnz weapon2

    ret

weapon3
    ld a, (de)
    ld (hl), a
    inc l
    inc de

    ld a, (de)
    ld (hl), a
    inc l
    inc de    

    ld a, (de)
    ld (hl), a
    inc de

    dec l
    dec l
    call scr_next_line
    djnz weapon3

    ret

weapon4
    push hl
    ld a, (de)
    ld (hl), a
    inc l
    inc de

    ld a, (de)
    ld (hl), a
    inc l
    inc de

    ld a, (de)
    ld (hl), a
    inc l
    inc de

    ld a, (de)
    ld (hl), a
    inc de

    pop hl
    call scr_next_line
    djnz weapon4

    ret

weapon_type
    defw spell_data

weapon_x
    defb 0x38

weapon_y
    defb 0x80

weapon_time
    defb 0x00

weapon_x_inc
    defb 0x00

weapon_y_inc
    defb 0x00

weapon_frame
    defb 0x00

weapon_frame_inc
    defb 0x01

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