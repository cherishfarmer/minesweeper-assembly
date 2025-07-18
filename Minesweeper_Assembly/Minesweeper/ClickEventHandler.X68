*-----------------------------------------------------------
* Title      : Click Event Handler
* Written by : Cherish Farmer
* Date       : 06/02/25
* Description: Called when a tile is clicked and handles it depending on what type it is
* - Blank tiles: checks surrounding tiles and calls click event if not bomb or out of bounds
* - Number tiles: display
* - Bomb tiles: display and game over
*
* Key:
* - d0: type of click (left/right)
* - d1: tile x
* - d2: tile y
* - d3: type of tile stored as byte
* - d4: stores tile number relative to other tiles
* - d5: used to calculate how many bytes to traverse in a3
* - a0: address of tiles
* - a1: address of current tile
* - a2: starting address of tile coordinates
* - a3: address for tile coordinates (changes)
* - a4: loads in address to check values at those addresses
*-----------------------------------------------------------

* TILE TYPES:
*
* 00:       empty tile/0 bombs nearby
* 01-08:    number tile that indicates how many bombs are nearby
* 0A:       bomb tile
*
* Any byte starting with '1' indicates it's been clicked.
* Any byte starting with '2' indicates it's been flagged (unrevealable).

* EQUATES
GET_X_COORDINATE        EQU     2
FLAG_CLICK              EQU     02
BOMB_TILE               EQU     $A
TILE_MAX_PLUS_ONE       EQU     9


ClickEventHandler

    ; d3 contains type of tile that was clicked    
    ; get location of tile in d3
    
    ; load in address of coordinates
    lea     Coordinates,a2
    
    ; reset address of a3 to start at a2
    move.w  a2,a3
    
    ; store d5 in d4 before using d5 for calculating coordinates
    move.l  d5,d4
    swap    d4
    
    ; move to coordinates of tile in d3 d5*4 for y, same but + 2 for x
    ; shift by two because each coordinate pair (x,y) stored in a long
    lsl.w   #SHIFT_FOR_BITS,d5
    
    ; use d1 for x and d2 for y for location of tile
    move.w  (a2,d5.l),d2
    addi.w  #GET_X_COORDINATE,d5
    move.w  (a2,d5.l),d1
    
    ; event for flag click (check if d0 == 02)
    cmp.b   #FLAG_CLICK,d0
    beq     FlagTileEvent

RevealTile    
    ; event for bomb tile (check if d3 == 0A)
    cmp.w   #BOMB_TILE,d3
    beq     BombTileEvent
    
    ; event for empty tile (check if d3 == 00)
    cmp.w   #0,d3
    beq     BlankTileEvent
    
    ; event for number tile (check if d3 < 9)
    cmp.w   #TILE_MAX_PLUS_ONE,d3
    blt     DrawNumberTile
    
    ; check if anymore tiles on stack to check
CheckRemainingStack
    lea     BFS_Stack_Offset,a4
    cmp.w   #0,(a4)
    beq     ClickEventDone
    
    ; update values to next address on stack
    sub.w   #ADDRESS_SPACE,(a4)
    move.w  (a4),d0
    lea     BFS_Stack,a4
    adda    d0,a4
    adda    #(ADDRESS_SPACE*2),a4
    clr.l   d0
    
    ; update current tile address
    move.w  (a4),a1
    
    ; get tile type
    move.b  (a1),d3
    
    ; get tile position (current tile address - tiles start) in d5 then moves to d4
    move.w  a1,d5
    sub.w   a0,d5
    
    ; get x, y coordinates retrieved when going back to beginning of routine   
    jsr     ClickEventHandler

ClickEventDone    
    rts





















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
