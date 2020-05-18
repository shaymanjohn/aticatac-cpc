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
	ld hl, interrupts
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
	defs 512
interrupt_stack_start

interrupt_index
	db interrupt_notReady

interrupts
	dw interrupt_0
	dw interrupt_1
	dw interrupt_2
	dw interrupt_3
	dw interrupt_4
	dw interrupt_5

interrupt_0
	ret

interrupt_1
	ret

interrupt_2
	ret

interrupt_3
	ld a, 0x45
	call background_on
	call check_doors
	call background_off
	ret	 		

interrupt_4
	ld a, 0x56
	call background_on

	call read_keys

	ld a, 0x5f
	call background_on

	call move_player	
	call background_off
	ret

interrupt_5
    ld a, (room_number)
    ld hl, old_room_number
    cp (hl)
    jp z, do_player

    call clear_room 
    call draw_room

	ld a, interrupt_notReady
	ld (interrupt_index), a

	ret

do_player	
	ld a, 0x55
	call background_on
	call update_player
	call background_off
	ret

background_on
	ld b, a
	ld a, (show_vsync)
	cp 1
	ret z

	ld d, b
	call set_border
	ret

background_off
	ld d, 0x54
	call set_border
	ret
