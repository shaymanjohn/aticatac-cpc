falling_tasks
    BORDER_ON hw_pastelCyan
    call erase_previous_tunnels

    BORDER_ON hw_pink
    call draw_new_tunnels

    BORDER_ON hw_orange
    call show_clock    

    BORDER_OFF

	ld a, (still_falling)
	and a
	ret nz

    di
    call clear_room
    call draw_room

    ld a, state_game
    ld (current_game_state), a

    ld hl, game_interrupts
    ld (current_interrupts), hl	

	ld a, interrupt_notReady
	ld (interrupt_index), a
    ei

    ret

erase_previous_tunnels
    xor a
    ld (tunnel_pen), a

    ld hl, save_fall_data
    ld a, (hidden_screen_base_address)
    cp 0xc0
    jp nz, erase_pt2
    inc hl

erase_pt2
    ld (this_index), hl

    ld a, (hl)
    and a
    ret z           ; dont erase if not drawn yet
    
    ld b, 7
erase_loop    
    rra
    call c, draw_tunnels
    djnz erase_loop
    ret    

draw_new_tunnels
    ld a, 0xf3
    ld (tunnel_pen), a

; first update tunnel index
    ld a, (fall_index)
    inc a
    cp (end_falling_sequence - falling_sequence) * 2
    jp z, falling_done

    ld (fall_index), a

    ld l, a
    srl l
    ld h, 0
    ld de, falling_sequence
    add hl, de
    ld a, (hl)

    ld hl, (this_index)
    ld (hl), a    

    ld b, 7
draw_loop    
    rra
    call c, draw_tunnels
    djnz draw_loop
    ret

falling_done
    xor a
    ld (still_falling), a
    ret

draw_tunnels
    push af
    push bc

    dec b
    ld l, b
    sla l
    sla l
    ld h, 0
    ld de, tunnel_data
    add hl, de
    ex de, hl

    ld ixh, d
    ld ixl, e

    ld a, b
    cp 6
    jp nz, draw_normal_tunnel
    call draw_smallest_tunnel
    jp tunnel_loop

draw_normal_tunnel    
    call nz, draw_single_tunnel

tunnel_loop
    pop bc
    pop af
    ret

draw_smallest_tunnel
    ld l, (ix + 1)              ; get y
    ld h, 0
    add hl, hl
    ld de, (scr_addr_table)
    add hl, de

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a                     ; hl is screen address

    ld c, (ix + 0)
    ld b, 0
    add hl, bc                  ; add start x

    ld a, (tunnel_pen)
    ld c, a   

    push hl

    and %01010101  
    ld (hl), a
    inc l
    ld (hl), c
    inc l
    ld a, c
    and %10101010
    ld (hl), a

    pop hl
    call scr_next_line
    push hl

    ld a, c
    and %01010101
    ld (hl), a
    inc l
    inc l
    ld a, c
    and %10101010
    ld (hl), a

    pop hl
    call scr_next_line
    push hl    
    ld a, c
    and %01010101
    ld (hl), a
    inc l
    inc l
    ld a, c
    and %10101010
    ld (hl), a

    pop hl
    call scr_next_line
    push hl
    ld a, c
    and %01010101
    ld (hl), a
    inc l
    inc l
    ld a, c
    and %10101010
    ld (hl), a

    pop hl
    call scr_next_line
    ld a, c
    and %01010101  
    ld (hl), a
    inc l
    ld (hl), c
    inc l
    ld a, c
    and %10101010
    ld (hl), a

    ret

draw_single_tunnel           ; ix = tunnel data, a = colour

; start with top line
    ld l, (ix + 1)              ; get y
    ld h, 0
    add hl, hl
    ld de, (scr_addr_table)
    add hl, de

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a                     ; hl is screen address

    ld c, (ix + 0)
    ld b, 0
    add hl, bc                  ; add start x

    push hl                     ; save screen address for left side top
    push hl                     ; and for right side top

    ex de, hl

    ld l, (ix + 2)
    ld h, 0
    add hl, hl

    ld c, l
    ld b, h
    ld hl, end_fast_plot_line - 1
    ccf
    sbc hl, bc

    ld (line_plot_addr_top + 1), hl
    ex de, hl

    ld a, (tunnel_pen)
line_plot_addr_top
    call 0

; left side
    pop hl

    and %01010101           ; only show right pixel
    ld c, a
    ld b, (ix + 3)          ; get height / 4
    srl b
    srl b
    srl b

left_side_loop
    push hl
    ld de, 0x800

repeat 7
    ld (hl), c
    add hl, de
rend
    ld (hl), c

    pop hl
    ld de, 0x40
    add hl, de
    djnz left_side_loop
    ld (hl), c

; now bottom line
    ld a, (ix + 1)              ; get y
    add (ix + 3)
    ld l, a
    ld h, 0
    add hl, hl
    ld de, (scr_addr_table)
    add hl, de

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a                     ; hl is screen address

    ld c, (ix + 0)
    ld b, 0
    add hl, bc                  ; add x

    ex de, hl

    ld l, (ix + 2)
    ld h, 0
    add hl, hl

    ld c, l
    ld b, h
    ld hl, end_fast_plot_line - 1
    ccf
    sbc hl, bc

    ld (line_plot_addr_bot + 1), hl
    ex de, hl

    ld a, (tunnel_pen)
line_plot_addr_bot
    call 0    

; right side
    ld c, (ix + 2)
    ld b, 0
    pop hl
    add hl, bc

    and %10101010       ; only show left pixel
    ld c, a

    ld b, (ix + 3)
    srl b
    srl b
    srl b
    
right_side_loop    
    push hl
    ld de, 0x800

repeat 7
    ld (hl), c
    add hl, de
rend
    ld (hl), c

    pop hl
    ld de, 0x40
    add hl, de
    djnz right_side_loop
    ld (hl), c

    ret

fast_plot_line
repeat 64
    ld (hl), a
    inc l
rend
    ret
end_fast_plot_line

falling_sequence            ; each bit set represents a tunnel 
    defb %00000001
    defb %00000010
    defb %00000100
    defb %00001001

repeat 10
    defb %00010010
    defb %00100100
    defb %01001001
rend
    
    defb %00010010
    defb %00100100
    defb %01001000
    defb %00010000
    defb %00100000
    defb %01000000
    defb %00000000
    defb %00000000
end_falling_sequence

tunnel_data     ; y and height both have to be multiples of 8 (apart from last row)
    defb 0x00, 0x08, 0x2e, 0xb0     ; x, y, width, height
    defb 0x04, 0x18, 0x26, 0x90     ; x, y, width, height
    defb 0x08, 0x28, 0x1e, 0x70     ; x, y, width, height
    defb 0x0c, 0x38, 0x16, 0x50     ; x, y, width, height
    defb 0x10, 0x48, 0x0e, 0x30     ; x, y, width, height
    defb 0x14, 0x58, 0x06, 0x10     ; x, y, width, height
    defb 0x16, 0x5e, 0x02, 0x08     ; x, y, width, height

tunnel_pen
    defb 0

still_falling
    defb 0             

fall_index
    defb 0

save_fall_data
    defb 0
    defb 0

this_index
    defw 0