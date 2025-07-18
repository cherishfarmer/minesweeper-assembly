*-----------------------------------------------------------
* Title      : Flag Click Event
* Written by : Cherish Farmer
* Date       : 06/06/25
* Description: Triggered when tile is left clicked to place or remove flag
* Shows flag correctness at end of game (incorrect flags are marked out)
* Key:
* - d0: type of click (left/right)
* - d1: tile x
* - d2: tile y
* - d3: type of tile stored as byte
* - d4: stores tile number relative to other tiles
* - d5: used to calculate how many bytes to traverse in a3
* - d6: used for calculations
* - a0: address of tiles
* - a1: address of current tile
* - a2: starting address of tile coordinates
* - a3: address for tile coordinates (changes)
* - a4: loads in address to check values at those addresses
* - a5: address for flags
* - a6: flags offset
*-----------------------------------------------------------

* EQUATES
FLAGGED_OFFSET          EQU     $20
FLAG_TILE               EQU     2
CORRECT_FLAG            EQU     $0A
NO_FLAGS_LEFT           EQU     0
NO_BOMBS_LEFT           EQU     0


    ; check d3 for tile type and check upper nybble
    ; upper nybble = 0 -> need to mark tile as flagged and update
    ; upper nybble = 2 -> need to unmark tile as flagged and update
FlagTileEvent
    
    lea     Clicked_Bomb_Address,a4
    cmp.w   #CLICKED_BOMB_UNSTORED,(a4)
    bne     ShowIncorrectFlag
    
    swap    d4
    move.b  d3,d5
    lsr.b   #SHIFT_FOUR,d5
    cmp.b   #FLAG_TILE,d5
    beq     RemovingFlag

    ; if fake bombs doesnt equal 0, proceed
    ; if it does, rts
PlacingFlag
    lea     Fake_Bomb_Counter,a4
    cmp.w   #NO_FLAGS_LEFT,(a4)
    bne     DecrementFakeBombs
    beq     AtFlagMax
    
DecrementFakeBombs
    sub.w   #1,(a4)
    move.l  #CLEAR_ADDRESS,a4

    ; check tile to type to see if flag is actually for bomb
    cmp.b   #CORRECT_FLAG,d3
    bne     IncrementIncorrectFlags
    
DecrementRealBombs
    lea     Real_Bomb_Counter,a4
    sub.w   #1,(a4)
    move.l  #CLEAR_ADDRESS,a4
    jsr     PlaceFlag
    rts

    ; increase incorrect flag offset by address space and push address onto incorrect flag stack
IncrementIncorrectFlags    
    lea     Incorrect_Flags,a5   
    move.w  a1,d7
    add.w   d4,d7
    
    ; check if address is already stored
CheckIfIncorrectAlreadyStored
    move.w  (a5)+,d6
    cmp.w   d6,d7
    beq     PlaceFlag
    cmp.w   #RESET_VAL,d6
    bne     CheckIfIncorrectAlreadyStored
    
    lea     Incorrect_Flags,a5
    lea     Incorrect_Flags_Offset,a6
    move.w  (a6),d6
    adda    d4,a1
    move.w  a1,(a5,d6.l)
    add.w   #ADDRESS_SPACE,(a6)
    move.l  #CLEAR_ADDRESS,a5
    move.l  #CLEAR_ADDRESS,a6

    ; blank -> flagged
    ; - draw flag on top of tile
    ; - update state of current tile by adding offset of $20
    ; - put tile back in address and bra to read mouse input
PlaceFlag       
    
    add.l   #FLAGGED_OFFSET,d3
    move.b  d3,(a0,d4.l)
    jsr     DrawFlag
    
    rts

    ; flagged -> blank
    ; - draw background on top of tile
    ; - update state of current tile by subtracting offset of $20
    ; - put tile back in address and bra to read mouse input
RemovingFlag 
    
    sub.l   #FLAGGED_OFFSET,d3
    move.b  d3,(a0,d4.l)
    
    ; if tile was a bomb tile, increment total of real bombs
    cmp.w   #CORRECT_FLAG,d3
    bne     IncrementFakeBombs
    lea     Real_Bomb_Counter,a4 
    add.w   #1,(a4)
    move.l  #CLEAR_ADDRESS,a4   

    ; increment number of fake bombs left after removing flag
IncrementFakeBombs    
    lea     Fake_Bomb_Counter,a4
    add.w   #1,(a4)
    move.l  #CLEAR_ADDRESS,a4
    
    jsr     DrawOverFlag
    
    rts

    ; Some versions of minesweeper allow for negative bombs left when more flags have been placed than bombs
    ; I did not get around to this, so I capped number of flags that can be placed as the number of bombs on the map
    ; Called after placing a flag and the max number of bombs have been reached  
AtFlagMax

    rts

    









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
