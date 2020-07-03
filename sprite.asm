do_sprite       ; ix points to sprite
    SELECT_BANK sprite_bank_config

    call erase_sprite
    call move_sprite
    call draw_sprite

    SELECT_BANK item_bank_config
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

    ld b, (ix + 3)
    ld c, 0
sprite_erase_loop
    ld (hl), c
    inc l

    ld (hl), c
    inc l

    ld (hl), c
    inc l

    ld (hl), c

    dec l
    dec l
    dec l
    call scr_next_line
    djnz sprite_erase_loop

    ret

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

    ld (ix + 8), hl 
    ld (ix + 10), hl

draw_sprite_entry2
    ld de, (ix + 5)
    ld b, (ix + 3)

sprite_draw_loop
    ld a, (de)
    ld (hl), a
    inc l
    inc de

    ld a, (de)
    ld (hl), a
    inc l
    inc de

    ld a, (de)
    ld (hl), a
    inc l
    inc de

    ld a, (de)
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
    ret    

; sprite struct
; x, y
; w, h
; frame
; sprite gfx base
; state: unformed, forming, alive, dying, dead
; draw 1 scr address, draw 2 scr address
; draw 1 gfx address, draw 2 gfx address

sprite1
    defb 0x20, 0x20
    defb 0x05, boss_height
    defb 0x00
    defw boss_dracula_0_0
    defb 0x02
    defw 0x0000, 0x0000
    defw 0x0000, 0x0000

sprite2
    defb 0x40, 0x20
    defb 0x05, boss_height
    defb 0x00
    defw boss_dracula_0_0
    defb 0x02
    defw 0x0000, 0x0000
    defw 0x0000, 0x0000

sprite3
    defb 0x40, 0x30
    defb 0x05, boss_height
    defb 0x00
    defw boss_dracula_0_0
    defb 0x02
    defw 0x0000, 0x0000
    defw 0x0000, 0x0000

boss
    defb 0x20, 0x30
    defb 0x05, boss_height
    defb 0x00
    defw boss_dracula_0_0
    defb 0x02
    defw 0x0000, 0x0000
    defw 0x0000, 0x0000
