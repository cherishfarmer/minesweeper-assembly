*-----------------------------------------------------------
* Title      : Blank Tile Event
* Written by : Cherish Farmer
* Date       : 06/03/25
* Description: Occurs when blank tile is clicked. Updates clicked tile and checks surrounding
* tiles using BFS:
* - If also blank, call same function for that tile
* - If number, display and update tile to clicked
*
* Key:
* - d4: tile number relative to other tiles
* - d5: uses first 8 bits to determine valid tiles (see valid tile key)
* - a2: starting address of tile coordinates
* - a3: address for tile coordinates (changes)
*
* Valid tile key:
* 
*       1 2 3
*       4 X 5     8-bit determines if valid in this order: 87654321
*       6 7 8     (X = current blank tile)
*-----------------------------------------------------------

BlankTileEvent

    ; display tile as clicked and update in memory as clicked
    jsr     DrawClicked 
    
    ; clear d5 and swap back d4 for validating surrounding tiles
    clr.l   d5
    swap    d4
    
    ; check surrounding tiles - store valid tiles on stack
    ; table for implementing valid tiles (valid meaning they exist)   
    jsr     ValidateSurroundingTiles
    
    ; use d5 (flags for which tiles nearby are valid) and d4 (relative tile location) to get addresses of surrounding tiles
    ; marks current tile as done when tiles have been pushed    
    lea     BFS_Stack_Offset,a2
    lea     BFS_Stack,a3
    adda    (a2),a3
    adda    #ADDRESS_SPACE,a3
    jsr     PushSurroundingTiles
    
    ; return to click event handler, BFS stack will be checked for remaining tiles  
    jsr     CheckRemainingStack 
    rts









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
