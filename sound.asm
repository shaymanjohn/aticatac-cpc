init_sound_system
	ld a, sound_bank_config
	call set_memory_bank

    ld hl, Newsong_Start
    xor a
    call PLY_AKG_Init

    ld hl, SoundEffects
    call PLY_AKG_InitSoundEffects
    ret

service_sound_system
	ld a, (memory_bank)
	ld (save_memory_bank), a

	ld a, sound_bank_config
	call set_memory_bank

	call PLY_AKG_Play

    ld a, (save_memory_bank)
    call set_memory_bank
	ret    

play_sfx                            ; a = sound effect number
    ld e, a
	ld a, sound_bank_config
	call set_memory_bank
    ld a, e

    ld bc, 0x0001                   ; full volume, both channels
    call PLY_AKG_PlaySoundEffect

    ld a, item_bank_config
    jp set_memory_bank
