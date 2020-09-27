map_doors
    ld a, (this_rooms_door_count)
    ld ix, this_rooms_door_list

next_door_to_map
    push af
;   
;   
;   
;   
;   
    pop af
    ld de, 8
    add ix, de
    dec a
    jr nz, next_door_to_map

    ret