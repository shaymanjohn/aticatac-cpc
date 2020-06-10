play_game_text
    defb 0x00, 0x02, 0xff
    defb "PRESS G FOR GAME"
    defb 0x00               ; x, y, colour, message, terminator

cursors_text
    defb 0x00, 0x04, 0xff
    defb "CURSOR KEYS TO MOVE"
    defb 0x00               ; x, y, colour, message, terminator

menu_text
    defb 0x00, 0x06, 0xf3
    defb "PRESS M TO RETURN TO MENU"
    defb 0x00               ; x, y, colour, message, terminator

interrupts_text
    defb 0x00, 0x08, 0x33
    defb "PRESS V TO TOGGLE INTERRUPT TIMINGS"
    defb 0x00               ; x, y, colour, message, terminator

next_screen_text
    defb 0x00, 0x0a, 0xcf
    defb "PRESS N FOR NEXT SCREEN"
    defb 0x00               ; x, y, colour, message, terminator

previous_screen_text
    defb 0x00, 0x0c, 0xcf
    defb "PRESS B FOR PREVIOUS SCREEN"
    defb 0x00               ; x, y, colour, message, terminator

knight_text
    defb 0x1a, 0x13, 0xf3
    defb "KNIGHT"
    defb 0x00               ; x, y, colour, message, terminator

wizard_text
    defb 0x1a, 0x13, 0xf3
    defb "WIZARD"
    defb 0x00               ; x, y, colour, message, terminator

serf_text
    defb 0x1a, 0x13, 0xf3
    defb " SERF "
    defb 0x00               ; x, y, colour, message, terminator

blank_text    
    defb 0x1a, 0x13, 0xf3
    defb "      "
    defb 0x00               ; x, y, colour, message, terminator

; 15 = 0xff, 14 = 0x3f, 13 = 0xf3, 12 = 0x33, 11 = 0xcf, 10 = 0x0f, 9 = 0xc3, 8 = 0x03