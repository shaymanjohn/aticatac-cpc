	; Interrupt routine from here
	; http://norecess.cpcscene.net/using-interrupts.html

interrupt_notReady		equ -2
interrupt_firstValue	equ -1

install_interrupts
	di
	ld hl, interrupt_callback
	ld (&39), hl
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

	ld b, &f5
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

game_interrupts
	dw interrupt_switch_screens
	dw interrupt_empty
	dw interrupt_keyboard
	dw interrupt_check_doors
	dw interrupt_move_player
	dw interrupt_update_game

menu_interrupts
	dw interrupt_empty
	dw interrupt_empty
	dw interrupt_keyboard
	dw interrupt_empty
	dw interrupt_empty
	dw interrupt_empty

interrupt_empty
	ret

interrupt_switch_screens
	call switch_screens
	ret

interrupt_update_chicken
	ld a, (energy)
	and a
	ret z
	dec a
	ld (energy), a

	ld b, a
	ld a, max_energy
	sub b
	sra a
	sra a
	sra a
	sra a
	and a
	ret z
	ld hl, carcass + 1
	ld (hl), a

    ld ix, carcass_item
    call draw_item
	ret

interrupt_keyboard
	ld d, 0x56
	call background_on

	call read_keys
	call poll_master_keys

	call background_off
	ret

interrupt_check_doors
	ld d, 0x45
	call background_on

	; ld bc, 0x7f00 + 128 + 4 + 8 + 1
	; out (c), c	

	call check_doors

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

	call erase_player
    call draw_player

	call background_off
	ret

interrupt_erase_player
	call erase_player
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

poll_master_keys
    ld a, (keyboard_state + 4)          ; m for menu
    bit 6, a
    jr z, show_menu

    ld a, (keyboard_state + 6)			; g for game
    bit 4, a
    jr z, show_game

    ld a, (keyboard_state + 6)          ; v for timing bars
    bit 7, a
    jr z, toggle_sync_bars

	ld a, (keyboard_state + 5)			; n for next screen
	bit 6, a
	jr z, show_next_screen

	ld a, (keyboard_state + 6)
	bit 6, a
	jr z, show_previous_screen

    ret

toggle_sync_bars
    ld a, (show_vsync)
    xor 1
    ld (show_vsync), a
	ret

show_menu
    ld a, mode_menu
    call switch_mode
    ret

show_game
    ld a, mode_game
    call switch_mode
    ret

show_next_screen
	ld hl, room_number
	inc (hl)
	jr room_change

show_previous_screen
	ld a, (room_number)
	and a
	ret z

	dec a
	ld (room_number), a

room_change
	ld a, 1
	ld (room_changed), a
	ret	