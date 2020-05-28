item_bank_items
	defw unused,   cavedoor,  normaldoor, bigdoor
	defw unused,   unused,    unused,     unused
	defw reddoor,  greendoor, bluedoor,   yellowdoor
	defw redcave,  greencave, bluecave,   yellowcave
	defw clock,    picture1,  table,      chicken
	defw carcass,  antlers,   trophy,     bookcase
	defw trapdoor, trapdoor2, barrel,     rug
	defw acgshield,shield,    knight,     unused
	defw shutdoor, opendoor,  shutcave,   opencave
	defw acgdoor,  picture2,  skeleton,   barrels

unused

cavedoor ; 0x01
    defb 8, 24                              ; width (bytes), height (portrait size)
    defw 8 * 24
    defw cavedoor_portrait
    defw cavedoor_landscape

normaldoor  ; 0x02
    defb 8, 24                              ; width (bytes), height (portrait size)
    defw 8 * 24                             ;normaldoor_landscape - normaldoor_portrait
    defw door_portrait
    defw door_landscape

bigdoor
    defb 12, 32                              ; width (bytes), height (portrait size)
    defw 12 * 32
    defw door_big_portrait
    defw door_big_landscape

reddoor
    defb 8, 24                              ; width (bytes), height (portrait size)
    defw 8 * 24
    defw door_red_portrait
    defw door_red_landscape

greendoor
    defb 8, 24                              ; width (bytes), height (portrait size)
    defw 8 * 24
    defw door_green_portrait
    defw door_green_landscape

bluedoor
    defb 8, 24                              ; width (bytes), height (portrait size)
    defw 8 * 24
    defw door_blue_portrait
    defw door_blue_landscape

yellowdoor
    defb 8, 24                              ; width (bytes), height (portrait size)
    defw 8 * 24
    defw door_yellow_portrait
    defw door_yellow_landscape

redcave
    defb 8, 24                              ; width (bytes), height (portrait size)
    defw 8 * 24
    defw cavedoor_red_portrait
    defw cavedoor_red_landscape

greencave
    defb 8, 24                              ; width (bytes), height (portrait size)
    defw 8 * 24
    defw cavedoor_green_portrait
    defw cavedoor_green_landscape

bluecave
    defb 8, 24                              ; width (bytes), height (portrait size)
    defw 8 * 24
    defw cavedoor_blue_portrait
    defw cavedoor_blue_landscape

yellowcave
    defb 8, 24                              ; width (bytes), height (portrait size)
    defw 8 * 24
    defw cavedoor_yellow_portrait
    defw cavedoor_yellow_landscape

clock
    defb 8, 32                              ; width (bytes), height (portrait size)
    defw 8 * 32
    defw clock_portrait
    defw clock_landscape

picture1    ; was 8, 24
    defb 8, 20                              ; width (bytes), height (portrait size)
    defw 8 * 20
    defw picture1_portrait
    defw picture1_landscape

table
    defb 8, 22                              ; width (bytes), height (portrait size)
    defw 8 * 22
    defw table_portrait
    defw table_portrait

chicken
    defb 12, 30                              ; width (bytes), height (portrait size)
    defw 12 * 30
    defw chicken_full
    defw chicken_full

carcass
    defb 12, 30                              ; width (bytes), height (portrait size)
    defw 12 * 30
    defw chicken_empty
    defw chicken_empty

antlers
    defb 8, 16                              ; width (bytes), height (portrait size)
    defw 8 * 16
    defw antlers_portrait
    defw antlers_landscape

trophy
    defb 4, 16                              ; width (bytes), height (portrait size)
    defw 4 * 16
    defw trophy_portrait
    defw trophy_landscape

bookcase
    defb 10, 32                              ; width (bytes), height (portrait size)
    defw 10 * 32
    defw bookcase_portrait
    defw bookcase_landscape

trapdoor
    defb 8, 32                              ; width (bytes), height (portrait size)
    defw 8 * 32
    defw trapdoor_open_portrait
    defw trapdoor_open_portrait
    
trapdoor2
    defb 8, 32                              ; width (bytes), height (portrait size)
    defw 8 * 32
    defw trapdoor_closed_portrait
    defw trapdoor_closed_portrait

barrel
    defb 8, 32                              ; width (bytes), height (portrait size)
    defw 8 * 32
    defw barrel_portrait
    defw barrel_landscape

rug
    defb 12, 40                              ; width (bytes), height (portrait size)
    defw 12 * 40
    defw rug_portrait
    defw rug_portrait

acgshield
    defb 4, 16                              ; width (bytes), height (portrait size)
    defw 4 * 16
    defw acg_shield_portrait
    defw acg_shield_landscape

shield
    defb 4, 16                              ; width (bytes), height (portrait size)
    defw 4 * 16
    defw shield_portrait
    defw shield_landscape

knight
    defb 4, 32                              ; width (bytes), height (portrait size)
    defw 4 * 32
    defw knight_portrait
    defw knight_landscape

shutdoor
    defb 8, 24                              ; width (bytes), height (portrait size)
    defw 8 * 24
    defw door_closed_portrait
    defw door_closed_landscape

opendoor
    defb 8, 24                              ; width (bytes), height (portrait size)
    defw 8 * 24
    defw door_portrait
    defw door_landscape

shutcave
    defb 8, 24                              ; width (bytes), height (portrait size)
    defw 8 * 24
    defw cavedoor_closed_portrait
    defw cavedoor_closed_landscape

opencave
    defb 8, 24                              ; width (bytes), height (portrait size)
    defw 8 * 24
    defw cavedoor_portrait
    defw cavedoor_landscape

acgdoor
    defb 16, 40                              ; width (bytes), height (portrait size)
    defw 16 * 40
    defw unused
    defw acg_door

picture2
    defb 8, 16                              ; width (bytes), height (portrait size)
    defw 8 * 16
    defw picture2_portrait
    defw picture2_landscape

skeleton
    defb 10, 40                              ; width (bytes), height (portrait size)
    defw 10 * 40
    defw skeleton_portrait
    defw skeleton_landscape

barrels
    defb 10, 28                              ; width (bytes), height (portrait size)
    defw 10 * 28
    defw barrels_portrait
    defw barrels_portrait
