switch_screens
    ld a, (screen_address)
    xor &80
    ld (screen_address), a
    ld e, a

    sra a
    sra a

    ld bc, &bc0c				; select CRTC register 12
    out (c), c
    ld b, &bd	    			; B = I/O address for CRTC register write    
    out (c), a

    ld bc, &bc0d				; select CRTC register 13
    out (c), c
    ld b, &bd		    		; B = I/O address for CRTC register write
    out (c), 0

    ld hl, scr_addr_table_c0
    ld a, e
    cp $c0
    jp nz, save_scr_table_addr

    ld hl, scr_addr_table_40

save_scr_table_addr
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

screen_address
    defb &c0    

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
	ld b, &f5
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
    ld iy, scr_addr_table_40
    ld hl, &c000				; start address of first scanline
    ld b, 200					; number of scanlines on screen
mst1
    ld (ix + 0), l
    ld (ix + 1), h
    inc ix
    inc ix
    ld a, h
    xor &80
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
    and &38
    ret nz
    ld a, l
    add a, &50
    ld l, a
    ld a, h
    adc a, &c0
    ld h, a
    ret

scr_addr_table_c0              ; table/array for screen addresses for each scan line
    defs 200 * 2

scr_addr_table_40
    defs 200 * 2

scr_addr_table
    defs 2

pens               ; hardware values
    defb hw_black  ; 0 black
    defb 0x58      ; 1 magenta
    defb 0x4d      ; 2 bright magenta
    defb 0x57      ; 3 sky blue
    defb 0x5e      ; 4 yellow
    defb 0x4a      ; 5 bright yellow
    defb 0x4b      ; 6 bright white
    defb 0x5c      ; 7 room colour
    defb 0x40      ; 8 grey
    defb 0x4e      ; 9 pumpkin orange
    defb 0x52      ; 10 green door
    defb 0x4c      ; 11 red door
    defb 0x43      ; 12
    defb 0x5b      ; 13
    defb 0x43      ; 14 panel border    
    defb 0x4b      ; 15 white
