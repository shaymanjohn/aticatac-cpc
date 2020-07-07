do_sprite       ; ix points to sprite
    call erase_sprite
    call move_sprite
    call draw_sprite

    ret

erase_sprite
    ld a, (hidden_screen_base_address)
    cp 0xc0
    jp nz, sprite_erase_with_80

    ld hl, (ix + 8)
    jp erase_sprite_start

sprite_erase_with_80
    ld hl, (ix + 10)
    
erase_sprite_start
    ld a, h
    or l
    ret z                       ; stop here if not yet set

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

    ld a, (hidden_screen_base_address)
    cp 0xc0
    jp nz, sprite_save_with_80
    ld (ix + 8), hl 
    jp draw_sprite_entry2

sprite_save_with_80
    ld (ix + 10), hl

draw_sprite_entry2
    ld de, (ix + 5)
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
    
    inc de

    dec l
    dec l
    dec l

    call scr_next_line
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
    ret

; sprite struct
; x, y
; w, h
; frame
; sprite gfx base
; state: unformed, forming, alive, dying, dead
; draw 1 scr address
; draw 2 scr address

sprite1
    defb 0x20, 0x20
    defb 0x05, boss_height
    defb 0x00
    defw boss_dracula_0_0
    defb 0x02
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

sprite3
    defb 0x40, 0x50
    defb 0x05, boss_height
    defb 0x00
    defw boss_dracula_0_0
    defb 0x02
    defw 0x0000
    defw 0x0000
sprite_end

old_room_sprites
    defs sprite_end - sprite1

