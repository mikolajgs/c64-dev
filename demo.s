           * = $0801

           .word (+), 2016
           .null $9e, format("%d", start)
+          .word 0

start      lda #$00
           sta $d020
           sta $d021
           tax
           lda #$00
clrscreen
           sta $0400,x
           sta $0500,x
           sta $0600,x
           sta $0700,x
           sta $2000,x ; and the charset data to 0
           dex
           bne clrscreen
           lda #$018 ; screen at $0400, chars at $2000
           sta $d018
mainloop
           lda $d012
           cmp #$fe ; on raster line $ff?
           bne mainloop
           ldx counter ; get offset value
           inx
           cpx #88 ; it it's 28, start over
           bne juststx
           ldx #$00
juststx
           stx counter
           lda $2000,x ;get byte nr x from chardata
           eor #$ff ; invert it
           sta $2000,x ;store it back

           jmp mainloop ; keep going...
counter
           .byte 8 ;initial value for counter
