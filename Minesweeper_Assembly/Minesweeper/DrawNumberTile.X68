*-----------------------------------------------------------
* Title      : Draw Number Tile
* Written by : Cherish Farmer
* Date       : 06/02/25
* Description: Draws a number tile after it's been clicked, displaying the number of bombs touching that tile.
* Key:
* - d0: used for task codes
* - d1: tile x
* - d2: tile y
* - d3: tile type (byte)
* - d4: temp stores x
* - d5: offset used for putting back updated tile (upper nybble becomes 1 to mark as clicked)
* - d6: temp stores y
* - d7: calculates and stores number in ascii to print out
* - a0: points to where tiles are stored
* - a1: used to point to ascii number to print out
*-----------------------------------------------------------
    
    ; put in equates for number colors

PADDING_COLOR       EQU 0    
ONE_COLOR           EQU $00fd0000
TWO_COLOR           EQU $00007e01
THREE_COLOR         EQU $000000fe
FOUR_COLOR          EQU $00800101
FIVE_COLOR          EQU $00010181
SIX_COLOR           EQU $00808000
SEVEN_COLOR         EQU $00000000
EIGHT_COLOR         EQU $00808080 
    
TEXT_POS_DIVISOR    EQU 4    
MULTIPLY_4          EQU 2       ;TODO: consolidate
DIVIDE_4            EQU 2
SUBTRACT_2          EQU 2
ASCII_OFFSET        EQU $30
CLICKED_OFFSET      EQU $10

SET_TEXT_COLOR      EQU 21
TEXT_SETTINGS       EQU $02140001   
DRAW_TEXT           EQU 95 

DrawNumberTile

    ; retrieve tile coordinates beforehand (x=d1,y=d2)

    ; swap d3 to store for later (TODO: store more optimally, consider stack)
    swap    d3
    jsr     DrawClicked
    swap    d3
    
    ; draw text at x,y + tile width / 4 
    addi.w  #(TILE_SIZE/TEXT_POS_DIVISOR),d1
    addi.w  #(TILE_SIZE/TEXT_POS_DIVISOR),d2
    
    ; set look up table for colors by lea into a4 (move d1 into d4)
    lea     Color_Table,a4
    move.w  d1,d4
    move.w  d3,d6       ; to multiply for longs
    lsl.w   #MULTIPLY_4,d6
    move.l  (a4,d6.l),d1
    
    ; move d2 to not affect text
    move.w  d2,d6
    move.l  #TEXT_SETTINGS,d2
    
    ; set text color
    move.l  #SET_TEXT_COLOR,d0
    trap    #15
    
    lea     Number_To_Display,a1
    move.b  d3,d7
    addi.l  #ASCII_OFFSET,d7
    swap    d7
    lsl.l   #8,d7
    move.l  d7,(a1)
    
    ; move d4 back into d1 for x pos and d6 to d2 for y pos
    move.l  d4,d1
    move.l  d6,d2
    
    ; set to draw text
    move.b  #DRAW_TEXT,d0
    trap    #15
    
    ; clear where ascii number is stored
    clr.l   (a1)
    
    ; set tile to clicked
    addi.w  #CLICKED_OFFSET,d3
    
    sub.w   #SUBTRACT_2,d5     ; subtract 2 since we added earlier
    lsr.w   #DIVIDE_4,d5       ; divide by 4 since we multiplied earlier
    move.b  d3,(a0,d5.l)       ; update byte to clicked value
    
    jsr     RepaintScreen

ReturnToClickEventHandler    
    ; after we update, return back to click event handler
    jsr     ClickEventHandler
    rts
    
Color_Table
            *1-8
            dc.l    PADDING_COLOR,ONE_COLOR,TWO_COLOR,THREE_COLOR,FOUR_COLOR,FIVE_COLOR,SIX_COLOR,SEVEN_COLOR,EIGHT_COLOR
Number_To_Display
            ds.l    1










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
