scr_set_mode        equ 0xbc0e

rotation_top        equ 0x00
rotation_table      equ 0x04
rotation_trapdoor   equ 0x02
rotation_bottom     equ 0x80
rotation_right      equ 0x60
rotation_right2     equ 0x40
rotation_left       equ 0xe0

max_items           equ 15      ; per room
player_width        equ 4       ; bytes
player_height       equ 18      ; rows
player_horiz_speed  equ 1
player_vert_speed   equ 2
max_energy          equ 240
num_rows            equ 192     ; same height as spectrum

; colours
hw_black            equ 0x54

; modes
state_menu           equ 0x00
state_game           equ 0x01
state_end            equ 0x02

; memory banks
sprite_bank_config  equ 0x7fc4
item_bank_config    equ 0x7fc0
room_bank_config    equ 0x7fc5

; player anim
num_player_frames       equ 16

player_is_going_down    equ 0
player_is_going_up      equ num_player_frames * 2
player_is_going_left    equ num_player_frames * 4
player_is_going_right   equ num_player_frames * 6


