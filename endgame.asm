init_endgame
    ld a, 50               ; wait 1 second on this screen before accepting any key press to continue.
    ld (end_key_delay), a

    SELECT_BANK room_bank_config

    ld hl, font_data_mode0
    ld (font_type), hl    

    ld hl, room_bank_RoomInfo                       ; count how many rooms visited to show percentage
    ld b, (end_room_bank - room_bank_RoomInfo) / 2
    xor a
room_count_loop
    bit 7, (hl)
    jr z, not_visited
    inc a

not_visited     
    inc hl
    inc hl
    djnz room_count_loop

    ld ix, game_over_percentage_text

    cp end_room
    jr nz, not_got_em_all

    ld (ix + 11), "1"
    ld (ix + 12), "0"
    ld (ix + 13), "0"
    call show_text
    jr show_rest_of_end

not_got_em_all
    ld (ix + 13), " "
    ld l, a
    ld h, 0
    ld bc, percentage_lookup - 1
    add hl, bc
    ld a, (hl)                              ; look up percentage
    ld b, a
    and 0xf0
    srl a
    srl a
    srl a
    srl a
    add "0"
    ld (ix + 11), a

    ld a, b
    and 0x0f
    add "0"
    ld (ix + 12), a

show_rest_of_end
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
    ld bc, 6
    ldir

    ld ix, game_over_time_text
    call show_text

    ld hl, score_text + 3
    ld de, game_over_score_text + 11
    ld bc, 6
    ldir

    ld ix, game_over_score_text
    call show_text

    ld ix, game_over_percentage_text
    jp show_text

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

visited_count
    defb 0x00
visited_bcd
    defb 0x00