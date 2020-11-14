;
; Based on example code here:
; http://www.cpcwiki.eu/index.php/Programming:An_example_loader
;
org 0x8000
loader_start

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

loader_screen_copy_loop
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
	jr nz, loader_screen_copy_loop

	call loader_set_pens

;----------------------------------------

	ld c, 0xc4					; set bank for sprites (0, 4, 2, 3)
	call loader_set_bank

	ld hl, file_heroes			; sprites in bank 4
	ld de, 0x4000
	call load_block

;----------------------------------------

	ld c, 0xc7					; set bank for baddies (0, 7, 2, 3)
	call loader_set_bank

	ld hl, file_baddies			; baddies in bank 7
	ld de, 0x4000
	call load_block

;----------------------------------------

	ld c, 0xc5					; set bank for rooms (0, 5, 2, 3)
	call loader_set_bank

	ld hl, file_room			; room data in bank 5
	ld de, 0x4000
	call load_block

;----------------------------------------

	ld c, 0xc6					; set bank for sound (0, 6, 2, 3)
	call loader_set_bank

	ld hl, file_sounds			; sound data in bank 6
	ld de, 0x4000
	call load_block	

;----------------------------------------

	ld c, 0xc0					; set bank for items (0, 1, 2, 3)
	call loader_set_bank

	ld hl, file_items			; item data in bank 1
	ld de, 0x4000
	call load_block

;----------------------------------------

	ld hl, file_code			; main game code in bank 0
	ld de, 0x100
	call load_block

;----------------------------------------

	jp 0x100					; start game

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

loader_set_bank
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

loader_set_pens
    ld hl, pens
    ld e, 16                    ; 16 pens for mode 0
    xor a					    ; initial pen index    
loader_set_pens_loop
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
    jr nz, loader_set_pens_loop
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
	defb "LOADING.BIN", 0

file_heroes
	defb "HEROES.BIN", 0

file_baddies
	defb "BADDIES.BIN", 0

file_room
	defb "ROOMS.BIN", 0

file_items
	defb "ITEMS.BIN", 0

file_code
	defb "GAMECODE.BIN", 0

file_sounds
	defb "SOUNDS.BIN", 0

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
    defb 16
    defb 24
	defb 26

open_buffer
	defs 2048

loader_end

scr_set_mode		equ 0xbc0e
scr_set_border		equ 0xbc38
scr_set_ink			equ 0xbc32
cas_in_open			equ 0xbc77
cas_in_direct		equ 0xbc83
cas_in_close		equ 0xbc7a
mc_start_program	equ 0xbd16
kl_rom_walk			equ 0xbccb
amsdos_reserved		equ 0xbe7d

save "atic.bin", 0x8000, loader_end-loader_start, DSK, "aticatac.dsk"