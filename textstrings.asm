copyright_text
    defb 0x18, 0x08
    defb 0xff
    defb "COPYRIGHT A.C.G."
    defb 0x00

play_game_text
    defb 0x0b, 0x0b
    defb 0xff
    defb "PRESS G FOR GAME, M FOR MENU"
    defb 0x00               ; x, y, colour, message, terminator

select_player_text 
    defb 0x08, 0x0d
    defb %00001111
    defb "USE LEFT + RIGHT TO SELECT HERO"
    defb 0x00               ; x, y, colour, message, terminator

select_marker
    defb 0x21, 0x12
    defb 0xff
    defb "<=>?"
    defb 0x00               ; x, y, colour, message, terminator    

job_titles
    defb 0x00, 0x16
    defb %00001111
    defb " GRAPHICS         CODE         SOUND"
    defb 0x00               ; x, y, colour, message, terminator        

dev_names
    defb 0x00, 0x17
    defb 0xff
    defb "STEVEN DAY     JOHN WARD"
    defb 0x00               ; x, y, colour, message, terminator        

; 15 = 0xff, 14 = 0x3f, 13 = 0xf3, 12 = 0x33, 11 = 0xcf, 10 = 0x0f, 9 = 0xc3, 8 = 0x03