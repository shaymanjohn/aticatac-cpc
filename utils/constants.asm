scr_set_mode        equ 0xbc0e

rotation_top        equ 0x00        ; portrait  %00000000
rotation_bottom     equ 0x80        ; portrait  %10000000
rotation_right      equ 0x60        ; landscape %01100000
rotation_left       equ 0xe0        ; landscape %11100000

max_doors           equ 8       ; per room
player_width        equ 5       ; bytes
player_height       equ 20      ; rows
player_horiz_speed  equ 1
player_vert_speed   equ 2
max_energy          equ 240
num_rows            equ 192     ; same height as spectrum
num_rooms           equ (end_room_bank - room_bank_RoomInfo) / 2

; game states
state_menu          equ 0x00
state_game          equ 0x01
state_falling       equ 0x02
state_end           equ 0x03
fall_time           equ 75

; memory banks
sprite_bank_config  equ 0x7fc4
item_bank_config    equ 0x7fc0
room_bank_config    equ 0x7fc5

; player anim
num_player_frames       equ 4
player_is_going_down    equ 0
player_is_going_up      equ num_player_frames * 2
player_is_going_left    equ num_player_frames * 4
player_is_going_right   equ num_player_frames * 6

; colours
hw_black            equ 0x54
hw_blue             equ 0x44
hw_brightBlue       equ 0x55
hw_green            equ 0x56
hw_cyan             equ 0x46
hw_skyBlue          equ 0x57
hw_brightGreen      equ 0x52
hw_red              equ 0x5c
hw_pastelCyan       equ 0x5b
hw_brightRed        equ 0x4c
hw_orange           equ 0x4e
hw_pink             equ 0x47
hw_brightYellow     equ 0x4a
hw_brightWhite      equ 0x4b
hw_magenta          equ 0x58
hw_brightMagenta    equ 0x4d

character_knight    equ 0x00
character_wizard    equ 0x01
character_serf      equ 0x02

item_clock          equ 0x10
item_bookcase       equ 0x17
item_barrel         equ 0x1a
item_trapdoor       equ 0x19