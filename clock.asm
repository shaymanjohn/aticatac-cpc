update_clock
    ld a, (screen_transition_in_progress)
    and a
    ret nz

    ld a, 1
    ld (tell_time), a
    ld (second_only), a

    ld a, (game_time + 5)
    inc a
    ld (game_time + 5), a
    cp "9" + 1
    ret nz

    xor a
    ld (second_only), a

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
    ld a, game_finished
    ld (game_over), a
    ret

show_clock
    xor a
    ld (tell_time), a

    ld ix, time_text
    ld a, (second_only)
    and a
    jp z, show_text

    ld a, (game_time + 5)
    ld (seconds_time), a
    ld ix, seconds_text
    jp show_text

reset_clock
    ld a, "0"
    ld (game_time), a
    ld (game_time + 1), a
    ld (game_time + 2), a

    ld (game_time + 4), a
    ld (game_time + 5), a

    ld a, 1
    ld (tell_time), a
    ret

tell_time
    defb 0x00
second_only
    defb 0x00