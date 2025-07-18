*-----------------------------------------------------------
* Title      : Validate Surrounding Tiles
* Written by : Cherish Farmer
* Date       : 06/04/25
* Description: Checks surrounding tiles to see if they exist
*
* Key:
* - d4: tile number relative to other tiles
* - d5: uses first 8 bits to determine valid tiles (see valid tile key)
* - a4: loads in table of validation
*
* Valid tile key:
* 
*       1 2 3
*       4 X 5     8-bit flag in d5 determines if tiles exist around X in this order: 87654321
*       6 7 8     (X = current blank tile)

*-----------------------------------------------------------

* EQUATES
SHIFT_FOR_WORD          EQU     1
CLEAR_ADDRESS           EQU     0

ValidateSurroundingTiles
    
    lea     Table_Of_Validation,a4
    lsl.l   #SHIFT_FOR_WORD,d4
    move.w  (a4,d4.l),d5
    lsr.l   #SHIFT_FOR_WORD,d4
    move.l  #CLEAR_ADDRESS,a4
    
    rts
    
* Stores each bitmask depending on tile position
Table_Of_Validation
            * 0-8
            dc.w    TOP_LEFT_TILE,TOP_TILE,TOP_TILE,TOP_TILE,TOP_TILE,TOP_TILE,TOP_TILE,TOP_TILE,TOP_RIGHT_TILE
            * 9-17
            dc.w    LEFT_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,RIGHT_TILE
            * 18-26
            dc.w    LEFT_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,RIGHT_TILE
            * 27-35
            dc.w    LEFT_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,RIGHT_TILE
            * 36-44
            dc.w    LEFT_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,RIGHT_TILE
            * 45-53
            dc.w    LEFT_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,RIGHT_TILE
            * 54-62
            dc.w    LEFT_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,RIGHT_TILE
            * 63-71
            dc.w    LEFT_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,MIDDLE_TILE,RIGHT_TILE
            * 72-80
            dc.w    BOTTOM_LEFT_TILE,BOTTOM_TILE,BOTTOM_TILE,BOTTOM_TILE,BOTTOM_TILE,BOTTOM_TILE,BOTTOM_TILE,BOTTOM_TILE,BOTTOM_RIGHT_TILE
            * padding
            ds.w    3









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
