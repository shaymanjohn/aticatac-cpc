erase_sprite
    ld a, (hidden_screen_base_address)
    cp 0xc0
    jp nz, sprite_erase_with_80

    ld hl, (ix + spr_scrc0)

    ld de, 0
    ld (ix + spr_scrc0), de             ; don't erase again (unless redrawn)

    ld de, (ix + spr_gfxc0)
    ld b, (ix + spr_hc0)
    ld c, (ix + spr_wc0)
    jp erase_sprite_start

sprite_erase_with_80
    ld hl, (ix + spr_scr80)

    ld de, 0
    ld (ix + spr_scr80), de             ; don't erase again (unless redrawn)
    
    ld de, (ix + spr_gfx80)
    ld b, (ix + spr_h80)
    ld c, (ix + spr_w80)
    
erase_sprite_start
    ld a, h
    or l
    ret z                               ; stop here if not yet set
    
    ld a, c
    jp draw_sprite_entry3

draw_sprite
    ld a, (ix + spr_state)
    and a
    ret z                               ; don't draw if dead
    
    ld l, (ix + spr_y)
    ld h, 0
    add hl, hl
    ld de, (scr_addr_table)
    add hl, de

    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a

    ld a, (ix + spr_x)
    srl a
    ld c, a
    ld b, 0
    add hl, bc                          ; hl has screen address

    ex de, hl                           ; swap it into de for a bit...

    ld a, (ix + spr_frame)              ; calculate frame here
    srl a
    srl a
    ld l, a
    ld h, 0
    add hl, hl

    ld bc, (ix + spr_gfx)    

    ld a, (ix + spr_fdom)
    and a
    jp z, calc_frame

    ld a, (ix + spr_xinc)
    bit 7, a
    jp z, calc_frame

    ld bc, (ix + spr_alt)

calc_frame
    add hl, bc
    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a

    ld a, (ix + spr_x)          ; use pixel shifted version?
    and 0x01
    jp z, not_shifted

    ld bc, end_of_baddies - start_of_baddies
    add hl, bc

not_shifted
    ex de, hl

    ld a, (hidden_screen_base_address)
    cp 0xc0
    jp nz, sprite_save_with_80

    ld (ix + spr_scrc0), hl
    ld (ix + spr_gfxc0), de
    ld a, (ix + spr_h)
    ld (ix + spr_hc0), a
    ld a, (ix + spr_w)
    ld (ix + spr_wc0), a    
    jp draw_sprite_entry2

sprite_save_with_80
    ld (ix + spr_scr80), hl
    ld (ix + spr_gfx80), de
    ld a, (ix + spr_h)
    ld (ix + spr_h80), a
    ld a, (ix + spr_w)
    ld (ix + spr_w80), a

draw_sprite_entry2
    ld b, (ix + spr_h)                  ; b has height
    ld a, (ix + spr_w)

draw_sprite_entry3    
    cp 5
    jp z, sprite_draw_loop_5

sprite_draw_loop_4
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

    dec l
    dec l
    dec l

    GET_NEXT_SCR_LINE
    djnz sprite_draw_loop_4
    ret

sprite_draw_loop_5
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
    inc l
    inc de

    ld a, (de)
    xor (hl)    
    ld (hl), a
    inc de

    dec l
    dec l
    dec l
    dec l

    GET_NEXT_SCR_LINE
    djnz sprite_draw_loop_5
    ret

update_sprite
    ld a, (ix + spr_state)

    cp state_dead
    jp z, is_dead

    cp state_arriving
    jp z, is_arriving

    cp state_dying
    jp z, is_dying

; sprite is active...    

; is this a boss?
    ld a, (ix + spr_boss)
    and a
    jp nz, update_boss

    ld a, (ix + spr_counter)
    dec a
    ld (ix + spr_counter), a
    and a
    jp z, change_direction

    ld a, (heartbeat)
    and 0x01
    ret z

    ld a, (ix + spr_x)
    add (ix + spr_xinc)
    ld (ix + spr_x), a
    ld b, a

    ld a, (min_x)
    ld d, a
    cp b
    jp nc, bounce_sprite_x

    ld a, (max_x)
    ld d, a
    cp b
    jp nc, check_bounce_y

