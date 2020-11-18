init_sound_system                   ; hl = music to play
    SELECT_BANK sound_bank_config

    ld a, d
    call PLY_AKG_Init

    ld hl, SoundEffects
    jp PLY_AKG_InitSoundEffects

service_sound_system
    ld a, sound_bank_config
    ld b, 0x7f
    out (c), a
	jp PLY_AKG_Play

play_sfx                            ; e = sound effect number
    ld a, (memory_bank)
    push af

    SELECT_BANK sound_bank_config

    ld a, e
    ld bc, 0x0001                   ; full volume, both channels
    call PLY_AKG_PlaySoundEffect

    pop af
    SELECT_BANK a
    ret
