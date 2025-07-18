*-----------------------------------------------------------
* Title      : Draw Grid Box
* Written by : Cherish Farmer
* Date       : 06/03/25
* Description: Draws box around entire grid for visual appeal
*
* Key:
* - d0: task codes
* - d1: x start
* - d2: y start
* - d3: x end
* - d4: y end
*-----------------------------------------------------------

GRID_BOX_WIDTH          EQU     PEN_WIDTH
BORDER_OFFSET           EQU     PEN_WIDTH
GRID_SIDE_LENGTH        EQU     TILE_SIZE*(NUM_COL+1)

GRID_OUTER_OFFSET       EQU     PEN_WIDTH*4
WINDOW_OFFSET           EQU     PEN_WIDTH

TOP_UI_HEIGHT           EQU     50
TOP_UI_WIDTH            EQU     GRID_SIDE_LENGTH
TOP_UI_PEN              EQU     PEN_WIDTH/2

WINDOWS_BLUE            EQU     $b04d10

DrawGridBox

    ; TODO: clean up code, use more equates for calculated values especially later on

    ; draw inner box

    ; set pen width TODO: create jsr for repeat code
    clr.l   d0
    move.b  #SET_PEN_WIDTH,d0
    move.w  #GRID_BOX_WIDTH,d1
    trap    #15
  
    ; set pen color to dark grey
    move.b  #SET_PEN_COLOR,d0
    move.l  #DARK_GREY,d1
    trap    #15
    
    clr.l   d1
    
    ; set trap code for line
    move.b  #DRAW_LINE,d0
    
    ; set positions and sub to shift grid out
    move.w  #START_X,d1
    move.w  #START_Y,d2
    sub.w   #BORDER_OFFSET,d1       ; TODO: just sub these values from START x/y when moving
    sub.w   #BORDER_OFFSET,d2
    move.w  d1,d3
    move.w  d2,d4
    
    ; horizontal grey line
    add.w   #GRID_SIDE_LENGTH,d3    ; x changes
    trap    #15
    
    ; vertical grey line
    move.w  d1,d3                   ; reset x position since it doesn't change
    add.w   #GRID_SIDE_LENGTH,d4    ; y changes
    trap    #15
        
    ; set pen color to highlight
    move.b  #SET_PEN_COLOR,d0
    move.l  #HIGHLIGHT,d1
    trap    #15
    
    clr.l   d1
    
    ; set trap code for line
    move.b  #DRAW_LINE,d0
    
    ; set positions and sub to shift grid out TODO: make jsr
    move.w  #START_X,d1
    sub.w   #BORDER_OFFSET,d1
    add.w   #GRID_SIDE_LENGTH,d1
    move.w  d1,d3
    move.w  #START_Y,d2             ; d4 should stay the same
    
    ; vertical highlight
    trap    #15
    
    ; horizontal highlight
    move.w  #START_X,d1
    move.w  d4,d2
    trap    #15
    
    
    
    ; draw outer box TODO: make subroutines for repeat code
    
    clr.l   d1
    
    ; set trap code for line
    move.b  #DRAW_LINE,d0
    
    ; set positions and sub to shift grid out
    move.w  #START_X,d1
    move.w  #START_Y,d2
    sub.w   #GRID_OUTER_OFFSET,d1       ; TODO: just sub these values from START x/y when moving
    sub.w   #GRID_OUTER_OFFSET,d2
    move.w  d1,d3
    sub.w   #TOP_UI_HEIGHT,d2
    move.w  d2,d4
    
    ; horizontal grey line
    add.w   #(GRID_SIDE_LENGTH+(GRID_OUTER_OFFSET+BORDER_OFFSET*2)),d3    ; x changes
    trap    #15
    
    ; vertical grey line
    move.w  d1,d3                   ; reset x position since it doesn't change
    add.w   #(GRID_SIDE_LENGTH+(GRID_OUTER_OFFSET+BORDER_OFFSET*2)+TOP_UI_HEIGHT),d4    ; y changes
    trap    #15
        
    ; set pen color to dark grey
    move.b  #SET_PEN_COLOR,d0
    move.l  #DARK_GREY,d1
    trap    #15
    
    clr.l   d1
    
    ; set trap code for line
    move.b  #DRAW_LINE,d0
    
    ; set positions and sub to shift grid out TODO: make jsr
    move.w  #START_X,d1
    add.w   #(GRID_SIDE_LENGTH+(BORDER_OFFSET*2)),d1
    move.w  d1,d3
    move.w  #(START_Y-TOP_UI_HEIGHT-GRID_OUTER_OFFSET),d2             ; d4 should stay the same
    
    ; vertical highlight
    trap    #15
    
    ; horizontal highlight
    move.w  #(START_X-GRID_OUTER_OFFSET),d1
    move.w  d4,d2
    trap    #15   
    
    ; draw blue window box
    
    ; set pen color to blue
    move.b  #SET_PEN_COLOR,d0
    move.l  #WINDOWS_BLUE,d1
    trap    #15
    
    clr.l   d1
    
    ; set trap code for line
    move.b  #DRAW_LINE,d0
    
    ; set positions and sub to shift grid out
    move.w  #START_X,d1
    move.w  #START_Y,d2
    sub.w   #(GRID_OUTER_OFFSET+WINDOW_OFFSET),d1       ; TODO: just sub these values from START x/y when moving
    sub.w   #(GRID_OUTER_OFFSET+WINDOW_OFFSET),d2
    move.w  d1,d3
    sub.w   #TOP_UI_HEIGHT,d2
    move.w  d2,d4
    
    ; horizontal grey line
    add.w   #(GRID_SIDE_LENGTH+(GRID_OUTER_OFFSET+BORDER_OFFSET*2+WINDOW_OFFSET*2)),d3    ; x changes
    trap    #15
    
    ; vertical grey line
    move.w  d1,d3                   ; reset x position since it doesn't change
    add.w   #(GRID_SIDE_LENGTH+(GRID_OUTER_OFFSET+BORDER_OFFSET*2+(WINDOW_OFFSET*2))+TOP_UI_HEIGHT),d4    ; y changes
    trap    #15
    
    ; set trap code for line
    move.b  #DRAW_LINE,d0
    
    ; set positions and sub to shift grid out TODO: make jsr
    move.w  #START_X,d1
    add.w   #(GRID_SIDE_LENGTH+(BORDER_OFFSET*2)+WINDOW_OFFSET),d1
    move.w  d1,d3
    move.w  #(START_Y-TOP_UI_HEIGHT-GRID_OUTER_OFFSET-WINDOW_OFFSET),d2             ; d4 should stay the same
    
    ; vertical highlight
    trap    #15
    
    ; horizontal highlight
    move.w  #(START_X-GRID_OUTER_OFFSET-WINDOW_OFFSET),d1
    move.w  d4,d2
    trap    #15
    
    
    
    ; draw box around top ui
    
    ; set pen width TODO: create jsr for repeat code
    clr.l   d0
    move.b  #SET_PEN_WIDTH,d0
    move.w  #TOP_UI_PEN,d1
    trap    #15
  
    ; set pen color to dark grey
    move.b  #SET_PEN_COLOR,d0
    move.l  #DARK_GREY,d1
    trap    #15
    
    clr.l   d1
    
    ; set trap code for line
    move.b  #DRAW_LINE,d0
    
    ; set positions and sub to shift grid out
    move.w  #START_X,d1
    move.w  #START_Y,d2
    sub.w   #(BORDER_OFFSET*2),d1       ; TODO: just sub these values from START x/y when moving
    sub.w   #(TOP_UI_HEIGHT+BORDER_OFFSET*2),d2
    move.w  d1,d3
    move.w  d2,d4
    
    ; horizontal grey line
    add.w   #(GRID_SIDE_LENGTH+BORDER_OFFSET*2),d3    ; x changes
    trap    #15
    
    ; vertical grey line
    move.w  d1,d3                   ; reset x position since it doesn't change
    add.w   #(TOP_UI_HEIGHT-BORDER_OFFSET),d4    ; y changes
    trap    #15
    
    ; set pen color to highlight
    move.b  #SET_PEN_COLOR,d0
    move.l  #HIGHLIGHT,d1
    trap    #15
    
    clr.l   d1
    
    ; set trap code for line
    move.b  #DRAW_LINE,d0
    
    ; set positions and sub to shift grid out TODO: make jsr
    move.w  #START_X,d1
    add.w   #GRID_SIDE_LENGTH,d1
    move.w  d1,d3
    move.w  #(START_Y-TOP_UI_HEIGHT-(BORDER_OFFSET*2)),d2             ; d4 should stay the same
    
    ; vertical highlight
    trap    #15
    
    ; horizontal highlight
    move.w  #(START_X-(BORDER_OFFSET*2)),d1
    move.w  d4,d2
    trap    #15
    
    jsr     ClearRegisters
    
    move.l  #CLEAR_ADDRESS,a0
    move.l  #CLEAR_ADDRESS,a1
    move.l  #CLEAR_ADDRESS,a2
    move.l  #CLEAR_ADDRESS,a3
    move.l  #CLEAR_ADDRESS,a4

    rts










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
