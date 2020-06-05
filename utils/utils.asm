switch_screens
    ld a, (visible_screen_base_address)
    ld (hidden_screen_base_address), a
    ld e, a       
    xor 0x40
    ld (visible_screen_base_address), a

    sra a
    sra a

    ld bc, 0xbc0c				; select CRTC register 12
    out (c), c
    ld b, 0xbd	    			; B = I/O address for CRTC register write    
    out (c), a

    ld bc, 0xbc0d				; select CRTC register 13
    out (c), c
    ld b, 0xbd		    		; B = I/O address for CRTC register write
    out (c), 0

    ld a, e                     ; e holds base address of hidden screen
    cp 0xc0        
    jp z, backbuffer_is_c0

    ld hl, scr_addr_table_80
    ld (scr_addr_table), hl
    ret    
    
backbuffer_is_c0
    ld hl, scr_addr_table_c0
    ld (scr_addr_table), hl
    ret

set_pens
    ld hl, pens
    ld e, 16                    ; 16 pens for mode 0
    xor a					    ; initial pen index    
set_pens_loop
    ld d, (hl)		            ; d = ink for pen
    inc hl
    call set_ink
    inc a					    ; increment pen index
    dec e
    jr nz, set_pens_loop
    ret

visible_screen_base_address
    defb 0xc0
hidden_screen_base_address
    defb 0x80

set_pens_off
    ld hl, pens
    ld e, 16                    ; 16 pens for mode 0
    xor a					    ; initial pen index    
    ld d, hw_black              ; hardware black

set_pens_off_loop
    call set_ink
    inc a					    ; increment pen index
    dec e
    jr nz, set_pens_off_loop
    ret

set_ink                     ; IN: a = pen, d = hardware colour. if pen is 16, then change border colour
    ld bc, 0x7f00
    out (c), a              ; pen number
    out (c), d              ; pen colour
    ret

set_border
    ld bc, 0x7f00
    ld a, 0x10
    out (c), a
    out (c), d
    ret

wait_vsync
	ld b, 0xf5
wait_vsync_loop    
	in a, (c)
	rrca
	jr nc, wait_vsync_loop
    ret    

; IN  h = x byte coord, l = y line
; OUT hl = screen address
get_scr_addr
    push de
    ld a, h
    ld h, 0
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld de, (scr_addr_table)
    add hl, de
    ld c, (hl)
    inc hl
    ld b, (hl)
    ld l, a
    ld h, 0
    add hl, hl
    add hl, hl
    add hl, bc
    pop de
    ret

; generate table of screen addresses
make_scr_table
    ld ix, scr_addr_table_c0	; address to store table
    ld iy, scr_addr_table_80
    ld hl, 0xc000				; start address of first scanline
    ld b, 200					; number of scanlines on screen
mst1
    ld (ix + 0), l
    ld (ix + 1), h
    inc ix
    inc ix
    ld a, h
    xor 0x40
    ld (iy + 0), l
    ld (iy + 1), a
    inc iy
    inc iy
    push bc
    call scr_next_line
    pop bc
    djnz mst1
    ret

scr_next_line   ; hl = current screen address
    ld a, h
    add a, 8
    ld h, a
    and 0x38
    ret nz
    ld a, l
    add a, 0x50
    ld l, a
    ld a, h
    adc a, 0xc0
    ld h, a
    ret

rotate_gfx          ; IN: IX = source, de = destination, b = width in bytes, c = height in rows.
    inc ix
    inc de

rotate2    
    ld h, 0
    push bc

rotate1
    ld a, (ix + 0)
    ld l, a
    and 0xaa    
    srl a
    or h
    ld (de), a

    ld a, l
    and 0x55
    sla a
    ld h, a
    
    inc ix
    inc ix
    inc de
    inc de
    djnz rotate1

    pop bc
    dec c
    jr nz, rotate2
    ret

; generate mask for rotated sprites
gen_mask
    ld d, h
    ld e, l
    inc de
    ld ixh, b

fix_mask
    ld b, ixh

fix_mask2
    ld a, (de)

    call mask_gen

    ld (hl), a    
    inc hl
    inc hl
    inc de
    inc de
    djnz fix_mask2

    dec c
    jr nz, fix_mask

    ret

mask_gen
    push bc
    push de

    ld b, a
    and 0xaa
    ld d, a
    ld a, b
    and 0x55
    ld e, a             ; de now has left pixel / right pixel

    ld b, 0x00
    ld a, d
    and a
    jr nz, do_right_pixel
    ld b, 0xaa

do_right_pixel
    ld c, 0x00
    ld a, e
    and a
    jr nz, done_both
    ld c, 0x55

done_both
    ld a, b
    or c

    pop de
    pop bc

    ret

flip_gfx
    push bc
    push ix

    ld a, c
    ld c, b
    ld b, 0
    add ix, bc

flip1    
    ld a, (ix + 0)
    and 0xaa
    srl a
    ld c, a
    ld a, (ix + 0)
    and 0x55
    sla a
    or c
    ld (de), a
    dec ix
    inc de
    djnz flip1

    pop ix
    pop bc
    dec c
    jr nz, flip_gfx

    ret

scr_addr_table_c0              ; table/array for screen addresses for each scan line
    defs 200 * 2

scr_addr_table_80
    defs 200 * 2

scr_addr_table
    defs 2

pens
    defb hw_black
    defb hw_blue
    defb hw_brightBlue
    defb hw_green
    defb hw_cyan
    defb hw_skyBlue
    defb hw_brightGreen
    defb hw_red
    defb hw_pastelCyan
    defb hw_brightRed
    defb hw_orange
    defb hw_pink
    defb hw_brightYellow
    defb hw_brightWhite
    defb hw_black           ; black in sprites
    defb 0x56               ; room colour
