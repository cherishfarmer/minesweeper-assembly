*-----------------------------------------------------------
* Title      : Draw Screen Border
* Written by : Cherish Farmer
* Date       : 06/03/25
* Description: Draws border around screen
*
* Key:
* - d0: task keycode
* - d1: start x
* - d2: start y
* - d3: end x
* - d4: end y
*-----------------------------------------------------------

LIGHT_GREY              EQU     $c0c0c0
DARK_GREY               EQU     $7c7c7c
HIGHLIGHT               EQU     $fcfcfc

PEN_WIDTH               EQU     4

SET_PEN_COLOR           EQU     80
SET_FILL_COLOR          EQU     81
DRAW_PIXEL              EQU     82
DRAW_LINE               EQU     84
DRAW_RECT_FILLED        EQU     87
FLOOD_FILL_AREA         EQU     89
DRAW_RECT_UNFILLED      EQU     90
SET_PEN_WIDTH           EQU     93

SCREEN_BORDER_WIDTH     EQU     4

SCREEN_OFFSET           EQU     4


DrawScreenBorder

    ; set pen width
    clr.l   d0
    move.b  #SET_PEN_WIDTH,d0
    move.w  #SCREEN_BORDER_WIDTH,d1
    trap    #15
    
    ; draw dark grey lines for screen border
    move.b  #SET_PEN_COLOR,d0
    move.l  #DARK_GREY,d1
    trap    #15
    
    ; screen dimensions: 640 x 480
    
    clr.l   d1   

    ; set coordinates (d1 and d2 are 0)
    add.w   #SCREEN_WIDTH,d3
    add.w   #SCREEN_HEIGHT,d4
    
    ; horizontal dark line
    move.b  #DRAW_LINE,d0
    move.w  d4,d2               ; y doesn't change
    trap    #15
    
    ; vertical dark line
    clr.l   d2
    move.w  d3,d1               ; x doesn't change
    trap    #15
    
    ; draw highlights for screen border
    move.b  #SET_PEN_COLOR,d0
    move.l  #HIGHLIGHT,d1
    trap    #15
    
    clr.l   d1

    ; horizontal highlight line
    move.b  #DRAW_LINE,d0
    clr.l   d4                  ; y doesn't change
    trap    #15
    
    ; vertical highlight line
    clr.l   d3                  ; x doesn't change
    add.w   #SCREEN_HEIGHT,d4 
    trap    #15

    jsr     ClearRegisters
    
    rts



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
