copyright_text
    defb 0x10, 0x08 * 8
    defb 0xff
    defb "COPYRIGHT A.C.G."
    defb 0x00

play_game_text
    defb 0x0d, 0x0d * 8
    defb 0xff
    defb "PRESS FIRE TO START"
    defb 0x00               ; x, y, colour, message, terminator

select_player_text 
    defb 0x01, 0x0b * 8
    defb %00001111
    defb "USE LEFT + RIGHT TO SELECT HERO"
    defb 0x00               ; x, y, colour, message, terminator

select_marker
    defb 0x1c, 0x12 * 8
    defb 0xff
    defb "<=>?"
    defb 0x00               ; x, y, colour, message, terminator    

graphics_title
    defb 0x02, 0x16 * 8
    defb %00001111
    defb "GRAPHICS"
    defb 0x00               ; x, y, colour, message, terminator        

code_title
    defb 0x1c, 0x16 * 8
    defb %00001111
    defb "CODE"
    defb 0x00               ; x, y, colour, message, terminator            

sound_title
    defb 0x31, 0x16 * 8
    defb %00001111
    defb "SOUND"
    defb 0x00               ; x, y, colour, message, terminator            

dev_day
    defb 0x00, 0x17 * 8
    defb 0xff
    defb "STEVEN DAY"
    defb 0x00               ; x, y, colour, message, terminator        

dev_ward
    defb 0x17, 0x17 * 8
    defb 0xff
    defb "JOHN WARD"
    defb 0x00               ; x, y, colour, message, terminator        

dev_cross
    defb 0x2c, 0x17 * 8
    defb 0xff
    defb "SAUL CROSS"
    defb 0x00               ; x, y, colour, message, terminator

time_text
    defb 0x32, 0x41
    defb 0xff
game_time    
    defb "000:00"
    defb 0x00

seconds_text
    defb 0x3c, 0x41
    defb 0xff
seconds_time    
    defb "0"
    defb 0x00

score_text
    defb 0x32, 0x51
    defb 0xff
    defb "000000"
    defb 0x00

game_over_text
    defb 0x0d, 0x30
    defb 0xf3
    defb "GAME OVER"
    defb 0x00

game_over_time_text
    defb 0x0d, 0x40
    defb 0x03
    defb "TIME    xxxxxx"
    defb 0x00

game_over_score_text
    defb 0x0d, 0x50
    defb 0x03
    defb "SCORE   xxxxxx"
    defb 0x00        

game_over_percentage_text
    defb 0x0d, 0x60
    defb 0x03
    defb "PERCENT 00"
    defb 0x00

game_over_congrats_text
    defb 0x0d, 0x20
    defb 0xf3
    defb "CONGRATULATIONT"
    defb 0x00

game_over_escaped_text
    defb 0x0d, 0x30
    defb 0xf3
    defb "YOU HAVE ESCAPED"
    defb 0x00


; 15 = 0xff, 14 = 0x3f, 13 = 0xf3, 12 = 0x33, 11 = 0xcf, 10 = 0x0f, 9 = 0xc3, 8 = 0x03