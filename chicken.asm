update_chicken
	ld a, (hunger_index)
	inc a
	cp max_hunger
	jp z, update_carcass

	ld (hunger_index), a
	; set death flag here

update_carcass
	srl a
	srl a
	srl a					; divide by 8

	and a
	ret z

	ld hl, carcass + 1
	ld (hl), a

    ; draw carcass here

    ret

hunger_c0
	defb 0x00
hunger_80
	defb 0x00	