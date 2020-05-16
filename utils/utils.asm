wait_vblank
    ld b, &f5
wait_l1    
    in a, (c)
    rra
    jp nc, wait_l1
    ret

set_border
    ld bc, &7f10
    out (c), c
    out (c), a
    ret

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
    ld b, 16                    ; 16 pens for mode 0
    xor a					    ; initial pen index    
set_pens_loop
    push bc
    push af
    ld c, (hl)		            ; b, c = inks for pen. If they are the same then no flashing.
    ld b, c
    inc hl
    push hl
    call scr_set_ink
    pop hl
    pop af
    pop bc
    inc a					    ; increment pen index
    djnz set_pens_loop
    ret

screen_address
    defb &c0    

set_pens_off
    ld hl, pens
    ld b, 16                    ; 16 pens for mode 0
    xor a					    ; initial pen index    
set_pens_off_loop
    push bc
    push af
    ld bc, 0
    call scr_set_ink
    pop af
    pop bc
    inc a					    ; increment pen index
    djnz set_pens_off_loop
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

pens
    defb 0      ; 0 black
    defb 4      ; 1 magenta
    defb 8      ; 2 bright magenta
    defb 11     ; 3 sky blue
    defb 12     ; 4 yellow
    defb 24     ; 5 bright yellow
    defb 26     ; 6 bright white
    defb 3      ; 7 room colour
    defb 13     ; grey
    defb 15     ; pumpkin orange
    defb 18     ; green door
    defb 6      ; red door
    defb 25     ; 12
    defb 23     ; 13
    defb 25     ; 14 panel border    
    defb 26     ; 15 white
