show_text                       ; IN: ix = message address
    call calc_text_scr_address

    ld a, (ix + 2)
    ld (font_colour), a

    push hl
    push ix

    call show_text_loop

    pop ix
    pop hl

; Draw same string on 2nd screen
    ld a, h
    xor 0x40
    ld h, a
    jp show_text_loop

show_text_fast                    ; IN: ix = message address
    jp show_text_loop_fast

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

show_text_loop
    ld a, (ix + 3)
    and a
    ret z

    push hl
    call draw_letter
    pop hl

    inc ix
    inc hl
    inc hl
    jr show_text_loop

show_text_loop_fast             ; no colour option, unrolled loop
    call calc_text_scr_address

show_text_loop_fast2
    ld a, (ix + 3)
    and a
    ret z

    push hl
    call draw_letter_fast
    pop hl

skip_colon
    inc ix

    inc hl
    inc hl
    jp show_text_loop_fast2

; IN: a = character to draw, hl = screen address
draw_letter
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

    ld a, (font_colour)
    ld iyh, a
    ld b, 8

draw_letter_loop
    push hl

    ld a, (de)
    and iyh 
    ld (hl), a
    inc hl
    inc de

    ld a, (de)
    and iyh 
    ld (hl), a
    inc de

    pop hl
    call scr_next_line
    djnz draw_letter_loop

    ret

draw_letter_fast
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

draw_letter_loop_fast       ; de is font data, hl is screen
    ld a, (de)
    ld (hl), a
    ld b, a
    ld c, h

    ld a, h
    xor 0x40
    ld h, a

    ld (hl), b
    ld h, c
    inc hl
    inc de

    ld a, (de)
    ld (hl), a
    ld b, a    
    ld c, h

    ld a, h
    xor 0x40
    ld h, a

    ld (hl), b
    ld h, c
    inc de
    dec hl

    call scr_next_line

    ld a, (de)
    ld (hl), a
    ld b, a
    ld c, h

    ld a, h
    xor 0x40
    ld h, a

    ld (hl), b
    ld h, c
    inc hl
    inc de

    ld a, (de)
    ld (hl), a
    ld b, a    
    ld c, h

    ld a, h
    xor 0x40
    ld h, a
    
    ld (hl), b
    ld h, c
    inc de
    dec hl

    call scr_next_line

    ld a, (de)
    ld (hl), a
    ld b, a
    ld c, h

    ld a, h
    xor 0x40
    ld h, a

    ld (hl), b
    ld h, c
    inc hl
    inc de

    ld a, (de)
    ld (hl), a
    ld b, a    
    ld c, h

    ld a, h
    xor 0x40
    ld h, a
    
    ld (hl), b
    ld h, c
    inc de
    dec hl

    call scr_next_line

    ld a, (de)
    ld (hl), a
    ld b, a
    ld c, h

    ld a, h
    xor 0x40
    ld h, a

    ld (hl), b
    ld h, c
    inc hl
    inc de

    ld a, (de)
    ld (hl), a
    ld b, a    
    ld c, h

    ld a, h
    xor 0x40
    ld h, a
    
    ld (hl), b
    ld h, c
    inc de
    dec hl

    call scr_next_line

    ld a, (de)
    ld (hl), a
    ld b, a
    ld c, h

    ld a, h
    xor 0x40
    ld h, a

    ld (hl), b
    ld h, c
    inc hl
    inc de

    ld a, (de)
    ld (hl), a
    ld b, a    
    ld c, h

    ld a, h
    xor 0x40
    ld h, a
    
    ld (hl), b
    ld h, c
    inc de
    dec hl

    call scr_next_line

    ld a, (de)
    ld (hl), a
    ld b, a
    ld c, h

    ld a, h
    xor 0x40
    ld h, a

    ld (hl), b
    ld h, c
    inc hl
    inc de

    ld a, (de)
    ld (hl), a
    ld b, a    
    ld c, h

    ld a, h
    xor 0x40
    ld h, a
    
    ld (hl), b
    ld h, c
    inc de
    dec hl

    call scr_next_line

    ld a, (de)
    ld (hl), a
    ld b, a
    ld c, h

    ld a, h
    xor 0x40
    ld h, a

    ld (hl), b
    ld h, c
    inc hl
    inc de

    ld a, (de)
    ld (hl), a
    ld b, a    
    ld c, h

    ld a, h
    xor 0x40
    ld h, a
    
    ld (hl), b
    ret    

font_colour
    defb 0

font_type
    defw font_data_mode0