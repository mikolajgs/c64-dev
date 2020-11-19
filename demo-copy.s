screen_ram      = $0400
address_sprites = $2000 
sprite_ship_current_frame = $fb
delay_animation_pointer   = $9e
sprite_frames_ship        = 16
sprite_pointer_ship       = address_sprites / $40
sprite_background_color   = $00
sprite_multicolor_1       = $0b
sprite_multicolor_2       = $01
sprite_ship_color         = $02

pra  = $dc00
prb  = $dc01
ddra = $dc02
ddrb = $dc03

                * = address_sprites
                .binary "sprites3.spr", 3, 1024

                * = $0801

                .word (+), 2016
                .null $9e, format("%d", start)
+               .word 0

start           jsr init_screen
                ; initialise memory
                lda #sprite_frames_ship
                sta sprite_ship_current_frame

                lda #sprite_pointer_ship
                sta screen_ram + $3f8 		

                ; initialise vic-ii registers
                lda #$01   ; enable Sprite#0
                sta $d015 
                lda #$01   ; set Multicolor mode for Sprite#0
                sta $d01c
                lda #$00   ; Sprite#0 has priority over background
                sta $d01b

                lda #sprite_background_color 
                sta $d021
                lda #sprite_multicolor_1
                sta $d05
                lda #sprite_multicolor_2 
                sta $d026
                lda #sprite_ship_color
                sta $d027

                lda #$01    ; set X-Coord high bit (9th Bit)
                sta $d010

                lda #$a0    ; set Sprite#0 positions with X/Y coords to
                sta $d000   ; bottom border of screen on the outer right
                lda #$33    ; $d000 corresponds to X-Coord
                sta $d001   ; $d001 corresponds to Y-Coord

                sei
                jsr init_screen
                jsr init_text
                
                ldy #$7f ; $7f = %01111111
                sty $dc0d ; turn off CIAs Timer interrupts
                sty $dd0d ; turn off CIAs Timer interrupts
                lda $dc0d ; cancel all CIA-IRQs in queue/unprocessed
                lda $dd0d ; cancel all CIA-IRQs in queue/unprocessed
                
                lda #$01 ; set Interrupt Request Mask...
                sta $d01a ; ...we want IRQ by Rasterbeam

                lda $d011
                and #$7f
                sta $d011

                lda #<irq ; point irq vector to our custom irq routine
                ldx #>irq
                sta $314 ; store in $314/315
                stx $315
                
                lda #$00 ; trigger first interrupt at row zero
                sta $d012

                cli 
                jmp *

; ==== custom routing
irq             dec $d019 ; acknowledge IRQ / clear register for next interrupt
                jsr anim_text
                jsr check_keys
                jsr update_ship
                jmp $ea81 ; return to kernel interrupt routine

; ==== text
                .enc "screen"
line1           .text "        bierun.digital presents         "
                .enc "none"

; ==== init screen
init_screen     ldx #$00 ; set x to zero (black bg)
                stx $d021 ; set bg color
                stx $d020 ; set fg color

clear           lda #$20 ; #$20 is the spacebar screen code
                sta $0400,x ; fill four areas with 256 spacebar characters
                sta $0500,x
                sta $0600,x
                sta $06e8,x
                lda #$00
                sta $d800,x
                sta $d900,x
                sta $da00,x
                sta $dae8,x
                inx ; increment x
                bne clear ; did x turn to zero ? if not then continue

                rts

; ==== init text
init_text       ldx #$00 ; init x with $00
loop_text       lda line1,x ; read character from line1
                sta $04f0,x ; and store on screen
                lda #$06 ; set colour
                sta $d8f0,x

                inx
                cpx #len(line1)
                bne loop_text
                rts

; ==== get get_key
check_keys      lda #%11111111 ; cia#1 port a needs to be set to output
                sta ddra

                lda #%00000000 ; cia#1 port b needs to be set to input
                sta ddrb

check_i         lda #%11101111 ; select third row
                sta pra        ; by storing $09 into pra
                lda prb        ; load current column information
                and #%00000010 ; isolate 'i' key bit which is bit #1
                beq move_up

check_k         lda #%11101111 ; select 3rd row
                sta pra
                lda prb
                and #%00100000 ; isolate 'k' key bit which is bit #5
                beq move_down
                rts

move_up         lda $d001
                cmp #$1e       ; check y-coord whether we are too high
                beq skip
                dec $d001      ; decrease y-coord for sprite 1
                rts

move_down       lda $d010
                cmp #$ff       ; check y-coord whether we are too low
                beq skip
                inc $d001
                rts

skip            rts

; ==== subroutine to jump into
anim_text       ldx #$00
loop_colour     inc $d8f0,x

                inx
                cpx #len(line1) ; loop until end of line1
                bne loop_colour

                ldx #$00 ; set x to 0
                ldy $04f0 ; get first char
loop_move       inx
                lda $04f0,x
                dex
                sta $04f0,x
                
                inx
                cpx #$28
                bne loop_move
                dex
                tya
                sta $04f0,x
                rts

ship_x_high         lda $d010                      ; load 9th Bit
                    eor #$01                       ; eor against #$01
                    sta $d010                      ; store into 9th bit

update_ship         dec $d000                      ; decrease X-Coord until zero
                    beq ship_x_high                ; switch 9th Bit of X-Coord

animate_ship        lda delay_animation_pointer    ; pointer is either #$01 or #$00
                    eor #$01                       ; eor flips between 0 and 1
                    sta delay_animation_pointer    ; store back into pointer
                    beq delay_animation            ; skip animation for this refresh if 0
                    lda sprite_ship_current_frame  ; load current frame number
                    bne dec_ship_frame             ; if not progress animation

reset_ship_frames   lda #sprite_frames_ship        ; load number of frames for ship
                    sta sprite_ship_current_frame  ; store into current frame counter
                    lda #sprite_pointer_ship       ; load original sprite shape pinter
                    sta screen_ram + $3f8          ; store in Sprite#0 pointer register

dec_ship_frame      inc screen_ram + $3f8          ; increase current pointer position
                    dec sprite_ship_current_frame  ; decrease current Frame
                    beq reset_ship_frames          ; if current frame is zero, reset

delay_animation     rts                            ; do nothing in this refresh, return