           * = $0801

           .word (+), 2016
           .null $9e, format("%d", start)
+          .word 0

start      lda #$00      ; Put the value 0 in accumulator
           sta $d020     ; Put value of acc in $d020
           sta $d021     ; Put value of acc in $d021
           tax           ; Put value of acc in x reg
           jsr $1000
           lda #$20      ; Put the value $20 in acc
clrloop:   sta $0400,x   ; Put value of acc in $0400 + value in x reg
           sta $0500,x   
           sta $0600,x   
           sta $0700,x
           dex            ; Decrement value in x reg
           jsr $1003
           bne clrloop    ; If not zero, branch to clrloop
           rts
