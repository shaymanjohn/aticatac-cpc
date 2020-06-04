org 0x4000                ; "rooms.bin" = room_bank
include "data/rooms.asm"
include "data/item_list.asm"
include "data/items_per_room.asm"
include "data/item_pointers.asm"

org 0x4000                  ; "sprites.bin" = sprite_bank
include "graphics/player_knight_gfx_masked.asm"

org 0x4000                  ; "items.bin" = item_bank
include "data/items.asm"
include "graphics/item_gfx.asm"
