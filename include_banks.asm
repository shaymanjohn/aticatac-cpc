BANK
org 0x4000
item_bank_start
include "data/items.asm"
include "graphics/item_gfx.asm"
item_bank_end
save "items.bin", 0x4000, item_bank_end-item_bank_start, DSK, "aticatac.dsk"

BANK
org 0x4000
sprite_bank_start
include "graphics/player_sprites_gfx.asm"
include "graphics/weapon_gfx.asm"
include "data/food_data.asm"
sprite_bank_end
save "heroes.bin", 0x4000, sprite_bank_end-sprite_bank_start, DSK, "aticatac.dsk"

BANK
org 0x4000
baddie_bank_start
include "graphics/baddies_gfx.asm"
baddie_bank_end
save "baddies.bin", 0x4000, baddie_bank_end-baddie_bank_start, DSK, "aticatac.dsk"

BANK
org 0x4000
rooms_bank_start
include "data/rooms.asm"
include "data/item_list.asm"
include "data/items_per_room.asm"
include "data/item_pointers.asm"
include "graphics/menu_gfx.asm"
include "graphics/pickup_gfx.asm"
include "fonts/fontdata.asm"
include "fonts/fontdata_mode1.asm"
rooms_bank_end
save "rooms.bin", 0x4000, rooms_bank_end-rooms_bank_start, DSK, "aticatac.dsk"

BANK
org 0x4000
include "graphics/titlescreen_gfx.asm"
save "loading.bin", 0x4000, 16000, DSK, "aticatac.dsk"

BANK
org 0x4000
sound_bank_start
include "sound/Music_Empty.asm"
include "sound/atic_tunes.asm"

PLY_AKG_HARDWARE_CPC = 1
PLY_AKG_MANAGE_SOUND_EFFECTS = 1

PLY_CFG_ConfigurationIsPresent = 1
PLY_CFG_UseSpeedTracks = 1
PLY_CFG_UseEffects = 1
PLY_CFG_UseInstrumentLoopTo = 1
PLY_CFG_NoSoftNoHard = 1
PLY_CFG_SoftOnly = 1
PLY_CFG_SoftOnly_SoftwareArpeggio = 1
PLY_CFG_SoftOnly_SoftwarePitch = 1
PLY_CFG_UseEffect_Legato = 1
PLY_CFG_UseEffect_Arpeggio3Notes = 1
PLY_CFG_UseEffect_ArpeggioTable = 1
PLY_CFG_SFX_ConfigurationIsPresent = 1
PLY_CFG_SFX_SoftOnly = 1
PLY_CFG_SFX_SoftOnly_Noise = 1

SoundEffects
include "sound/Atic-Atac-CPC-SFX.asm"
include "sound/PlayerAkg.asm"
sound_bank_end
save "sounds.bin", 0x4000, sound_bank_end-sound_bank_start, DSK, "aticatac.dsk"