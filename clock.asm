update_clock
    ld a, (game_time + 5)
    inc a
    ld (game_time + 5), a
    cp ":"
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
    cp ":"
    ret nz

    ld a, "0"
    ld (game_time + 2), a

    ld a, (game_time + 1)
    inc a
    ld (game_time + 1), a    
    cp ":"
    ret nz

    ld a, "0"
    ld (game_time + 1), a

    ld a, (game_time)
    inc a
    ld (game_time), a    
    cp ":"
    ret nz

; times up - finish game
    ld b, state_menu
    call switch_game_state

    ret

reset_clock
    ld a, "0"
    ld (game_time), a
    ld (game_time + 1), a
    ld (game_time + 2), a

    ld (game_time + 4), a
    ld (game_time + 5), a
    ret