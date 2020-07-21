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

    SELECT_BANK baddie_bank_config

    ld de, shifted_baddies    
    ld ix, start_of_baddies

    ld b, 5                 ; large bat
    ld c, 18 * 4
    call rotate_gfx

    ld b, 4                 ; small bat
    ld c, 18 * 2
    call rotate_gfx

    ld b, 4                 ; birth
    ld c, 16 * 4
    call rotate_gfx

    ld b, 4                 ; devil
    ld c, 23 * 3
    call rotate_gfx

    ld b, 4                 ; dracula
    ld c, 23 * 3
    call rotate_gfx

    ld b, 4                 ; frankenstein
    ld c, 24 * 3
    call rotate_gfx

    ld b, 5                 ; hunchback
    ld c, 21 * 3
    call rotate_gfx

    ld b, 5                 ; mummy
    ld c, 23 * 3
    call rotate_gfx

    ld b, 4                 ; bouncy
    ld c, 11 * 2
    call rotate_gfx

    ld b, 4                 ; death
    ld c, 16 * 4
    call rotate_gfx

    ld b, 5                 ; ghost1
    ld c, 16 * 4
    call rotate_gfx

    ld b, 5                 ; ghost2
    ld c, 20 * 2
    call rotate_gfx

    ld b, 5                 ; monk
    ld c, 20 * 4
    call rotate_gfx

    ld b, 5                 ; octopus
    ld c, 14 * 2
    call rotate_gfx

    ld b, 5                 ; pumpkin
    ld c, 19 * 2
    call rotate_gfx

    ld b, 5                 ; slime
    ld c, 11 * 2
    call rotate_gfx

    ld b, 5                 ; spark
    ld c, 18 * 2
    call rotate_gfx

    ld b, 5                 ; witch
    ld c, 21 * 4
    call rotate_gfx    

    SELECT_BANK item_bank_config

; Some default values
    ld a, character_mid
    ld (player_select_x), a
    ld (characters_target), a

    ld b, state_menu
    call switch_game_state    

    ret
