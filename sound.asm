init_sound_system
	ld bc, sound_bank_config
	out (c), c    

    ld hl, Newsong_Start
    xor a
    call PLY_AKG_Init

    ld hl, SoundEffects
    call PLY_AKG_InitSoundEffects
    ret

service_sound_system
	ld bc, sound_bank_config
	out (c), c

	call PLY_AKG_Play	

	ld bc, item_bank_config
	out (c), c	
	ret    

play_sfx                            ; a = sound effect number
	ld bc, sound_bank_config
	out (c), c

    ld bc, 0x0001                   ; full volume, both channels
    call PLY_AKG_PlaySoundEffect

	ld bc, item_bank_config         ; default page back in
	out (c), c
    ret

sound_collect       equ 1
sound_menu          equ 5