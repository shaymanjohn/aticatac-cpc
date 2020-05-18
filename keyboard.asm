read_keys
    ld hl, keyboard_state
    ld bc, 0xf782
    out (c), c
    ld bc, 0xf40e
    ld e, b
    out (c), c
    ld bc, 0xf6c0
    ld d, b
    out (c), c
    ld c, 0x00
    out (c), c
    ld bc, 0xf792
    out (c), c
    ld a, 0x40
    ld c, 0x4a

key_loop
    ld b, d
    out (c), a
    ld b, e
    ini
    inc a
    cp c
    jp c, key_loop
    ld bc, 0xf782
    out (c), c

    ret

keyboard_state
    defs 10