DEBUG=1

macro BORDER_ON hw_colour
if DEBUG
    ld d, {hw_colour}
    call background_on
endif
mend

macro BORDER_OFF
if DEBUG
    call background_off
endif
mend