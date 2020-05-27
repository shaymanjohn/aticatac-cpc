org 0x400

code_start

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
