*-----------------------------------------------------------
* Title      : Draw Blank Tile
* Written by : Cherish Farmer
* Date       : 06/02/25
* Description: Draws a blank tile. Used to print initial board and background for smiley guy
* Key:
* - d0: trap code
* - d1: x start pos
* - d2: y start pos
* - d3: x end pos
* - d4: y end pos
* - d5: temp x
* - d6: temp y
*-----------------------------------------------------------

DrawBlankTile

    ; set pen width
    clr.l   d0
    move.b  #SET_PEN_WIDTH,d0
    move.w  #PEN_WIDTH,d1
    trap    #15
    
    ; draw dark grey unfilled rectangle
    move.b  #SET_PEN_COLOR,d0
    move.l  #DARK_GREY,d1
    trap    #15
    
    ; horizontal dark line
    move.b  #DRAW_LINE,d0
    move.l  d3,d1
    trap    #15
    
    ; vertical dark line
    move.w  d5,d1
    move.w  d2,d5
    move.w  d4,d2
    trap    #15
    
    ; move values back
    move.w  d5,d2
    move.w  d1,d5
    
    ; draw two white highlight lines, one horizontal and one vertical (determine tile length)
    move.b  #SET_PEN_COLOR,d0
    move.l  #HIGHLIGHT,d1
    trap    #15
    
    ; set starting position for highlights
    move.l  d5,d1
    
    ; store end y into d5 to save for vertical line
    move.w  d4,d5
    
    ; move d2 into d4 for horizontal line
    move.w  d2,d4
    
    ; horizontal line
    move.b  #DRAW_LINE,d0
    trap    #15
    
    ; move d1 into d3 and d4 back to d5 for horizontal line
    move.w  d3,d6
    move.w  d1,d3
    move.w  d5,d4
    
    ; vertical line
    trap    #15
    
    rts    





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
