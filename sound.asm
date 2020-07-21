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

    SELECT_BANK sound_bank_config

	call PLY_AKG_Play

    pop af

    ld b, 0x7f
    ld c, a
    out (c), c
    ld (memory_bank), a
	ret    

play_sfx                            ; e = sound effect number
    ld a, (memory_bank)
    ld iyh, a                       ; save current memory bank 

    SELECT_BANK sound_bank_config

    ld a, e
    ld bc, 0x0001                   ; full volume, both channels
    call PLY_AKG_PlaySoundEffect

    SELECT_BANK iyh                 ; switch back to correct memory bank
    ret
