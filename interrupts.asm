	; Interrupt routine from here
	; http://norecess.cpcscene.net/using-interrupts.html

interrupt_notReady		equ -2
interrupt_firstValue	equ -1

install_interrupts
	di
	ld hl, interrupt_callback
	ld (0x39), hl
	ei
	ret

interrupt_callback
	ld (interrupt_previous_stack), sp
	ld sp, interrupt_stack_start

	push af
	push bc
	push hl
	push de
	push ix
	push iy

	ld b, 0xf5
	in a, (c)
	rrca
	jr nc, skipInitFirst
	ld a, interrupt_firstValue
	ld (interrupt_index), a

skipInitFirst
	ld a, (interrupt_index)
	cp interrupt_notReady
	jp z, skipInterrupt

	inc a
	cp 6
	jp nz, no_interrupt_reset
	xor a

no_interrupt_reset
	ld (interrupt_index), a

	add a, a
	ld c, a
	ld b, 0
	ld hl, (current_interrupts)
	add hl, bc

	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld (interrupt_call + 1), hl

interrupt_call
	call 0						; modified in line above to have correct address

skipInterrupt
	pop iy
	pop ix
	pop de
	pop hl
	pop bc
	pop af

	ld sp, (interrupt_previous_stack)
	ei

	ret

interrupt_previous_stack
	dw 0

interrupt_stack
	defs 256
interrupt_stack_start

interrupt_index
	db interrupt_notReady

current_interrupts
	dw 0

menu_interrupts
	dw interrupt_switch_screens_and_clear
	dw interrupt_menu_keyboard					; read keys, update position of characters
	dw interrupt_update_character_select		; fast draw them
	dw interrupt_set_mode0
	dw interrupt_set_mode1_delayed	
	dw interrupt_empty	

game_interrupts
	dw interrupt_switch_screens_and_update
	dw interrupt_keyboard	
	dw interrupt_sprites
	dw interrupt_sprites
	dw interrupt_sprites
	dw interrupt_sprites

falling_interrupts
	dw interrupt_switch_screens
	dw interrupt_fall
	dw interrupt_empty
	dw interrupt_empty
	dw interrupt_empty
	dw interrupt_empty

end_interrupts
	dw interrupt_switch_screens
	dw interrupt_empty
	dw interrupt_empty
	dw interrupt_empty
	dw interrupt_empty
	dw interrupt_keyboard	

interrupt_empty
	ret

interrupt_fall
	ld d, 0x4e
	call background_on

	call do_tunnels

	call background_off

	ld a, (still_falling)
	and a
	ret nz

end_fall
    call clear_room
   	ld a, (hidden_screen_base_address)
    xor 0x40
    call clear_room2	

    call draw_room

    ld hl, game_interrupts
    ld (current_interrupts), hl	

	ld a, interrupt_notReady
	ld (interrupt_index), a
	ret

interrupt_sprites
	ld d, 0x4e
	call background_on

sprite_loop1
	ld a, (hidden_screen_base_address)
	ld h, a
	ld l, 0
	ld de, door_portrait

	ld b, 22

sprite_loop2
	push hl

	ld a, (de)
	xor (hl)
	ld (hl), a
	inc hl
	inc de
	ld a, (de)
	xor (hl)
	ld (hl), a
	inc hl
	inc de
	ld a, (de)
	xor (hl)
	ld (hl), a
	inc hl
	inc de
	ld a, (de)
	xor (hl)
	ld (hl), a
	inc de

	pop hl
	call scr_next_line

	djnz sprite_loop2

	call background_off
	ret

interrupt_switch_screens
	call switch_screens
	ret

interrupt_switch_screens_and_clear
	call switch_screens
	call interrupt_set_mode1
	call interrupt_clear_character_select
	ret

interrupt_set_mode1
	ld bc, 0x7f00 + 128 + 4 + 8 + 1		; change screen mode
	out (c), c

	call set_logo_pens
	ret	

interrupt_set_mode1_delayed
	ld b, 180
delay_mode1
	nop
	djnz delay_mode1

	ld bc, 0x7f00 + 128 + 4 + 8 + 1		; change screen mode
	out (c), c

	ld hl, logo_pens2
	call set_logo_pens2
	ret		

interrupt_set_mode0
	ld bc, 0x7f00 + 128 + 4 + 8 + 0		; change screen mode
	out (c), c

	ld hl, pens
	call set_logo_pens2
	ret

interrupt_switch_screens_and_update
	call switch_screens
	call interrupt_set_mode0
	call interrupt_update_game
	call interrupt_check_doors	
	ret

interrupt_update_chicken
	call update_chicken
	ret

interrupt_menu_keyboard
	ld d, 0x56
	call background_on

	call read_keys
	call poll_master_keys

	call update_menu

	call background_off	
	ret

interrupt_keyboard
	ld d, 0x56
	call background_on

	call read_keys
	call poll_master_keys

	call interrupt_move_player

	call background_off	
	ret

interrupt_check_doors
	ld d, 0x45
	call background_on

	ld bc, room_bank_config
	out (c), c

	call check_doors

	ld bc, item_bank_config
	out (c), c

    ld a, (room_changed)
	and a
    jp z, skip_room_1

    call clear_room 
    call draw_room

	ld a, interrupt_notReady
	ld (interrupt_index), a
	ret	

skip_room_1
	call background_off
	ret	 		

interrupt_move_player
	ld d, 0x5f
	call background_on

	call move_player

	call background_off
	ret

interrupt_update_game
	ld d, 0x55
	call background_on

; switch to sprite bank
	ld bc, sprite_bank_config
	out (c), c

	call erase_player
    call draw_player

; switch back to tile bank
	ld bc, item_bank_config
	out (c), c	

	call background_off
	ret

interrupt_clear_character_select
	ld d, 0x55
	call background_on

	call clear_character_selects

	call background_off
	ret

interrupt_update_character_select
	ld d, 0x55
	call background_on

; switch to sprite bank
	ld bc, sprite_bank_config
	out (c), c

	call update_character_selects

; switch back to tile bank
	ld bc, item_bank_config
	out (c), c	

	call background_off
    ret

background_on
    ld a, (show_vsync)
	cp 1
	ret z

	call set_border
    ret

background_off
	ld d, hw_black
	call set_border
	ret
