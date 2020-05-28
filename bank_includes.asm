; save "gamecode.bin",code_start,code_end-code_start

org 0x4000                  ; "sprites.bin" = sprite_bank
start_player_gfx
include "graphics/player_knight_gfx_masked.asm"
end_player_gfx

; BANK 4
org 0x4000                  ; "items.bin" = item_bank
start_item_gfx
include "data/items.asm"
include "graphics/item_gfx.asm"
end_item_gfx

start_panel_data
include "graphics/panel_data.asm"
end_panel_data

; save "items.bin",start_item_gfx,end_panel_data-start_item_gfx

; BANK 5
; org 0x4000                  ; "sprites.bin" = sprite_bank
; start_player_gfx
; include "graphics/player_knight_gfx_masked.asm"
; end_player_gfx

; save "sprites.bin",start_player_gfx,end_player_gfx-start_player_gfx

; org 0x4000                ; "rooms.bin" = room_bank
; start_room_data
; include "data/rooms.asm"
; include "data/item_list.asm"
; include "data/items_per_room.asm"
; include "data/item_pointers.asm"
; end_room_data