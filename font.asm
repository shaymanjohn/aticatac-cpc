show_text                       ; IN: ix = message address
    call calc_text_scr_address

    ld a, (ix + 2)
    ld iyh, a                   ; hold colour mask in iyh

    ld a, (ix + 3)              ; get 1st letter

show_text_loop
    push hl
    call draw_letter
    pop hl

    ld a, (ix + 4)
    and a
    ret z    

    inc ix
    inc l
    inc l
    jp show_text_loop

draw_letter             ; IN: a = character to draw, hl = screen address
    ld de, (font_type)
    ld b, h             ; bc saves screen address
    ld c, l

    sub " "

    ld h, 0
    ld l, a

    add hl, hl          ; multiply character value by 16 and add start
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, de

    ex de, hl

    ld h, b             ; get screen address back in hl
    ld l, c

    push hl
    push de
    call draw_single_letter
    pop de
    pop hl

    ld a, h             ; now draw same on other screen
    xor 0x40
    ld h, a

draw_single_letter
repeat 8
    ld a, (de)
    and iyh 
    ld (hl), a
    inc l
    inc de

    ld a, (de)
    and iyh 
    ld (hl), a
    inc de
    dec l

    GET_NEXT_SCR_LINE
rend
    ret

calc_text_scr_address
    ld h, 0
    ld l, (ix + 1)

    add hl, hl
    ld de, (scr_addr_table)
    add hl, de

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a

    ld c, (ix + 0)
    ld b, 0
    add hl, bc
    ret

font_type
    defw font_data_mode0