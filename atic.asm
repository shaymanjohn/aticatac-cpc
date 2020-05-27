include "includes.asm"

start
    xor a
    call scr_set_mode    

    call set_pens_off
    call wait_vsync

    di
    ld sp, 0x7fff

    ld d, hw_black
    call set_border                ; border to black

    call set_screen_properties
    call setup_game_data

    call install_interrupts

    jp $                            ; spin here, interrupts will handle flow

setup_game_data
    call make_scr_table
    ld hl, scr_addr_table_c0
    ld (scr_addr_table), hl

; switch to sprite bank
	ld bc, 0x7fc4
	out (c), c    

; rotate mode 0 sprites a pixel to the left
    ld ix, player_kd_0_0
    ld de, player_kd_0_1
    ld bc, 0x04d8                   ; 4 bytes wide, 18 x 3 high 
    call rotate_gfx                 ; (& ignore mask)

; and then generate a new mask for them.
    ld hl, player_kd_0_1
    ld bc, 0x04d8
    call gen_mask

; switch back to tile bank
	ld bc, 0x7fc0
	out (c), c    

    ld a, mode_game
    call switch_mode    

    ret

switch_mode
    ld b, a

    ld l, a
    ld h, 0
    add hl, hl
    ld de, mode_table
    add hl, de
    
    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a
    
    ld (current_interrupts), hl

	ld a, interrupt_notReady
	ld (interrupt_index), a

    ld a, b
    cp mode_menu
    jp z, select_menu

    cp mode_game
    jp z, select_game

    cp mode_end
    jp z, select_end

    ret

select_menu
    call wait_vsync
    call set_pens_off

    call clear_screen

    call set_pens
    ret

select_game
    call wait_vsync
    call set_pens_off

    call clear_screen

    xor a    
    ld (room_number), a
    ld (player_frame), a
    ld (player_orientation), a
    ld (game_over), a
    ld (panel_drawn), a

    inc a
    ld (room_changed), a

    ld a, 0x2c
    ld (player_x), a

    ld a, 0x57
    ld (player_y), a

    ld a, player_is_going_right
    ld (player_orientation), a

    ld a, 3
    ld (num_lives), a

    ld a, max_energy
    ld (energy), a

    call draw_panel
    call set_pens
    ret

select_end
    ret

clear_screen
    ld hl, 0xc000
    ld de, 0xc001
    ld bc, 0x3fff
    ld (hl), 0
    ldir

    ld hl, 0x8000
    ld de, 0x8001
    ld bc, 0x3fff
    ld (hl), 0
    ldir

    ret

mode_table
    defw menu_interrupts
    defw game_interrupts

code_end

; save "gamecode.bin",code_start,code_end-code_start

; BANK 4
org 0x4000                  ; banked
start_item_gfx
include "data/items.asm"
include "graphics/item_gfx.asm"
end_item_gfx

start_panel_data
include "graphics/panel_data.asm"
end_panel_data

; save "items.bin",start_item_gfx,end_panel_data-start_item_gfx

; BANK 5
org 0x4000                  ; banked
start_player_gfx
include "graphics/player_knight_gfx_masked.asm"
end_player_gfx

; save "sprites.bin",start_player_gfx,end_player_gfx-start_player_gfx
