init_sound_system                   ; hl = music to play
    SELECT_BANK sound_bank_config

    xor a
    call PLY_AKG_Init

    ld hl, SoundEffects
    call PLY_AKG_InitSoundEffects
    ret

service_sound_system
	ld a, (memory_bank)
    push af

    ld a, sound_bank_config
    ld b, 0x7f
    out (c), a

	call PLY_AKG_Play

    pop af
    ld b, 0x7f                      ; switch back to original memory bank
    out (c), a
	ret    

play_sfx                            ; e = sound effect number
    ld a, (memory_bank)
    push af

    ld a, sound_bank_config
    ld b, 0x7f
    out (c), a

    ld a, e
    ld bc, 0x0001                   ; full volume, both channels
    call PLY_AKG_PlaySoundEffect

    pop af
    ld b, 0x7f                      ; switch back to original memory bank
    out (c), a
    ret
