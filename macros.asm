GOD_MODE=0

macro SET_MODE screenmode
    ld bc, 0x7f00 + 128 + 8 + 4 + {screenmode}
	out (c), c
mend

macro DO_SPRITE
    call erase_sprite
    call update_sprite
    call draw_sprite
mend

macro GET_NEXT_SCR_LINE
    ld a, h
    add a, 8
    ld h, a
    and 0x38
    jr nz, @got_next_line
    ld a, l
    add a, 0x40
    ld l, a
    ld a, h
    adc 0xc0
    ld h, a
@got_next_line
mend

macro SELECT_BANK bank_num
    ld a, {bank_num}
    ld (memory_bank), a    
    ld b, 0x7f
    out (c), a
mend

macro RANDOM_IN_A       ; from http://www.z80.info/pseudo-random.txt
    ld a, (random_seed)
    ld b, a 

    rrca                ; multiply by 32
    rrca
    rrca
    xor 0x1f

    add a, b
    sbc a, 255          ; carry

    ld (random_seed), a
mend

macro ANIMATE_SPRITE
    ld a, (ix + spr_frame)
    inc a
    and 0x0f
    ld (ix + spr_frame), a
mend