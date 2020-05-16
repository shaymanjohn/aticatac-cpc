; firmware functions used
scr_set_mode		equ &bc0e
scr_set_ink			equ &bc32
km_test_key			equ &bb1e
mc_wait_flyback	    equ &bd19
scr_set_border	    equ &bc38

rotation_top        equ 0x00
rotation_table      equ 0x04
rotation_trapdoor   equ 0x02
rotation_bottom     equ 0x80
rotation_right      equ 0x60
rotation_right2     equ 0x40
rotation_left       equ 0xe0

max_items           equ 30
player_width        equ 4       ; bytes
player_height       equ 18      ; rows
num_rooms           equ (RoomTypes - RoomInfo) / 2
player_horiz_speed  equ 1
player_vert_speed   equ 2

