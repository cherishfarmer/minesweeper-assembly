*-----------------------------------------------------------
* Title      : Draw Flag
* Written by : Cherish Farmer
* Date       : 06/06/25
* Description:
* Key:
* - d0: task codes
* - d1: start x
* - d2: start y
* - d3: end x
* - d4: end y
* - d5: temp hold start x
* - d6: temp hole start y
* - d7: counter for filling in flag
*-----------------------------------------------------------

LIGHT_GREY              EQU     $c0c0c0
HIGHLIGHT               EQU     $fcfcfc
BLACK                   EQU     $000000
FLAG_RED                EQU     $000000fe

FLAG_POLE_WIDTH         EQU     3
FLAG_WIDTH              EQU     5

SET_PEN_COLOR           EQU     80
SET_FILL_COLOR          EQU     81
DRAW_PIXEL              EQU     82
DRAW_LINE               EQU     84
DRAW_RECT_FILLED        EQU     87
SET_PEN_WIDTH           EQU     93

TILE_HALF               EQU     TILE_SIZE/2
TILE_QUARTER            EQU     TILE_SIZE/4
TILE_EIGTH              EQU     TILE_SIZE/8
TILE_SIXTEENTH          EQU     TILE_SIZE/16
BOMB_WIDTH              EQU     TILE_SIZE-TILE_HALF

NUM_FLAG_FILLS          EQU     2

DrawFlag

    ; save d1 and d2 in d5 and d6
    move.l  d1,d5
    move.l  d2,d6
    
    ; set pen width
    clr.l   d0
    move.b  #SET_PEN_WIDTH,d0
    move.w  #FLAG_POLE_WIDTH,d1
    trap    #15
   
    ; set pen color to black
    move.b  #SET_PEN_COLOR,d0
    move.l  #BLACK,d1
    trap    #15
    
    ; set fill color to black
    move.b  #SET_FILL_COLOR,d0
    trap    #15
    
    ; move d1 back to use for pos
    move.l  d5,d1
    
    ; set end positions
    add.l   #TILE_HALF,d1
    move.l  d1,d3
    move.l  d2,d4
    add.l   #TILE_SIZE,d4
    
    ; adjust y values for vertical line
    add.l   #(TILE_EIGTH+TILE_SIXTEENTH),d2
    sub.l   #TILE_QUARTER,d4
    
    ; draw vertical line
    move.b  #DRAW_LINE,d0
    trap    #15
    
    ; reset positions for horizontal line
    move.l  d4,d2
    sub.l   #TILE_QUARTER,d1
    add.l   #TILE_QUARTER,d3
    
    ; draw horizontal line
    trap    #15
    
    ; reset positions for black rect
    add.l   #TILE_EIGTH,d1
    sub.l   #TILE_SIXTEENTH,d2
    sub.l   #TILE_EIGTH,d3
    
    ; draw rect
    move.b  #DRAW_FILLED_RECT,d0
    trap    #15
    
    ; set pen color to red
    move.b  #SET_PEN_COLOR,d0
    move.l  #FLAG_RED,d1
    trap    #15
    
    ; move d1 back
    move.l  d5,d1
    
    ; reset positions for first diag
    add.l   #TILE_HALF,d1
    move.l  d1,d3
    sub.l   #TILE_QUARTER,d3
    move.l  d6,d2
    add.l   #(TILE_EIGTH+TILE_SIXTEENTH),d2
    move.l  d2,d4
    add.l   #(TILE_EIGTH+TILE_SIXTEENTH),d4
    
    ; draw first flag diag
    move.b  #DRAW_LINE,d0
    trap    #15
    
    ; update positions for second diag
    add.l   #(TILE_QUARTER+TILE_SIXTEENTH),d2
    
    ; draw second flag diag
    trap    #15
    
    ; update positions for up flag line
    sub.l   #(TILE_EIGTH+TILE_SIXTEENTH),d4
    move.l  d1,d3
    
    ; draw up flag line
    trap    #15
    
    ; set counter
    move.l  #NUM_FLAG_FILLS,d7
    
LoopFillFlag
    ; sub d1 and d2 to fill in flag
    sub.l   #TILE_SIXTEENTH,d1
    sub.l   #TILE_SIXTEENTH,d2
    
    ; fill flag
    trap    #15
    
    ; loop
    dbra    d7,LoopFillFlag
    
    ; set fill color back to light grey
    move.b  #SET_FILL_COLOR,d0
    move.l  #LIGHT_GREY,d1
    trap    #15
    
    ; move d5 back to d1
    move.l  d5,d1
    
    jsr     RepaintScreen
    
    rts
    
DrawOverFlag

    ; save vals for later
    move.l  d1,d5
    move.l  d2,d6
    
    ; set pen color to light grey
    move.b  #SET_PEN_COLOR,d0
    move.l  #LIGHT_GREY,d1
    trap    #15
    
    ; restore d1
    move.l  d5,d1
    
    ; set positions for rect
    move.l  d1,d3
    add.l   #TILE_EIGTH,d1
    add.l   #(TILE_SIZE-TILE_EIGTH),d3
    move.l  d2,d4
    add.l   #TILE_EIGTH,d2
    add.l   #(TILE_SIZE-TILE_EIGTH),d4
    
    ; draw light grey filled box within tile (cover up flag :( )
    move.b  #DRAW_FILLED_RECT,d0
    trap    #15
    
    jsr     RepaintScreen
    
    rts
    
DrawIncorrectFlag

    ; save d1 and d2 in d5 and d6
    move.l  d1,d5
    move.l  d2,d6
    
    ; set pen width
    clr.l   d0
    move.b  #SET_PEN_WIDTH,d0
    move.w  #FLAG_POLE_WIDTH,d1
    trap    #15
   
    ; set pen color to black
    move.b  #SET_PEN_COLOR,d0
    move.l  #BLACK,d1
    trap    #15
    
    ; move positions back
    move.l  d5,d1
    
    ; set positions for first diag
    move.l  d1,d3
    add.l   #TILE_EIGTH,d1
    add.l   #(TILE_SIZE-TILE_EIGTH),d3
    move.l  d2,d4
    add.l   #TILE_EIGTH,d2
    add.l   #(TILE_SIZE-TILE_EIGTH),d4
    
    ; draw first diag
    move.b  #DRAW_LINE,d0
    trap    #15
    
    ; set positions for second diag
    move.l  d1,d3
    move.l  d5,d1
    add.l   #(TILE_SIZE-TILE_EIGTH),d1
    
    ; draw second diag
    trap    #15
    
    ; move positions back
    move.l  d5,d1
    move.l  d6,d2
    
    jsr     RepaintScreen
    
    rts
 
    



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
