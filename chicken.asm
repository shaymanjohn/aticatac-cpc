init_health
	ld a, max_health
    ld (health), a

	ld a, max_health / 4
    ld (drawn_health), a
	ret

health_decay
	ld a, (health)
	and a
	ret z
	dec a
	ld (health), a
	ret

health_down
	ld a, (health)
	and a
	ret z
	sub 8
	jr nc, hd1

	xor a

hd1
	ld (health), a
	ret

health_up
	ld a, (health)
	add 16
	cp max_health
	jr c, maximus
	ld a, max_health

maximus
	ld (health), a
	ret

update_chicken
	ld a, (health)
	srl	a
	srl a					; divide by 4

	ld b, a
	ld a, (drawn_health)
	cp b
	ret z

	jr nc, health_going_down

	inc a
	ld (drawn_health), a

	ld b, a
	ld a, 30
	sub b
	inc a
	cp 30
	ret z

	ld bc, chicken_full
	jr update_carcass

health_going_down
	dec a
	ld (drawn_health), a

	ld b, a
	ld a, 30
	sub b
	cp 30
	jr nz, not_dead_yet

	call decrease_lives

	ld a, (game_over)
	and a
	call z, make_player_disappear
	ret
	
not_dead_yet
	ld bc, chicken_empty

update_carcass				; multiply a by 12 (width of chicken) and draw 1 line only...
	ld l, a
	ld h, 0
	add hl, hl				; x2
	add hl, hl				; x4

	ld d, h
	ld e, l					; de = hl * 4

	add hl, hl				; x8
	add hl, de				; x12

	add hl, bc				; hl = address of image data for this row
	ex hl, de				; now in de

	; calculate line to draw on
	add 0x53
    ld l, a
    ld h, 0
    add hl, hl
    ld bc, (scr_addr_table)
    add hl, bc

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a

	ld c, 0x72
	ld b, 0
	add hl, bc				; hl has screen address, de has gfx address
	ex de, hl				; swapped

	push hl
	push de

repeat 12
	ldi
rend

	pop de
	pop hl
		
	ld a, d
	xor 0x40
	ld d, a
repeat 12
	ldi
rend

    ret
