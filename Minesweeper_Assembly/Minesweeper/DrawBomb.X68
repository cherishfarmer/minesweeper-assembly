*-----------------------------------------------------------
* Title      : Draw Bomb
* Written by : Cherish Farmer
* Date       : 06/05/25
* Description: Draws bombs as primitives
* Key:
* - d0: task codes
* - d1: start x
* - d2: start y
* - d3: end x
* - d4: end y
* - d5: temp hold start x
* - d6: temp hold start y
*-----------------------------------------------------------

DrawBomb

    ; save d1 and d2 in d5 and d6
    move.l  d1,d5
    move.l  d2,d6
    
    ; set pen width
    clr.l   d0
    move.b  #SET_PEN_WIDTH,d0
    move.w  #BOMB_PEN_WIDTH,d1
    trap    #15

    ; set pen color to black
    move.b  #SET_PEN_COLOR,d0
    move.l  #BLACK,d1
    trap    #15
    
    ; set fill color to black
    move.b  #SET_FILL_COLOR,d0
    trap    #15
    
    ; store pos in d1 and d2
    move.l  d5,d1
    move.l  d6,d2
    
    ; calc pos by adding quarter of tile size to each (divide tile size by 4 -- make equate)
    add.l   #TILE_QUARTER,d1
    add.l   #TILE_QUARTER,d2
    
    ; use d1 and d2 to calc end positions d3 and d4
    move.l  d1,d3
    move.l  d2,d4
    add.l   #BOMB_WIDTH,d3
    add.l   #BOMB_WIDTH,d4
    
    ; draw black filled circle from pos to pos+tile size
    move.b  #DRAW_ELLIPSE_FILLED,d0
    trap    #15
    
    ; draw down diagonal line
    move.b  #DRAW_LINE,d0
    trap    #15
    
    ; draw up diagonal line
    move.l  d4,d2
    move.l  d6,d4
    add.l   #TILE_QUARTER,d4
    trap    #15
    
    ; draw horizontal line
    move.l  d5,d1
    add.w   #TILE_EIGTH,d1
    move.l  d1,d3
    add.w   #(TILE_SIZE-TILE_QUARTER),d3
    move.l  d6,d2
    add.w   #TILE_HALF,d2
    move.l  d2,d4
    trap    #15
    
    ; draw vertical line
    move.l  d6,d2
    add.w   #TILE_EIGTH,d2
    move.l  d2,d4
    add.w   #(TILE_SIZE-TILE_QUARTER),d4
    move.l  d5,d1
    add.w   #TILE_HALF,d1
    move.l  d1,d3
    trap    #15
    
    ; set pen color to highlight
    move.b  #SET_PEN_COLOR,d0
    move.l  #HIGHLIGHT,d1
    trap    #15
    
    ; set fill color to highlight
    move.b  #SET_FILL_COLOR,d0
    trap    #15
    
    clr.l   d1
    
    ; draw white circle with coord from half of black circle top left to origin
    move.b  #DRAW_ELLIPSE_FILLED,d0
    move.l  d5,d1
    move.l  d6,d2
    add.w   #(TILE_QUARTER+TILE_EIGTH),d1
    add.w   #(TILE_QUARTER+TILE_EIGTH),d2
    move.l  d1,d3
    move.l  d2,d4
    add.w   #TILE_SIXTEENTH,d3
    add.w   #TILE_SIXTEENTH,d4
    trap    #15
    
    ; reset fill color
    move.b  #SET_FILL_COLOR,d0
    move.l  #LIGHT_GREY,d1
    trap    #15
    
    jsr     RepaintScreen
    
    ; checks if the bomb being drawn is the clicked bomb, don't need to draw as clicked if it is
    lea     Clicked_Bomb_Address,a4
    move.w  (a4),d0
    cmp.w   a1,d0
    beq     SkipDrawClicked
    
    ; preps positions to draw clicked
    move.l  d5,d1
    move.l  d6,d2
    jsr     DrawClicked

SkipDrawClicked    
    jsr     ClearRegisters

    rts
    

DrawClickedBomb

    ; save d1 for later
    move.l  d1,d5
    
    jsr     DrawClicked
    
    ; set pen color
    move.b  #SET_PEN_COLOR,d0
    move.l  #CLICKED_BOMB_COLOR,d1
    trap    #15
    
    ; set fill color
    move.b  #SET_FILL_COLOR,d0
    trap    #15
    
    ; redraw tile as red
    move.b  #DRAW_FILLED_RECT,d0
    move.l  d5,d1
    move.l  d1,d3
    move.l  d2,d4
    add.w   #TILE_SIZE,d3
    add.w   #TILE_SIZE,d4
    trap    #15
    
    ; repaint to screen
    jsr     RepaintScreen
    
    ; go back to draw rest of bombs
    rts






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
