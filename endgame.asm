init_endgame
    ld a, 50               ; wait 1 second on this screen before accepting any key press to continue.
    ld (end_key_delay), a

    SELECT_BANK room_bank_config
    ld hl, font_data_mode0
    ld (font_type), hl

    ld a, (game_over)
    cp game_completed                       ; did player finish the game?
    jp nz, not_completed_end

    ld ix, game_over_congrats_text          ; if so, show congrats message
    call show_text

    ld ix, game_over_escaped_text
    call show_text
    jr no_game_over_message                 ; but not game over message

not_completed_end
    ld ix, game_over_text
    call show_text

no_game_over_message                        ; always show these stats though...
    ld hl, game_time
    ld de, game_over_time_text + 11
    ld b, 6
    call copy_text

    ld ix, game_over_time_text
    call show_text

    ld hl, score_text + 3
    ld de, game_over_score_text + 11
    ld b, 6
    call copy_text    

    ld ix, game_over_score_text
    call show_text

    ld ix, game_over_percentage_text
    jp show_text

copy_text
    ld a, (hl)
    ld (de), a
    inc hl
    inc de
    djnz copy_text
    ret

end_tasks
    ld a, (end_key_delay)
    and a
    jr z, wait_for_keypress
    dec a
    ld (end_key_delay), a    
    ret

wait_for_keypress
    ld a, (keys_pressed)
    and a
    ret z

    ld b, state_menu
    jp switch_game_state

end_key_delay
    defb 0x00