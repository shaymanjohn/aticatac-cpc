init_transients
    ld ix, transient_items
    ld de, 8

    ld a, r                     ; randomize the pickups
    and 0x07
    ld b, a

init_trans_loop
    ld a, (ix + 0)
    cp 0xff
    ret z

    ld (ix + 1), 0              ; not collected

    ld a, (ix + 5)
    cp type_mushroom
    jr z, next_transient

    ld (ix + 2), b              ; item

    ld a, b
    inc a
    cp 10
    jr nz, no_pickup_loop
    xor a

no_pickup_loop
    ld b, a    

next_transient
    add ix, de
    jr init_trans_loop

    ret