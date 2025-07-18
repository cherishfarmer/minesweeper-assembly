*-----------------------------------------------------------
* Title      : Draw Clicked
* Written by : Cherish Farmer
* Date       : 06/03/25
* Description: Update tile to display as clicked by removing depth of tile. Drawn with primitives
* Key:
* - d0: task codes
* - d1: tile x
* - d2: tile y
* - d3: end x (tile x + tile size)
* - d4: end y (tile y + tile size)
* - d7: temp store x
*-----------------------------------------------------------

SetCoordinatesRect
    ; move x back to d1
    move.l  d7,d1
    
    ; set d3 and d4
    move.w  d1,d3
    move.w  d2,d4
    add.w   #TILE_SIZE,d3
    add.w   #TILE_SIZE,d4
    
    rts

DrawClicked

    ; store x in d7 to be used later
    move.w  d1,d7
    
    ; set pen width
    clr.l   d0
    move.b  #SET_PEN_WIDTH,d0
    move.w  #PEN_WIDTH,d1
    trap    #15

    ; set pen color
    move.b  #SET_PEN_COLOR,d0
    move.l  #LIGHT_GREY,d1
    trap    #15
    
    jsr     SetCoordinatesRect
    
    ; draw light grey unfilled rectangle to get rid of shading
    move.b  #DRAW_RECT_UNFILLED,d0
    trap    #15
    
    ; set pen width to narrower
    clr.l   d0
    move.b  #SET_PEN_WIDTH,d0
    move.w  #PEN_WIDTH,d1
    lsr.w   #HALF_WIDTH,d1
    trap    #15

    ; set pen color
    move.b  #SET_PEN_COLOR,d0
    move.l  #DARK_GREY,d1
    trap    #15
    
    jsr     SetCoordinatesRect
    
    ; adjust coordinates to compensate for narrower lines
    sub.w   #HALF_WIDTH,d1
    sub.w   #HALF_WIDTH,d2
    add.w   #HALF_WIDTH,d3
    add.w   #HALF_WIDTH,d4
    
    ; draw dark grey unfilled rectangle for clicked
    move.b  #DRAW_RECT_UNFILLED,d0
    trap    #15
    
    ; adjust coordinates back to original position
    add.w   #HALF_WIDTH,d1
    add.w   #HALF_WIDTH,d2

    clr.w   d3      ; don't clear long because tile type is stored in upper word
    clr.w   d4      ; don't clear long because tile type is stored in upper word
    clr.l   d7
    
    ; check if bomb has been clicked so non-bomb tiles are not decremented
    lea     Clicked_Bomb_Address,a4
    cmp.w   #CLICKED_BOMB_UNSTORED,(a4)
    bne     ReturnAfterDrawingClicked
    
    ; since not bomb, decrement num non-bomb tiles 
    lea     Non_Bomb_Tiles,a4
    sub.l   #1,(a4)
    move.l  #CLEAR_ADDRESS,a4

ReturnAfterDrawingClicked    
    jsr     RepaintScreen
    rts
    







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
