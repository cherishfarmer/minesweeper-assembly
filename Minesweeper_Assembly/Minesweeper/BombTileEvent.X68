*-----------------------------------------------------------
* Title      : Bomb Tile Event
* Written by : Cherish Farmer
* Date       : 06/05/25
* Description:
* Key: 
* - d3: type of tile stored as byte
* - d4: stores tile number relative to other tiles
* - d5: used to calculate how many bytes to traverse in a3
* - a0: address of tiles
* - a1: address of current tile
* - a2: starting address of tile coordinates
* - a3: address for tile coordinates (changes)
* - a4: loads in address to check values at those addresses
*-----------------------------------------------------------

* EQUATES
CLICKED_OFFSET          EQU     $10
SUBTRACT_2              EQU     2
DIVIDE_4                EQU     2
CLICKED_BOMB_UNSTORED   EQU     $FFFF
UNCLICKED_BOMB          EQU     $0A

BombTileEvent

    ; set current bomb as clicked so it doesn't get overwritten (if clicked bomb address is empty)
    addi.w  #CLICKED_OFFSET,d3
    sub.w   #SUBTRACT_2,d5     ; subtract 2 since we added earlier
    lsr.w   #DIVIDE_4,d5       ; divide by 4 since we multiplied earlier
    move.b  d3,(a0,d5.l)
    
    ; store bomb clicked by player so background doesn't get overwritten
    lea     Clicked_Bomb_Address,a4
    cmp.w   #CLICKED_BOMB_UNSTORED,(a4)
    bne     DisplayBomb
    
    ; if address not stored, store bomb address so that first bomb will be shown as clicked bomb
    adda    d5,a1
    move.w  a1,(a4)                 
        
    ; draw current bomb with red background
    jsr     DrawClickedBomb
    
* TODO: make displaying all bombs and incorrect flags each their own subroutine
* currently they both call to click event handler with each value in each stack,
* so each one loops through click event handler, but this can be optimized

DisplayBomb
    jsr     DrawBomb
           
    ; go through entire grid and expose all bombs
    ; use stack to store addresses of bombs
    ; use each address for position to draw each one
    ; traverse through addresses until values are invalid (FFFF)
CheckRemainingBombs

    ; load in offset of addresses of bombs (if 0 we have gone through all the bombs)
    lea     Bombs_Offset,a4
    cmp.w   #0,(a4)
    
    ; once all bombs are displayed, cross out any flags placed in the wrong spot                                
    beq     CheckIncorrectFlags    
    
    ; go to next bomb
    sub.w   #ADDRESS_SPACE,(a4)
    move.w  (a4),d0
    lea     Bombs,a4
    adda    d0,a4
    clr.l   d0
    
    ; update current tile address
    move.w  a0,a1
    move.w  (a4),a1
    
    ; get tile type
    move.b  (a1),d3
    cmp.w   #UNCLICKED_BOMB,d3
    bne     CheckRemainingBombs
    
    ; get tile position (current tile address - tiles start) in d5 then moves to d4 TODO: go back to previous files to sync
    move.w  a1,d5
    sub.w   a0,d5
    
    ; get x, y coordinates retrieved when going back to beginning of routine   
    jsr     ClickEventHandler
    
    rts
    
    
    ; show incorrect flag as marked out once bombs have been revealed
ShowIncorrectFlag
    
    jsr     DrawIncorrectFlag
    jsr     ClearRegisters
    
    ; iterate through checked flags list -- make sure they are still flagged
CheckIncorrectFlags

    lea     Incorrect_Flags_Offset,a6
    cmp.w   #0,(a6)
    
    beq     AllFlagsChecked
  
    sub.w   #ADDRESS_SPACE,(a6)
    move.w  (a6),d0
    lea     Incorrect_Flags,a5
    adda    d0,a5
    clr.l   d0
    
    ; update current tile address
    move.w  a0,a1
    move.w  (a5),a1
    
    ; get tile type (check if still flagged)
    move.b  (a1),d3
    move.b  d3,d6
    lsr.b   #SHIFT_FOUR,d6
    cmp.w   #FLAG_TILE,d6
    bne     CheckIncorrectFlags
    
    ; get tile position (current tile - tiles start)
    move.w  a1,d5
    sub.w   a0,d5
    move.b  #FLAG_CLICK,d0
    
    ; get coordinates
    jsr     ClickEventHandler
    
    rts  
    
    ; once all flags are checked, trigger lose game event    
AllFlagsChecked

    jsr     GameLoseEvent
    rts

    

* Address of clicked bomb -- used to differentiate so that it appears with a red background    
Clicked_Bomb_Address    ds.w    1










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
