init_sound_system
    SELECT_BANK sound_bank_config

    ld hl, Newsong_Start
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

play_sfx                            ; a = sound effect number
    ld e, a
    SELECT_BANK sound_bank_config
    ld a, e

    ld bc, 0x0001                   ; full volume, both channels
    call PLY_AKG_PlaySoundEffect

    SELECT_BANK item_bank_config
    rets
