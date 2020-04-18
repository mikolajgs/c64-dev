           * = $0801

           .word (+), 2016
           .null $9e, format("%d", start)
+          .word 0

start      lda #$00
           sta $d020
           sta $d021
           tax
           lda #$00
clrscr
           sta $0400,x
           sta $0500,x
           sta $0600,x
           sta $0700,x
           sta $2000,x
           dex
           bne clrscr
           lda #$018
           sta $d018
mainloop
           lda $d012
           cmp #$fe
           bne mainloop
           ldx counter
           inx
           cpx #88
           bne changechr
           ldx #$00
changechr
           stx counter
           lda $2000,x
           eor #$ff
           sta $2000,x

           jmp mainloop
counter
           .byte 8
