;
; Based on example code here:
; http://www.cpcwiki.eu/index.php/Programming:An_example_loader
;
org 0x8000
	ld hl, (amsdos_reserved)	; store the drive number the loader was run from
	ld a, (hl)
	ld (drive + 1), a

	ld c, 0xff					; disable all roms
	ld hl, start				; execution address for program
	call mc_start_program		; start it

start
	call kl_rom_walk			; enable all roms

drive
	ld a, 0						; This will restore the drive number to the drive the loader was run from (smc)
	ld hl, (amsdos_reserved)
	ld (hl), a

	xor a
	call scr_set_mode
	call set_to_black

;----------------------------------------	Show loading screen here (and set pens)

	ld hl, file_loading_screen
	ld de, 0x4000
	call load_block

	ld hl, 0x4000
	ld de, 0xc000
	ld a, 200

screen_copy_loop
	push af
	push de

	ld bc, 80
	ldir

	ex de, hl
	
	pop hl
	call scr_next_line
	ex de, hl

	pop af
	dec a
	jr nz, screen_copy_loop

	call set_pens

;----------------------------------------

	ld c, 0xc4					; set bank for sprites (0, 4, 2, 3)
	call set_bank

	ld hl, file_sprites			; sprites in bank 4
	ld de, 0x4000
	call load_block

;----------------------------------------

	ld c, 0xc5					; set bank for rooms (0, 5, 2, 3)
	call set_bank

	ld hl, file_room			; room data in bank 5
	ld de, 0x4000
	call load_block

;----------------------------------------

	ld c, 0xc0					; set bank for items (0, 1, 2, 3)
	call set_bank

	ld hl, file_items			; item data in bank 1
	ld de, 0x4000
	call load_block

;----------------------------------------

	ld hl, file_code			; main game code in bank 0
	ld de, 0x400
	call load_block

;----------------------------------------

	jp 0x400					; start game

;----------------------------------------	

load_block
	push de						; save destination

	call calc_name_length		; get filename length in b
	ld de, open_buffer			; file open needs a 2k buffer
	call cas_in_open

	pop hl						; destination now in hl
	call cas_in_direct

	call cas_in_close
	ret

calc_name_length				; return name length in b
	ld b, 0
	push hl

count_loop
	ld a, (hl)
	and a
	jr z, count_done

	inc hl
	inc b
	jr count_loop

count_done
	pop hl
	ret

set_bank
	ld b, 0x7f
	out (c), c
	ret

set_to_black
	ld b, 16
	xor a

stb1
	push af
	push bc
	ld bc, 0
	call scr_set_ink			; set colour
	pop bc
	pop af
	inc a						; increment pen index
	djnz stb1

	ld bc, 0					; black
	call scr_set_border			; set border colour
	ret

set_pens
    ld hl, pens
    ld e, 16                    ; 16 pens for mode 0
    xor a					    ; initial pen index    
set_pens_loop
    ld d, (hl)		            ; d = ink for pen
    inc hl
	ld b, d
	ld c, d
	push hl
	push af
	push de
    call scr_set_ink
	pop de
	pop af
	pop hl
    inc a					    ; increment pen index
    dec e
    jr nz, set_pens_loop
    ret

scr_next_line   	; hl = current screen address
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

file_loading_screen
	defb "LOADING", 0

file_sprites
	defb "SPRITES.BIN", 0

file_room
	defb "ROOMS.BIN", 0

file_items
	defb "ITEMS.BIN", 0

file_code
	defb "GAMECODE.BIN", 0

pens
    defb 0
    defb 1
    defb 2
    defb 9
    defb 11
    defb 18
    defb 3
    defb 4
    defb 23
    defb 6
    defb 7
    defb 8
    defb 15
    defb 17
    defb 24
	defb 26

open_buffer
	defs 2048

scr_set_mode		equ 0xbc0e
scr_set_border		equ 0xbc38
scr_set_ink			equ 0xbc32
cas_in_open			equ 0xbc77
cas_in_direct		equ 0xbc83
cas_in_close		equ 0xbc7a
mc_start_program	equ 0xbd16
kl_rom_walk			equ 0xbccb
amsdos_reserved		equ 0xbe7d