bounce_sprite_x
    ld a, (ix + spr_xinc)
    neg
    ld (ix + spr_xinc), a

    ld (ix + spr_x), d
    
check_bounce_y
    ld a, (ix + spr_y)
    add (ix + spr_yinc)
    ld (ix + spr_y), a
    ld b, a

    ld a, (min_y)
    ld d, a
    cp b
    jp nc, bounce_sprite_y

    ld a, (max_y)
    ld d, a
    cp b
    jp nc, anim_sprite

bounce_sprite_y
    ld a, (ix + spr_yinc)
    neg
    ld (ix + spr_yinc), a

    ld (ix + spr_y), d

anim_sprite
    ANIMATE_SPRITE
    ret  

change_direction
    jp random_sprite_action

is_dead
    ld a, (ix + spr_boss)
    and a
    ret nz
    
    ld a, (ix + spr_counter)
    dec a
    ld (ix + spr_counter), a
    and a
    ret nz

    ld a, state_arriving
    ld (ix + spr_state), a

    ld a, arrival_time
    ld (ix + spr_counter), a

    ld iy, sprite_birth

    ld a, (min_x)               ; calculate random x position inside room
    ld e, a
    ld a, (max_x)
    sub 6                       ; not in rhs wall
    sub e
    ld c, a

    RANDOM_IN_A

    cp c
    jp c, random_y_pos
    srl a

    cp c
    jp c, random_y_pos
    srl a

    cp c
    jp c, random_y_pos
    srl a

    cp c
    jp c, random_y_pos
    srl a    

random_y_pos
    add e
    ld (ix + spr_x), a

    ld a, (min_y)               ; calculate random y position inside room
    ld e, a
    ld a, (max_y)
    sub 24                      ; not in bottom wall
    sub e
    ld c, a

    RANDOM_IN_A

    cp c
    jp c, random_pos_done
    srl a

    cp c
    jp c, random_pos_done
    srl a

    cp c
    jp c, random_pos_done
    srl a

random_pos_done
    add e
    ld (ix + spr_y), a

init_sprite    
    xor a
    ld (ix + spr_frame), a    

    ld a, (iy + 0)              ; width
    ld (ix + spr_w), a

    ld a, (iy + 1)              ; height
    ld (ix + spr_h), a

    ld a, (iy + 4)              ; faces direction of motion
    ld (ix + spr_fdom), a

    ld de, (iy + 2)             ; alternative sprite data if fdom
    ld (ix + spr_alt), de

    ld bc, 5
    add iy, bc
    ld a, iyl
    ld (ix + spr_gfx), a
    ld a, iyh
    ld (ix + spr_gfx + 1), a
    
    ret

is_arriving
    ld a, (ix + spr_counter)
    dec a
    ld (ix + spr_counter), a
    and a
    jp z, become_active

    ANIMATE_SPRITE
    ret

become_active
    ld a, state_active
    ld (ix + spr_state), a

    RANDOM_IN_A
    and 0x0f                        ; random sprite number between 0-15
    ld l, a
    ld h, 0
    add hl, hl
    ld de, sprite_info
    add hl, de
    ld a, (hl)
    inc hl
    ld b, (hl)
    ld iyh, b
    ld iyl, a

    ; ld iy, spr_witch
    ; ld iy, spr_monk
    ; ld iy, spr_large_bat
    ; ld iy, spr_ghost1
    ; ld iy, boss_mummy

    call random_sprite_action
    jp init_sprite

random_sprite_action
    ld a, r
    and 0x3f
    add 20
    ld (ix + spr_counter), a

    RANDOM_IN_A     ; a is random number between 0 and 7
    and 0x07

    ld hl, sprite_direction_table
    add a    
    ld c, a
    ld b, 0
    add hl, bc
    ld d, (hl)
    inc hl
    ld e, (hl)

    ld (ix + spr_xinc), d
    ld (ix + spr_yinc), e
    ret

