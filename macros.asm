DEBUG=1

macro BORDER_ON hw_colour
if DEBUG
    ld d, {hw_colour}
    ld a, (show_vsync)
    and a
    jp nz, $+6
    call set_border
endif
mend

macro BORDER_OFF
if DEBUG
    ld d, hw_black
	call set_border
endif
mend

macro SELECT_BANK bank_num
    ld c, {bank_num}
    ld b, 0x7f
    out (c), c
    ld a, c
    ld (memory_bank), a
mend