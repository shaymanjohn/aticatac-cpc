update_chicken
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

    ; draw carcass here

    ret