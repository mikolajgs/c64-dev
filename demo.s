           * = $2000
           .binary "picture.sda", 0

           * = $0801

           .word (+), 2016
           .null $9e, format("%d", start)
+          .word 0

start      lda #$00
           sta $d020
           lda $4711
           sta $d021
           tax

copyloop:
           lda $3f40,x  ; copy colours to screen RAM
           sta $0400,x
           lda $4040,x
           sta $0500,x
           lda $4140,x
           sta $0600,x
           lda $4240,x
           sta $0700,x
           lda $4328,x  ; copy colours to colour RAM
           sta $d800,x
           lda $4428,x
           sta $d900,x
           lda $4528,x
           sta $da00,x
           lda $4628,x
           sta $db00,x
           dex
           bne copyloop

           lda #$3b     ; bitmap mode
           ldx #$18     ; multi-colour mode
           ldy #$18     ; screen at $0400, bitmap at $2000
           sta $d011
           stx $d016
           sty $d018

mainloop:
           jmp mainloop ; keep going...