kill_sprite
    ld a, state_dying
    ld (ix + spr_state), a

    ld a, dying_time
    ld (ix + spr_counter), a

    ld iy, sprite_death
    call init_sprite
    ret

is_dying
    ld a, (ix + spr_counter)
    dec a
    ld (ix + spr_counter), a
    and a
    jp z, become_dead
    ANIMATE_SPRITE
    ret

become_dead
    ld a, state_dead
    ld (ix + spr_state), a

    RANDOM_IN_A
    and 0x0f
    add 10
    ld (ix + spr_counter), a
    ret

reset_sprites
    ld hl, 0
    ld a, state_dead

    ld (boss + spr_state), a
    ld (boss + spr_scrc0), hl
    ld (boss + spr_scr80), hl

    ld (sprite1 + spr_state), a
    ld (sprite1 + spr_scrc0), hl
    ld (sprite1 + spr_scr80), hl

    ld (sprite2 + spr_state), a
    ld (sprite2 + spr_scrc0), hl
    ld (sprite2 + spr_scr80), hl

    ld (sprite3 + spr_state), a
    ld (sprite3 + spr_scrc0), hl
    ld (sprite3 + spr_scr80), hl

    RANDOM_IN_A
    and 0x3f
    add 5
    ld (sprite1 + spr_counter), a

    RANDOM_IN_A
    and 0x3f
    add 5
    ld (sprite2 + spr_counter), a

    RANDOM_IN_A
    and 0x3f
    add 5
    ld (sprite3 + spr_counter), a

; going to a boss room?
    call init_boss

    ret

; sprite struct
;
spr_x       equ 0   ; x
spr_y       equ 1   ; y
spr_xinc    equ 2   ; x inc
spr_yinc    equ 3   ; y inc
spr_counter equ 4   ; counter
spr_w       equ 5   ; width
spr_h       equ 6   ; height
spr_frame   equ 7   ; frame
spr_gfx     equ 8   ; sprite gfx base
spr_state   equ 10  ; state: unformed, forming, alive, dying, dead
spr_scrc0   equ 11  ; save screen c0
spr_scr80   equ 13  ; save screen 80
spr_gfxc0   equ 15  ; save gfx c0
spr_gfx80   equ 17  ; save gfx 80
spr_alt     equ 19  ; alternative sprite data when facing left
spr_fdom    equ 21  ; faces direction of motion
spr_wc0     equ 22  ; width of c0 frame
spr_w80     equ 23  ; width of 80 frame
spr_hc0     equ 24  ; height of c0 frame
spr_h80     equ 25  ; height of 80 frame
spr_boss    equ 26

boss
    defb 0x00, 0x00             ; x, y
    defb 0x00, 0x00             ; x increment, y increment
    defb 0x00                   ; counter
    defb 0x00, 0x00             ; width, height
    defb 0x00                   ; frame number * 4
    defw 0x0000                 ; base sprite gfx pointer
    defb 0x00                   ; state
    defw 0x0000                 ; save screen c0
    defw 0x0000                 ; save screen 80
    defw 0x0000                 ; save gfx c0
    defw 0x0000                 ; save gfx 80
    defw 0x0000                 ; alt sprite data
    defb 0x00                   ; faces direction of motion
    defb 0x00                   ; width c0
    defb 0x00                   ; width 80
    defb 0x00                   ; height c0
    defb 0x00                   ; height c0
    defb 0x01                   ; boss flag

sprite1
    defb 0x00, 0x00             ; x, y
    defb 0x00, 0x00             ; x increment, y increment
    defb 0x00                   ; counter
    defb 0x00, 0x00             ; width, height
    defb 0x00                   ; frame number * 4
    defw 0x0000                 ; base sprite gfx pointer
    defb 0x00                   ; state
    defw 0x0000                 ; save screen c0
    defw 0x0000                 ; save screen 80
    defw 0x0000                 ; save gfx c0
    defw 0x0000                 ; save gfx 80
    defw 0x0000                 ; alt sprite data
    defb 0x00                   ; faces direction of motion
    defb 0x00                   ; width c0
    defb 0x00                   ; width 80
    defb 0x00                   ; height c0
    defb 0x00                   ; height c0
    defb 0x00                   ; boss flag

