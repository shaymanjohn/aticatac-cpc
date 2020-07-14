do_sprite                               ; ix points to sprite
    call erase_sprite
    call move_sprite
    call draw_sprite
    ret

erase_sprite
    ld a, (hidden_screen_base_address)
    cp 0xc0
    jp nz, sprite_erase_with_80

    ld hl, (ix + 8)
    ld de, (ix + 12)
    jp erase_sprite_start

sprite_erase_with_80
    ld hl, (ix + 10)
    ld de, (ix + 14)
    
erase_sprite_start
    ld a, h
    or l
    ret z                               ; stop here if not yet set

    jp draw_sprite_entry2

draw_sprite
    ld l, (ix + 1)
    ld h, 0
    add hl, hl
    ld de, (scr_addr_table)
    add hl, de

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a

    ld a, (ix + 0)
    srl a
    ld c, a
    ld b, 0
    add hl, bc

    ld de, (ix + 5)    

    ld a, (hidden_screen_base_address)
    cp 0xc0
    jp nz, sprite_save_with_80
    ld (ix + 8), hl
    ld (ix + 12), de
    jp draw_sprite_entry2

sprite_save_with_80
    ld (ix + 10), hl
    ld (ix + 14), de    

draw_sprite_entry2
    ld b, (ix + 3)

sprite_draw_loop
    ld a, (de)
    xor (hl)
    ld (hl), a
    inc l
    inc de

    ld a, (de)
    xor (hl)    
    ld (hl), a
    inc l
    inc de

    ld a, (de)
    xor (hl)    
    ld (hl), a
    inc l
    inc de

    ld a, (de)
    xor (hl)    
    ld (hl), a
    inc de
    
    ; inc de

    dec l
    dec l
    dec l

    GET_NEXT_SCR_LINE
    djnz sprite_draw_loop

    ret

move_sprite
    ld a, (ix + 1)
    inc a
    ld (ix + 1), a
    cp 170
    ret nz
    xor a
    ld (ix + 1), a
    ret

reset_sprites
    ld hl, 0
    ld (sprite1 + 8), hl
    ld (sprite1 + 10), hl

    ld (sprite2 + 8), hl
    ld (sprite2 + 10), hl

    ld (sprite3 + 8), hl
    ld (sprite3 + 10), hl

    ld a, 0x20
    ld (sprite1 + 1), a
    ld a, 0x38
    ld (sprite2 + 1), a
    ld a, 0x50
    ld (sprite3 + 1), a    
    ret

; sprite struct
; x, y
; w, h
; frame
; sprite gfx base
; state: unformed, forming, alive, dying, dead
; draw 1 scr address
; draw 2 scr address
; draw 1 gfx address
; draw 2 gfx address

sprite1
    defb 0x20, 0x20
    defb 0x05, boss_height
    defb 0x00
    defw boss_dracula_0_0
    defb 0x02
    defw 0x0000
    defw 0x0000
    defw 0x0000
    defw 0x0000   

sprite2
    defb 0x30, 0x38
    defb 0x05, boss_height
    defb 0x00
    defw boss_dracula_0_0
    defb 0x02
    defw 0x0000
    defw 0x0000
    defw 0x0000
    defw 0x0000

sprite3
    defb 0x40, 0x50
    defb 0x05, boss_height
    defb 0x00
    defw boss_dracula_0_0
    defb 0x02
    defw 0x0000
    defw 0x0000
    defw 0x0000
    defw 0x0000
sprite_end

boss_devil
    defw boss_devil_0_0     ; first frame
    defb 0x03               ; number of frames
    defb 0x00               ; faces direction of motion
    defb 0x04               ; width
    defb 23                 ; height

boss_dracula
    defw boss_dracula_0_0   ; first frame
    defb 0x03               ; number of frames
    defb 0x00               ; faces direction of motion
    defb 0x04               ; width
    defb 23                 ; height

boss_frankie
    defw boss_dracula_0_0   ; first frame
    defb 0x03               ; number of frames
    defb 0x00               ; faces direction of motion
    defb 0x04               ; width
    defb 24                 ; height

boss_hunchback
    defw boss_hunchback_0_0 ; first frame
    defb 0x03               ; number of frames
    defb 0x00               ; faces direction of motion
    defb 0x05               ; width
    defb 21                 ; height

boss_mummy
    defw mummy_0_0          ; first frame
    defb 0x03               ; number of frames
    defb 0x00               ; faces direction of motion
    defb 0x05               ; width
    defb 23                 ; height    

sprite_birth
    defw birth_0            ; first frame
    defb 0x04               ; number of frames
    defb 0x00               ; faces direction of motion
    defb 0x04               ; width
    defb 16                 ; height

sprite_death
    defw death_0            ; first frame
    defb 0x04               ; number of frames
    defb 0x00               ; faces direction of motion
    defb 0x04               ; width
    defb 16                 ; height

sprite_info
    defw spr_large_bat, spr_small_bat
    defw spr_bouncy,    spr_ghost1
    defw spr_ghost2,    spr_monk
    defw spr_octopus
    defw spr_pumpkin,   spr_slime
    defw spr_spark,     spr_witch

spr_large_bat
    defw bat_large_0_0      ; first frame
    defb 0x02               ; number of frames
    defb 0x01               ; faces direction of motion
    defb 0x05               ; width
    defb 18                 ; height

spr_small_bat
    defw bat_small_0_0      ; first frame
    defb 0x02               ; number of frames
    defb 0x00               ; faces direction of motion
    defb 0x04               ; width
    defb 18                 ; height

spr_bouncy
    defw bouncy_0_0         ; first frame
    defb 0x02               ; number of frames
    defb 0x00               ; faces direction of motion
    defb 0x04               ; width
    defb 11                 ; height

spr_ghost1
    defw ghost1_0_0         ; first frame
    defb 0x02               ; number of frames
    defb 0x00               ; faces direction of motion
    defb 0x05               ; width
    defb 16                 ; height

spr_ghost2
    defw ghost2_0_0         ; first frame
    defb 0x02               ; number of frames
    defb 0x00               ; faces direction of motion
    defb 0x05               ; width
    defb 20                 ; height

spr_monk
    defw monk_0_0           ; first frame
    defb 0x02               ; number of frames
    defb 0x01               ; faces direction of motion
    defb 0x05               ; width
    defb 20                 ; height

spr_octopus
    defw octopus_0_0        ; first frame
    defb 0x02               ; number of frames
    defb 0x00               ; faces direction of motion
    defb 0x05               ; width
    defb 14                 ; height

spr_pumpkin
    defw pumpkin_0_0        ; first frame
    defb 0x02               ; number of frames
    defb 0x00               ; faces direction of motion
    defb 0x05               ; width
    defb 19                 ; height

spr_slime
    defw slime_0_0          ; first frame
    defb 0x02               ; number of frames
    defb 0x00               ; faces direction of motion
    defb 0x05               ; width
    defb 11                 ; height

spr_spark
    defw pumpkin_0_0        ; first frame
    defb 0x02               ; number of frames
    defb 0x00               ; faces direction of motion
    defb 0x05               ; width
    defb 18                 ; height

spr_witch
    defw witch_0_0          ; first frame
    defb 0x02               ; number of frames
    defb 0x01               ; faces direction of motion
    defb 0x05               ; width
    defb 21                 ; height

old_room_sprites
    defs sprite_end - sprite1

