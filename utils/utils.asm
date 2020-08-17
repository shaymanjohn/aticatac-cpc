switch_screens
	ld a, (heartbeat)
	inc a
	cp 50
	jp nz, save_heartbeat
	xor a

save_heartbeat
	ld (heartbeat), a

    ld a, (pen_delay)
    and a
    jp z, switch_em
    dec a
    ld (pen_delay), a

switch_em    
    ld a, (visible_screen_base_address)
    ld (hidden_screen_base_address), a
    ld e, a       
    xor 0x40
    ld (visible_screen_base_address), a

    srl a
    srl a

    ld bc, 0xbc0c				; select CRTC register 12
    out (c), c
    ld b, 0xbd	    			; B = I/O address for CRTC register write    
    out (c), a

    ld bc, 0xbc0d				; select CRTC register 13
    out (c), c
    ld b, 0xbd		    		; B = I/O address for CRTC register write
    out (c), 0

	xor a
	ld (frame_ready), a

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
    ld a, (pen_delay)
    and a
    ret nz

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

set_logo_pens
    ld hl, logo_pens
set_logo_pens2
    ld a, (pen_delay)
    and a
    ret nz

    xor a					    ; initial pen index

    ld bc, 0x7f00    

    ld d, (hl)		            ; d = ink for pen
    out (c), a                  ; pen number
    out (c), d                  ; pen colour
    inc hl
    inc a					    ; increment pen index

    ld d, (hl)
    out (c), a                  ; pen number
    out (c), d                  ; pen colour
    inc hl
    inc a	

    ld d, (hl)
    out (c), a                  ; pen number
    out (c), d                  ; pen colour
    inc hl
    inc a	

    ld d, (hl)
    out (c), a              ; pen number
    out (c), d              ; pen colour
    ret

clear_screens
    ld hl, 0xc000
    ld de, 0xc001
    ld bc, 0x3fff
    ld (hl), 0
    ldir

    ld hl, 0x8000
    ld de, 0x8001
    ld bc, 0x3fff
    ld (hl), 0
    ldir
    ret    

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

set_border                  ; d = border colour (hardware value)
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
    ld b, num_rows				; number of scanlines on screen

mst1
    ld (ix + 0), l
    ld (ix + 1), h
    ld a, h
    xor 0x40
    ld (iy + 0), l
    ld (iy + 1), a

    inc ix
    inc ix
    inc iy
    inc iy

    ld a, h
    add a, 8
    ld h, a
    and 0x38
    jp nz, skipx
    ld a, l
    add a, 0x40
    ld l, a
    ld a, h
    adc a, 0xc0
    ld h, a

skipx
    djnz mst1

    ld hl, scr_addr_table_c0
    ld (scr_addr_table), hl 
    ret

rotate_gfx          ; IN: IX = source, de = destination, b = width in bytes, c = height in rows.
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
    inc de
    djnz rotate1

    pop bc
    dec c
    jr nz, rotate_gfx
    ret

scr_addr_table_c0              ; table/array for screen addresses for each scan line
    defs num_rows * 2

scr_addr_table_80
    defs num_rows * 2

scr_addr_table
    defs 2

visible_screen_base_address
    defb 0xc0
hidden_screen_base_address
    defb 0x80    

random_seed
    defb 0x00

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
    defb hw_mauve
    defb hw_brightMagenta

logo_pens
    defb hw_black
    defb hw_brightRed    
    defb hw_pink
    defb hw_brightWhite

logo_pens2
    defb hw_black
    defb hw_brightRed    
    defb hw_brightGreen
    defb hw_brightWhite    

memory_bank
    defb 0x00

previous_memory_bank
    defb 0x00