           * = $0801

           .word (+), 2016
           .null $9e, format("%d", start)
+          .word 0

start      lda #$01
           sta $d015 ; turn sprite 0 on
           lda #$03
           sta $d027 ; make it white
           lda #$40  ; 60
           sta $d000 ; set x coordinate to 40
           sta $d001 ; set y corrdinate to 40
           lda #$80
           sta $07f8 ; set pointer: sprite dataat $2000

mainloop
           lda $d012
           cmp #$ff  ; raster beam at line $ff?
           bne mainloop ; no: go to mainloop

           lda dir   ; which direction are we moving?
           beq down  ; if 0, down

                     ; moving up
           ldx coord ; get coord
           dex
           stx coord ; store it
           stx $d000 ; set sprite coords
           stx $d001 ; y
           cpx #$40  ; if it's not equal to $40
           bne mainloop

           lda #$00  ; otherwise, change direction
           sta dir
           jmp mainloop

down
           ldx coord ; this should be familiar
           inx
           stx coord
           stx $d000
           stx $d001
           cpx #$e0
           bne mainloop

           lda #$01
           sta dir
           jmp mainloop

coord
           .byte $40
dir
           .byte 0
