;
; Line drawing routine by fgbrain on cpcwiki.eu forum
; see http://www.cpcwiki.eu/forum/programming/fast-line-draw-in-assembly-(breseham-algorithm)/
;

plot_line               ; IN: bc = start vertex, de = end vertex
  di

  srl b
  srl d                   ; divide both x-coords by 2

  ld (exith + 1), sp      ; save SP to restore at exit..
  ld h, 0
  ld a, c

  ld l, b
  ld (x1+1), hl       ;x1
  ld l, c
  ld (y1+1), hl       ;y1

  ld l, d
  ld (x2+1), hl       ;x2
  ld l, e
  ld (y2+1), hl       ;y2

  ld d, 0
  ld e, a
  or a
  sbc hl, de          ;  hl=y2-y1
  jp p, gnp0

  xor a
  sub l
  ld l, a
  sbc a, a
  sub h
  ld h, a             ;  ABS hl

gnp0
  ld (dy+1), hl      ; =ABS(DY)
  ld a, h
  cpl
  ld h, a
  ld a, l
  cpl
  ld l, a
  inc hl              ; neg hl = -DY
  srl h
  rr l
  set 7, h             ; keep negative HL
  ld (er+1), hl       ;  ER = -DY/2

  ex de, hl
  ld de, (y2+1)
  or a
  sbc hl, de           ; hl=y1-y2
  ld a, &34
  jr c, skip1
  ld a, &35           ; sy= DEC (HL) / if y1 - y2 <0  sy= INC (HL)
skip1
  ld (sy), a

  ld de, (x1+1)
  ld hl, (x2+1)
  or a
  sbc hl, de           ; hl=x2-x1
  jp p, gnp1
  xor a
  sub l
  ld l, a
  sbc a, a
  sub h
  ld h, a              ;  ABS hl

gnp1
  ld sp, hl
  ld b, h
  ld c, l              ; =ABS(DX) = BC = SP stack pointer !!!!!!

  ex de, hl
  ld de, (x2+1)
  or a
  sbc hl, de           ;  HL=x1-x2
  ld a, &34
  jr c, skip2
  ld a, &35            ; sx= DEC (HL) / if x1 - x2 <0  sx= INC (HL)
skip2
  ld (sx), a

  ld h, b
  ld l, c              ;  HL=dx
  ld de, (dy+1)
  or a
  sbc hl, de           ; hl=dx-dy
  jr c, nex0           ; if dx-dy>0 (dx>dy)  [when nc]
  ld h, b
  ld l, c              ; HL=dx
  srl h
  rr l
  ld (er+1), hl        ; then er=dx/2

nex0
DRLOOP                 ; main DRAWING loop
x1
  ld de, 1
y1
  ld hl, 1

; Fast Plot for MODE 0 by Executioner follows...
FPLOT
  ld a, l            ;A = Lowbyte Y
  and %00000111        ;isolate Bit 0..2
  ld h, a            ;= y MOD 8 to H
  xor l            ;A = Bit 3..7 of Y
  ld l, a            ;= (Y\*8 to L
  ld c,a             ;store in C

scr_offset_value
  ld b, &60         ;B = &C0\2 = Highbyte Screenstart\2  ; this value set prior to drawing room outline
  add hl, hl        ;HL * 2
  add hl, hl        ;HL * 4
  add hl, bc        ;+ BC = Startaddress
  add hl, hl        ;of the raster line
  srl e            ;calculate X\2, because 2 pixel per byte, Carry is X MOD 2
  ld c, %10101010            ;Bitmask for MODE 0
  jr nc, NSHIFT        ;-> = 0, no shift

SHIFT
  ld c, %01010101            ;other bitmask for right pixel
NSHIFT
  add hl, de        ;+ HL = Screenaddress
  ld a, (line_pen_number)        ; pen to use
  xor (hl)        ;XOR screenbyte
  and c            ;AND bitmask
  xor (hl)        ;XOR screenbyte
  ld (hl), a        ;new screenbyte

  ld hl,(x1+1)
x2
  ld de,0
  or a
  sbc hl, de
  jr nz, nex1         ; CHECK if we reach the end???
  ld hl, (y1+1)
y2
  ld de, 0
  or a
  sbc hl, de
  jr z, exith         ; if x1=x2 and y1=y2 then exit!!

nex1
er
  ld hl, 0
  ld b, h
  ld c, l             ; HL=ER=E2=BC
dy
  ld de, 0            ; DE= DY
  add hl, sp          ; SP=DX
  bit 7, h
  jr nz, nex2         ; IF  E2+DX > 0  THEN ER = ER - DY
  ld h, b
  ld l, c
  or a
  sbc hl, de
  ld (er+1), hl        ; er = er -dy
  ld hl, x1+1
sx
  db 0                ; X1 = X1 + SX

nex2
  ld h, b
  ld l, c             ; HL=E2   DE=dy
  or a
  sbc hl, de            ; IF E2 - DY < 0 THEN ER = ER + DX
  jp p, nex3
  ld hl, (er+1)
  add hl, sp            ; SP=DX
  ld (er+1), hl         ; er = er+dx
  ld hl, y1+1

sy
  db 0             ; Y1 = Y1 + SY

nex3
  jp drloop

exith
  ld sp, 0        ; modified in init
  ret             ; finished OK

line_pen_number
  defb 0x00