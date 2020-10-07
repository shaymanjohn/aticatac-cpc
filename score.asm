init_score
    xor a
    ld (score + 0), a
    ld (score + 1), a
    ld (score + 2), a
    ret

add_to_score             ; IN: bc value to add to score
    ld hl, score + 2
    ld a, (hl)
    add a, c
    daa
    ld (hl), a
    dec hl
    ld a, (hl)
    adc a, b
    daa
    ld (hl), a
    dec hl
    ld a, (hl)
    adc a, 0
    daa
    ld (hl), a

    ex de, hl           ; de now points to start of score bytes

    ld b, 3
    ld hl, score_text + 3

convert_score_loop
    ld a, (de)
    ld c, a
    rrca
    rrca
    rrca
    rrca
    and 0x0f
    add '0'
    ld (hl), a
    inc hl

    ld a, c
    and 0x0f
    add '0'
    ld (hl), a

    inc hl
    inc de
    djnz convert_score_loop

    SELECT_BANK item_bank_config
    ld ix, score_text

    jp show_text
