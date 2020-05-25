include "utils/start.asm"
include "utils/constants.asm"
include "utils/screen_size.asm"
include "utils/utils.asm"

include "lines.asm"
include "draw_room.asm"
include "draw_items.asm"
include "panel.asm"
include "player.asm"
include "interrupts.asm"
include "keyboard.asm"

start_room_data
include "data/rooms.asm"
include "data/item_list.asm"
include "data/items_per_room.asm"
include "data/item_pointers.asm"
end_room_data

start_item_gfx
include "data/items.asm"
include "graphics/item_gfx.asm"
end_item_gfx

start_panel_data
include "graphics/panel_data.asm"
end_panel_data

start_player_gfx
include "graphics/player_knight_gfx_masked.asm"
end_player_gfx

