num_rows equ 192     ; same height as spectrum
  
set_screen_size
  ld hl, crtc_vals
  call set_crtc
  ret

set_crtc
  ld bc, &bc00
set_crtc_vals
  out (c), c
  inc b
  ld a, (hl)
  out (c), a
  dec b
  inc hl
  inc c
  ld a, c
  cp 14
  jr nz, set_crtc_vals
  ret

crtc_vals
  defb &3f              ;; R0 - Horizontal Total
  defb 40               ;; R1 - Horizontal Displayed  (32 chars wide)
  defb 46               ;; R2 - Horizontal Sync Position (centralises screen)
  defb &86              ;; R3 - Horizontal and Vertical Sync Widths
  defb 38               ;; R4 - Vertical Total
  defb 0			          ;; R5 - Vertical Adjust
  defb num_rows / 8     ;; R6 - Vertical Displayed
  defb 30               ;; R7 - Vertical Sync Position (centralises screen) (was 31)
  defb 0                ;; R8 - Interlace
  defb 7                ;; R9 - Max Raster
  defb 0                ;; R10 - Cursor (not used)
  defb 0                ;; R11 - Cursor (not used)
  defb &30              ;; R12 - Screen start (start at &c000)
  defb &00              ;; R13 - Screen start