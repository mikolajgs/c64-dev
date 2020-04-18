           * = $1000
           .binary "demo.sid", $7e

           * = $0801

           .word (+), 2016
           .null $9e, format("%d", start)
+          .word 0

start      lda #$00
           tax
           tay
           jsr $1000

mainloop:  lda $d012
           cmp #$80
           bne mainloop

           inc $d020
           jsr $1006
           dec $d020
           jmp mainloop
           rts

