update_clock
    ld a, 2
    ld (tell_time), a

    ld a, (game_time + 5)
    inc a
    ld (game_time + 5), a
    cp "9" + 1
    ret nz

    ld a, "0"
    ld (game_time + 5), a

    ld a, (game_time + 4)
    inc a
    ld (game_time + 4), a
    cp "6"
    ret nz

    ld a, "0"
    ld (game_time + 4), a

    ld a, (game_time + 2)
    inc a
    ld (game_time + 2), a    
    cp "9" + 1
    ret nz

    ld a, "0"
    ld (game_time + 2), a

    ld a, (game_time + 1)
    inc a
    ld (game_time + 1), a    
    cp "9" + 1
    ret nz

    ld a, "0"
    ld (game_time + 1), a

    ld a, (game_time)
    inc a
    ld (game_time), a    
    cp "9" + 1
    ret nz

; times up - finish game
    ld b, state_menu
    call switch_game_state
    ret

show_clock
    ld a, (tell_time)
    and a
    ret z

    dec a
    ld (tell_time), a

    ld ix, time_text
    call show_text_fast    
    ret

reset_clock
    ld a, "0"
    ld (game_time), a
    ld (game_time + 1), a
    ld (game_time + 2), a

    ld (game_time + 4), a
    ld (game_time + 5), a

    ld a, 2
    ld (tell_time), a    
    ret

tell_time
    defb 0x00