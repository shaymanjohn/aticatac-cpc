	; Interrupt routine from here
	; http://norecess.cpcscene.net/using-interrupts.html
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

interrupt_empty
	ret

interrupt_switch_screens
	ld a, (frame_ready)
	and a
	ret z
	jp switch_screens

interrupt_switch_screens_and_mode1
	ld bc, 0x7f00 + 128 + 4 + 8 + 1		; mode 1
	out (c), c

	ld a, (frame_ready)
	and a
	ret z

ssm1
	call set_logo_pens
	jp switch_screens

interrupt_set_mode1_delayed
	ld b, 180
delay_mode1
	nop
	djnz delay_mode1

	ld bc, 0x7f00 + 128 + 4 + 8 + 1		; mode 1
	out (c), c

	ld hl, logo_pens2
	jp set_logo_pens2

interrupt_set_mode0_delayed
	ld b, 240
delay_mode0
	nop
	nop
	nop
	djnz delay_mode0

	call set_pens

	ld bc, 0x7f00 + 128 + 4 + 8 + 0		; mode 0
	out (c), c

	ld hl, pens
	jp set_logo_pens2

interrupt_keyboard
	BORDER_ON hw_brightMagenta

	call read_keys

	BORDER_OFF
	ret

interrupt_clock
	ld a, (heartbeat)
	cp 45
	jp z, update_clock
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
	dw interrupt_switch_screens_and_mode1
	dw interrupt_keyboard
	dw interrupt_empty
	dw interrupt_set_mode0_delayed
	dw interrupt_set_mode1_delayed
	dw service_sound_system

game_interrupts
	dw interrupt_switch_screens
	dw interrupt_keyboard
	dw interrupt_clock
	dw interrupt_empty
	dw interrupt_empty
	dw service_sound_system	

falling_interrupts
	dw interrupt_switch_screens
	dw interrupt_clock	
	dw interrupt_empty
	dw interrupt_empty
	dw interrupt_empty
	dw service_sound_system

end_interrupts
	dw interrupt_switch_screens
	dw interrupt_keyboard
	dw interrupt_empty
	dw interrupt_empty
	dw interrupt_empty
	dw service_sound_system

heartbeat
	defb 0x00

pen_delay
	defb 0x00

