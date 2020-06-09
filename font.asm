include "fontdata.asm"

play_game_text
    defb 0x00, 0x02, 0xff, "PRESS G FOR GAME", 0x00    ; x, y, colour, message, terminator
cursors_text
    defb 0x00, 0x04, 0xff, "CURSOR KEYS TO MOVE", 0x00    ; x, y, colour, message, terminator
menu_text
    defb 0x00, 0x06, 0xf3, "PRESS M TO RETURN TO MENU", 0x00    ; x, y, colour, message, terminator
interrupts_text
    defb 0x00, 0x08, 0x33, "PRESS V TO TOGGLE INTERRUPT TIMINGS", 0x00    ; x, y, colour, message, terminator
next_screen_text
    defb 0x00, 0x0a, 0xcf, "PRESS N FOR NEXT SCREEN" 0x00    ; x, y, colour, message, terminator
previous_screen_text
    defb 0x00, 0x0c, 0xcf, "PRESS B FOR PREVIOUS SCREEN", 0x00    ; x, y, colour, message, terminator    

; 15 = 0xff, 14 = 0x3f, 13 = 0xf3, 12 = 0x33, 11 = 0xcf, 10 = 0x0f, 9 = 0xc3, 8 = 0x03

show_text                   ; IN: ix = message address
    ld h, 0
    ld l, (ix + 1)

    add hl, hl
    add hl, hl
    add hl, hl
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

    ld a, (ix + 2)
    ld iyh, a

    push hl
    push ix
    call show_text_loop
    pop ix
    pop hl

; Draw same string on 2nd screen
    ld a, h
    xor 0x40
    ld h, a
    call show_text_loop

    ret

show_text_loop
    ld a, (ix + 3)
    and a
    ret z

    push hl
    call draw_letter
    inc ix
    pop hl
    inc hl
    inc hl

    jr show_text_loop

; IN: a = character to draw, hl = screen address
draw_letter
    ld de, font_data
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

    ld bc, &800
    add hl, bc

start_draw_letter 
    ld bc, &800 - 1

    ld a, (de)
    and iyh    
    ld (hl), a
    inc hl
    inc de
    ld a, (de)
    and iyh
    ld (hl), a
    inc de
    add hl, bc

    ld a, (de)
    and iyh    
    ld (hl), a
    inc hl
    inc de
    ld a, (de)
    and iyh    
    ld (hl), a
    inc de
    add hl, bc

    ld a, (de)
    and iyh    
    ld (hl), a
    inc hl
    inc de
    ld a, (de)
    and iyh
    ld (hl), a
    inc de
    add hl, bc

    ld a, (de)
    and iyh    
    ld (hl), a
    inc hl
    inc de
    ld a, (de)
    and iyh
    ld (hl), a
    inc de
    add hl, bc

    ld a, (de)
    and iyh    
    ld (hl), a
    inc hl
    inc de
    ld a, (de)
    and iyh    
    ld (hl), a
    inc de
    add hl, bc

    ld a, (de)
    and iyh    
    ld (hl), a
    inc hl
    inc de
    ld a, (de)
    and iyh    
    ld (hl), a
    inc de
    add hl, bc

    ld a, (de)
    and iyh    
    ld (hl), a
    inc hl
    inc de
    ld a, (de)
    and iyh    
    ld (hl), a
    inc de
    add hl, bc

    ld a, (de)
    and iyh    
    ld (hl), a
    inc hl
    inc de
    ld a, (de)
    and iyh    
    ld (hl), a

    ret                        
