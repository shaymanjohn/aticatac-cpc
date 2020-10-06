DEBUG=0

macro SET_MODE screenmode
    ld bc, 0x7f00 + 128 + 4 + 8 + {screenmode}
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
    jp nz, @got_next_line
    ld a, l
    add a, 0x40
    ld l, a
    ld a, h
    adc a, 0xc0
    ld h, a
@got_next_line
mend

macro BORDER_ON hw_colour
if DEBUG
    ld a, (show_vsync)
    and a
    jp nz, @no_show
    ld d, {hw_colour}    
    call set_border
@no_show
endif
mend

macro BORDER_OFF
if DEBUG
    ld d, hw_black
	call set_border
endif
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