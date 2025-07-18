*-----------------------------------------------------------
* Title      : Print Initial Board
* Written by : Cherish Farmer
* Date       : 06/02/25
* Description: Prints all empty tiles on board at beginning of game
*-----------------------------------------------------------

* EQUATES

TILE_SIZE               EQU     40
START_X                 EQU     250
START_Y                 EQU     200
END_X                   EQU     START_X+TILE_SIZE
END_Y                   EQU     START_Y+TILE_SIZE

PEN_WIDTH               EQU     4

NUM_ROW                 EQU     9
NUM_COL                 EQU     9


PrintInitialBoard

    clr.l   d6

    jsr     DrawBlankTile
    
    ; store start y and x in coordinates
    move.w  d2,(a3)+
    move.w  d1,(a3)+
    
    ; move values back
    move.w  d5,d4
    move.w  d6,d3
    move.w  d1,d5
    
    ; decrement counter
    subi.w  #1,d7
    
    ; each x increment, shift over by 50 pixels
    addi.w  #(TILE_SIZE+PEN_WIDTH),d5
    addi.w  #(TILE_SIZE+PEN_WIDTH),d3
    
    ; move counter into different register, divide by 9 and compare remainder to 0
    ; if 0, increment y
    move.w  d7,d6
    divu    #(NUM_ROW+1),d6
    swap    d6 ; can i do a bne if it sets the zero flag or do i need to do a cmp?
    cmp.w   #0,d6
    bne     PrintInitialBoard
        
    ; each y increment and reset x positions, shift down by 50 pixels
    move.w  #START_X,d5
    move.w  #END_X,d3
    addi.w  #(TILE_SIZE+PEN_WIDTH),d2
    addi.w  #(TILE_SIZE+PEN_WIDTH),d4
    
    ; dbra counter jump to print initial board
    dbra    d7,PrintInitialBoard
    
    jsr     ClearRegisters
    
    rts





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
