collectable_items
; room (0xff = in a pocket)
; item_gfx address
; x, y
; type (collectable, toxic eg. mushrooms)

defb 0x00
defb collectable_acgkey1
defb 0x30, 0x30
defb type_collectable

defb 0x00
defb collectable_acgkey2
defb 0x38, 0x30
defb type_collectable

defb 0x00
defb collectable_acgkey3
defb 0x38, 0x38
defb type_collectable

end_collectable_items

transient_items
; room, item, x, y, collected
end_transient_items

pocket1
    defb 0
pocket2
    defb 0
pocket3
    defb 0

collectable_table
    defw item_acgkey1
    defw item_acgkey2
    defw item_acgkey3
    defw key_blue
    defw key_green
    defw key_red
    defw key_yellow