sprite2
    defb 0x00, 0x00             ; x, y
    defb 0x00, 0x00             ; x increment, y increment
    defb 0x00                   ; counter
    defb 0x00, 0x00             ; width, height
    defb 0x00                   ; frame number * 4
    defw 0x00                   ; base sprite gfx pointer
    defb 0x00                   ; state
    defw 0x0000                 ; save screen c0
    defw 0x0000                 ; save screen 80
    defw 0x0000                 ; save gfx c0
    defw 0x0000                 ; save gfx 80
    defw 0x0000                 ; alt sprite data
    defb 0x00                   ; faces direction of motion
    defb 0x00                   ; width c0
    defb 0x00                   ; width 80
    defb 0x00                   ; height c0
    defb 0x00                   ; height c0
    defb 0x00                   ; boss flag    

sprite3
    defb 0x00, 0x00             ; x, y
    defb 0x00, 0x00             ; x increment, y increment
    defb 0x00                   ; counter
    defb 0x00, 0x00             ; width, height
    defb 0x00                   ; frame number * 4
    defw 0x00                   ; base sprite gfx pointer
    defb 0x00                   ; state
    defw 0x0000                 ; save screen c0
    defw 0x0000                 ; save screen 80
    defw 0x0000                 ; save gfx c0
    defw 0x0000                 ; save gfx 80
    defw 0x0000                 ; alt sprite data
    defb 0x00                   ; faces direction of motion
    defb 0x00                   ; width c0
    defb 0x00                   ; width 80
    defb 0x00                   ; height c0
    defb 0x00                   ; height c0
    defb 0x00                   ; boss flag    
sprite_end

boss_devil
    defb 0x04               ; width
    defb 23                 ; height
    defw 0                  ; alt
    defb 0x00               ; faces direction of motion
    defw boss_devil_0_0, boss_devil_1_0
    defw boss_devil_2_0, boss_devil_0_0
    defb 0                  ; killed?
    defb 44, 84             ; start x and y

boss_dracula
    defb 0x04               ; width
    defb 23                 ; height
    defw 0                  ; alt
    defb 0x00               ; faces direction of motion    
    defw boss_dracula_0_0, boss_dracula_1_0
    defw boss_dracula_2_0, boss_dracula_0_0
    defb 0                  ; killed?
    defb 44, 84             ; start x and y    

boss_frankie
    defb 0x04               ; width
    defb 24                 ; height
    defw 0                  ; alt
    defb 0x00               ; faces direction of motion    
    defw boss_frankie_0_0, boss_frankie_1_0
    defw boss_frankie_2_0, boss_frankie_0_0
    defb 0                  ; killed?
    defb 44, 84             ; start x and y    

boss_hunchback
    defb 0x05               ; width
    defb 21                 ; height
    defw 0                  ; alt
    defb 0x00               ; faces direction of motion    
    defw boss_hunchback_0_0, boss_hunchback_1_0
    defw boss_hunchback_2_0, boss_hunchback_0_0
    defb 0                  ; killed?
    defb 44, 32             ; start x and y    

boss_mummy
    defb 0x05               ; width
    defb 23                 ; height
    defw 0                  ; alt
    defb 0x00               ; faces direction of motion    
    defw boss_mummy_0_0, boss_mummy_1_0   ; 5, 7
    defw boss_mummy_2_0, boss_mummy_0_0   ; 9, 11
    defb 0                  ; killed?
    defb 60, 50             ; start x and y    

sprite_birth
    defb 0x04               ; width
    defb 16                 ; height
    defw 0                  ; alt
    defb 0x00               ; faces direction of motion    
    defw birth_0, birth_1
    defw birth_2, birth_3
    defb 0                  ; killed?
    defb 0, 0               ; start x and y    

sprite_death
    defb 0x04               ; width
    defb 16                 ; height
    defw 0                  ; alt
    defb 0x00               ; faces direction of motion
    defw death_0, death_1
    defw death_2, death_3
    defb 0                  ; killed?
    defb 0, 0               ; start x and y    

