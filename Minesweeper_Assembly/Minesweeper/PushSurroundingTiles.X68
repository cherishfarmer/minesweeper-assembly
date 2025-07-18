*-----------------------------------------------------------
* Title      : Push Surrounding Tiles
* Written by : Cherish Farmer
* Date       : 06/04/25
* Description: Pushes tiles surrounding current tile onto a stack to be checked
* Key:
* - d3: tile type
* - d4: tile number relative to other tiles
* - d5: 8 bit flag that determines which surrounding tiles exist
* - d6: used for calculations
* - d7: counter and used to shift appropriate number of bits each check
* - a0: address of where tiles are stored
* - a1: pointer to address of where tiles are stored (changes)
* - a2: address of (BFS/map generation) stack size (lea before this routine)
* - a3: address of (BFS/map generation) stack (lea before this routine)
* - a4: address of where surrounding tile tables starts
* - a5: pointer to routine in table (a4)
* - a6: address of surrounding tile to be checked
*-----------------------------------------------------------

NUM_TILES_SURROUNDING   EQU     8 
RIGHT_MOST_BIT          EQU     1
SHIFT_FOR_BITS          EQU     2

CLICKED_OFFSET          EQU     $10
ADDRESS_SPACE           EQU     2
ONE_BEFORE              EQU     -1

UNSET_TILE              EQU     $FF

ONE_BEFORE              EQU     -1

PushSurroundingTiles
    ; use each bit flag to figure out tile location relative to current tile (d4)
    ; use table of routines that each find the address of surrounding tile depending on location (8 total)
    ; figure out which flags are on by looping through anding with 1 and shifting right by 1 (8 times)
    
    ; start at negative one (ONE_BEFORE) since counter increments at beginning
    ; this is because the counter is used to shift the bitmask, and checked at the end if we reached the end of the bitmask
    move.l  #ONE_BEFORE,d7
    lea     Relative_Tile_Positions,a4
    lea     Surrounding_Tile_To_Check,a6
    
LoopFlags

    ; increment counter by 1 (used to shift flags to check for each one)
    add.l   #1,d7
    
    ; move tile position so it can be manipulated in a different register
    move.l  d5,d6
    
    ; shift tile position to flag we want to check
    lsr.l   d7,d6
    and.l   #RIGHT_MOST_BIT,d6
    cmp.l   #RIGHT_MOST_BIT,d6
    bne     CheckLoopCount                        ; if not flagged, loop again
    
    ; shift d7 to be number of bits offset by address (and move back) TODO: optimize this
    clr.l   d6
    lsl.l   #SHIFT_FOR_BITS,d7
    move.l  (a4,d7.l),d6
    lsr.l   #SHIFT_FOR_BITS,d7
    
    ; calculate tile to be pushed
    add.w   d4,d6
    jsr     CheckSurroundingType                            

    ; check if we have checked all surrounding tiles
CheckLoopCount    
    cmp.b   #NUM_TILES_SURROUNDING,d7
    beq     PushedSurroundingTiles
    bne     LoopFlags


    ; use d6 to check type of file at location d6 (need to account for num bytes in bits = 4)   
    ; each time a tile is found, check status of tile and push address if appropriate    
    ; if tile at location is clicked or bomb, ignore (tile type value > 08)
    ; if tile is number or blank, store address on stack to be explored after the current one is explored (tile type value <= 08)
CheckSurroundingType
    move.l  a0,a1
    adda    d6,a1
    move.b  (a1),(a6)
    
    ; if d6 is greater than 08, do nothing
    clr.l   d6
    move.b  (a6),d6
    cmp.l   #NUM_TILES_SURROUNDING,d6
    blt     PushAddress
    
    ; check if FF for new board
    cmp.b   #UNSET_TILE,d6
    beq     PushAddress
    rts

    ; valid address (number or blank) -> make room on stack pointer and push address onto stack pointer
PushAddress
    ; increase BFS stack size by 1/2 bytes
    add.w   #ADDRESS_SPACE,(a2)
    ; push stack top in BFS stack
    adda    #ADDRESS_SPACE,a3
    ; push address of tile checked onto BFS stack
    move.w  a1,(a3)
    rts

    ; return -> upon return push next available (if any) address to current (find tile coordinates, tile type, and position)    
PushedSurroundingTiles
    ; mark current tile as done
    move.b  #CLICKED_OFFSET,d3
    
    ; move current tile back to original location
    move.b  d3,(a0,d4.l)
    
    jsr     ClearRegisters
    move.l  #CLEAR_ADDRESS,a2
    move.l  #CLEAR_ADDRESS,a3
    move.l  #CLEAR_ADDRESS,a4
    move.l  #CLEAR_ADDRESS,a5
    move.l  #CLEAR_ADDRESS,a6
    rts
    
Surrounding_Tile_To_Check
                ds.b    1
Padding_Check
                ds.b    1








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
