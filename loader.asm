;
; Based on example code here:
; http://www.cpcwiki.eu/index.php/Programming:An_example_loader
;
org 0x8000
	ld hl, (0xbe7d)				; store the drive number the loader was run from
	ld a, (hl)
	ld (drive + 1), a

	ld c, 0xff					; disable all roms
	ld hl, start				; execution address for program
	call mc_start_program		; start it

start
	call kl_rom_walk			; enable all roms

drive
	ld a, 0						; This will restore the drive number to the drive the loader was run from (smc)
	ld hl, (0xbe7d)
	ld (hl), a

	xor a
	call scr_set_mode
	call set_to_black

	ld c, 0xc4					; set bank for sprites (0, 4, 2, 3)
	call set_bank
	ld hl, file_sprites
	ld b, file_sprites_end - file_sprites
	ld de, 0x4000
	call load_block	

	; ld c, 0xc5					; set bank for rooms (0, 5, 2, 3)
	; call set_bank
	; ld hl, file_room
	; ld b, file_room_end - file_room
	; ld de, 0x4000
	; call load_block	

	ld c, 0xc0					; set bank for items (0, 1, 2, 3)
	call set_bank
	ld hl, file_items
	ld b, file_items_end - file_items
	ld de, 0x4000
	call load_block	

	ld hl, file_code
	ld b, file_code_end - file_code
	ld de, 0x400
	call load_block	

	jp 0x400

set_bank
	ld b, 0x7f
	out (c), c
	ret

load_block
	push de

	ld de, 0xc000
	call cas_in_open

	pop hl
	call cas_in_direct

	call cas_in_close
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

file_sprites
	defb "SPRITES.BIN"
file_sprites_end

file_room
	defb "ROOMS.BIN"
file_room_end

file_items
	defb "ITEMS.BIN"
file_items_end

file_code
	defb "GAMECODE.BIN"
file_code_end

end_of_code

scr_set_mode		equ 0xbc0e
scr_set_border		equ 0xbc38
scr_set_ink			equ 0xbc32
cas_in_open			equ 0xbc77
cas_in_direct		equ 0xbc83
cas_in_close		equ 0xbc7a
mc_start_program	equ 0xbd16
kl_rom_walk			equ 0xbccb