sprite_info                 ; some repeats to make random selection easier...
    defw spr_large_bat, spr_small_bat
    defw spr_bouncy,    spr_ghost1
    defw spr_ghost2,    spr_monk
    defw spr_octopus,   spr_pumpkin
    defw spr_slime,     spr_spark
    defw spr_witch,     spr_ghost1
    defw spr_octopus,   spr_pumpkin
    defw spr_ghost2,    spr_monk

spr_large_bat
    defb 0x05               ; width
    defb 18                 ; height
    defw spr_large_bat_alt  ; alt    
    defb 0x01               ; faces direction of motion
    defw bat_large_0_0, bat_large_1_0
    defw bat_large_0_0, bat_large_1_0

spr_large_bat_alt
    defw bat_large_2_0, bat_large_3_0
    defw bat_large_2_0, bat_large_3_0

spr_small_bat
    defb 0x04               ; width
    defb 18                 ; height
    defw 0                  ; alt
    defb 0x00               ; faces direction of motion
    defw bat_small_0_0, bat_small_1_0
    defw bat_small_0_0, bat_small_1_0

spr_bouncy
    defb 0x04               ; width
    defb 11                 ; height
    defw 0                  ; alt
    defb 0x00               ; faces direction of motion
    defw bouncy_0_0, bouncy_1_0
    defw bouncy_0_0, bouncy_1_0

spr_ghost1
    defb 0x05               ; width
    defb 16                 ; height
    defw spr_ghost1_alt     ; alt
    defb 0x01               ; faces direction of motion
    defw ghost1_0_0, ghost1_1_0
    defw ghost1_0_0, ghost1_1_0
spr_ghost1_alt
    defw ghost1_2_0, ghost1_3_0
    defw ghost1_2_0, ghost1_3_0

spr_ghost2
    defb 0x05               ; width
    defb 20                 ; height
    defw 0                  ; alt
    defb 0x00               ; faces direction of motion
    defw ghost2_0_0, ghost2_1_0
    defw ghost2_0_0, ghost2_1_0

spr_monk
    defb 0x05               ; width
    defb 20                 ; height
    defw spr_monk_alt       ; alt
    defb 0x01               ; faces direction of motion    
    defw monk_0_0, monk_1_0
    defw monk_0_0, monk_1_0

spr_monk_alt
    defw monk_2_0, monk_3_0
    defw monk_2_0, monk_3_0

spr_octopus
    defb 0x05               ; width
    defb 14                 ; height
    defw 0                  ; alt
    defb 0x00               ; faces direction of motion
    defw octopus_0_0, octopus_1_0
    defw octopus_0_0, octopus_1_0

spr_pumpkin
    defb 0x05               ; width
    defb 19                 ; height
    defw 0                  ; alt
    defb 0x00               ; faces direction of motion
    defw pumpkin_0_0, pumpkin_1_0
    defw pumpkin_0_0, pumpkin_1_0

spr_slime
    defb 0x05               ; width
    defb 11                 ; height
    defw 0                  ; alt
    defb 0x00               ; faces direction of motion
    defw slime_0_0, slime_1_0
    defw slime_0_0, slime_1_0

spr_spark
    defb 0x05               ; width
    defb 18                 ; height
    defw 0                  ; alt
    defb 0x00               ; faces direction of motion    
    defw spark_0_0, spark_1_0
    defw spark_0_0, spark_1_0

spr_witch
    defb 0x05               ; width
    defb 21                 ; height
    defw spr_witch_alt      ; alt
    defb 0x01               ; faces direction of motion
    defw witch_0_0, witch_1_0
    defw witch_0_0, witch_1_0

spr_witch_alt
    defw witch_2_0, witch_3_0
    defw witch_2_0, witch_3_0    

old_room_sprites
    defs sprite_end - sprite1

sprite_direction_table
    defb  0, -1
    defb  1, -1
    defb  1,  0
    defb  1,  1
    defb  0,  1
    defb -1,  1
    defb -1,  0
    defb -1, -1    

