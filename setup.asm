setup_game_data
    call make_scr_table

; Create copy of hero sprites, rotated a mode 0 pixel to the left

    SELECT_BANK sprite_bank_config

    ld ix, sprite_bank_player_kd_0_0
    ld de, sprite_bank_player_kd_0_1
    ld b, player_width
    ld c, knight_height * 12
    call rotate_gfx

    ld ix, sprite_bank_player_wd_0_0
    ld de, sprite_bank_player_wd_0_1
    ld b, player_width
    ld c, wizard_height * 12
    call rotate_gfx

    ld ix, sprite_bank_player_sd_0_0
    ld de, sprite_bank_player_sd_0_1
    ld b, player_width
    ld c, serf_height * 12
    call rotate_gfx

; Initialise Arkos player
    call init_sound_system

    SELECT_BANK item_bank_config

; Some default values
    ld a, character_mid
    ld (player_select_x), a
    ld (characters_target), a

    ld b, state_menu
    call switch_game_state    

    ret
