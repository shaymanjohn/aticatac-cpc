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
	dw game_interrupts

game_interrupts
	dw interrupt_empty
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

interrupt_keyboard
	ld d, 0x56
	call background_on

	call read_keys

	call background_off
	ret

interrupt_check_doors
	ld d, 0x45
	call background_on

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
