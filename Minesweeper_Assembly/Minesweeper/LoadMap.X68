*-----------------------------------------------------------
* Title      : Load Map
* Written by : Cherish Farmer
* Date       : 06/02/25
* Description:
* Key:
* - d0: counter
* - d1: check tile type/mouse x
* - d2: mouse y/number of bombs
* - d3: calculations
* - d4: holds tile positions in beginning, moved to d5
* - d5: tile position in grid
* - d6: calculations, placeholder for bombs when generating, used to randomize bomb placement
* - d7: counter for beginning tiles that can't be clicked
* - a0: where map is stored in memory
* - a1: where map data is loaded into
* - a2: where bombs are loaded into, and then where coordinates are loaded into
* - a3: address of bomb count
* - a4: temp address for calculations
* - a5: temp address - used for bombs and checking every tile to place numbers
* - a6: temp address - used for offsets
*-----------------------------------------------------------

NO_FLAGS                EQU     0000

TILE_POS_ONE            EQU     -NUM_COL-1
TILE_POS_TWO            EQU     -NUM_COL
TILE_POS_THREE          EQU     -NUM_COL+1
TILE_POS_FOUR           EQU     -1
TILE_POS_FIVE           EQU     1
TILE_POS_SIX            EQU     NUM_COL-1
TILE_POS_SEVEN          EQU     NUM_COL
TILE_POS_EIGHT          EQU     NUM_COL+1

NUM_TILES_SURROUNDING   EQU     8 
SURROUNDING_LENGTH      EQU     18

REVEAL_CLICK            EQU     01
FLAG_CLICK              EQU     02

BOMB_TILE               EQU     $A
BLANK_TILE              EQU     00
FLAG_TILE               EQU     2

ADDRESS_SPACE           EQU     2
ONE_BEFORE              EQU     -1

START_X                 EQU     250
START_Y                 EQU     200
END_X                   EQU     START_X+TILE_SIZE
END_Y                   EQU     START_Y+TILE_SIZE

NUM_ROW                 EQU     9
NUM_COL                 EQU     9

RIGHT_MOST_BIT          EQU     1
SHIFT_FOR_BITS          EQU     2

    
LoadMap

    ; make sure click is a reveal click, not flag click
    cmp.b   #FLAG_CLICK,d0
    beq     ReadMouseInput
    
    ; set address of bomb map and grid (where it will be loaded into)
    lea     Tiles,a0
    move.l  a0,a1
    
    ; get size of bomb map
    move.w  #(Map_End-Map_Start),d0
    
    ; d4 holds tile position initially, moved to d5 to work for ValidateSurroundingTiles
    lea     Starting_Tile,a2
    lea     Starting_Surrounding,a3
    move.w  d5,d4
    move.b  #BLANK_TILE,(a0,d5.l)
    adda    d5,a1
    move.w  a1,(a2)
    move.l  a0,a1
    
    move.l  #BLANK_TILE,d3
    clr.l   d5
   
    ; check which tiles around clicked tile are real tiles
    jsr     ValidateSurroundingTiles
    
    clr.l   d7
    lea     Starting_Offset,a2
    lea     Starting_Surrounding,a3
    add.w   #ADDRESS_SPACE,(a2)
    adda    #ADDRESS_SPACE,a3
    move.w  Starting_Tile,(a3)
    jsr     PushSurroundingTiles  
    
    ; go through and randomly generate tile numbers by modding time by grid size (rows*cols) and placing bomb at that time
    ; d7 is used as a counter for beginning tiles where bombs can't be placed
    
    lea     Tiles,a0
    lea     Bombs,a5
    lea     Bombs_Offset,a6
    lea     Starting_Offset,a2
    lea     Starting_Surrounding,a3
    adda    #ADDRESS_SPACE,a3
    move.l  a0,a1


    ; generate bombs until the right number of bombs have been reached
GenerateBomb   
    move.l  a0,a1
    jsr     GenerateRandomNumber
    adda    d1,a1
    
    clr.l   d7
    clr.l   d2
    
CheckIfAvailable
    move.w  (a3,d7.l),a4
    cmp.l   a1,a4
    ; if address is first clicked or surrounding, generate new location for bomb
    beq     GenerateBomb   
    
    ; go to next address and loop if not at end
    add.w   #ADDRESS_SPACE,d7
    cmp.l   #SURROUNDING_LENGTH,d7
    blt     CheckIfAvailable
    
    ; if address already has bomb, generate new bomb location
    move.b  (a0,d1),d2
    cmp.b   #BOMB_TILE,d2
    beq     GenerateBomb
    
    ; store bomb, loop if max bombs hasn't been reached
    move.w  a1,(a5)+
    add.w   #ADDRESS_SPACE,(a6)
    add.l   #1,d6
    move.b  #BOMB_TILE,(a1)
    cmp.l   #NUM_BOMBS,d6
    bne     GenerateBomb
    
    ; loop through every tile to check surrounding to count number of bombs (do so similar to blank tile bfs)
    lea     Tiles,a0
    move.l  a0,a5
    suba    #1,a5
    ; num bombs
    clr.l   d2
    
    lea     Relative_Tile_Positions,a4
    lea     Surrounding_Tile_To_Check,a6
  
  
SetNumberTiles
    ; skip tile being checked if bomb
    ; a5 goes through each tile in grid
    clr.l   d7
    clr.l   d5
    adda    #1,a5
    move.b  (a5),d3
    cmp.b   #BOMB_TILE,d3
    beq     SetNumberTiles
    
    move.l  #CLEAR_ADDRESS,(a2)
    move.w  a5,d4
    sub.w   a0,d4
    jsr     ValidateSurroundingTiles
    lea     Relative_Tile_Positions,a4
    
    move.l  #ONE_BEFORE,d7
    jsr     CheckSurroundingBombs
    
SetCurrentNumberTile
    ; set number of surrounding bombs to tile type
    ; d2 is number of bombs surrounding a number tile
    move.b  d2,(a5)
    
    clr.l   d2
    
    ; check if at end of grid
    move.l  a5,d3
    sub.l   a0,d3
    cmp.l   #(NUM_ROW*NUM_COL),d3
    blt     SetNumberTiles

    
    lea     Incorrect_Flags_Offset,a3
    move.w  #NO_FLAGS,(a3)
    
    lea     Coordinates,a2
    move.l  a2,a3
    
    jsr     StartTime
    lea     Tiles,a0
    lea     Starting_Tile,a2
    move.w  (a2),d5
    sub.w   a0,d5
    rts

PrepInitialBoard
    jsr     ClearRegisters
    lea     Coordinates,a2
    move.l  a2,a3    
    
    ; get size of grid
    move.w  #(Map_End-Map_Start)-1+NUM_COL,d7   
 
    ; starting positions for loading in tiles
    move.w  #START_X,d5
    move.w  #START_Y,d2
    move.w  #END_X,d3
    move.w  #END_Y,d4
    
    jsr PrintInitialBoard
    
    rts
    
    
GenerateRandomNumber
    
    ; get time since midnight
    move.b  #RETURN_TIME,d0
    trap    #15
    
    ; uses a random set of numbers to randomly place bombs
    lea     Random_Offset,a4
    
    ; mod value by cols * rows TODO: optimize
    add.b  (a4,d6.l),d1
    swap    d1
    clr.w   d1
    swap    d1
    divu   #((NUM_COL*NUM_ROW)-1),d1
    clr.w   d1
    swap    d1
    
    rts
    
    
ContinueCheckingBombs
    ; move tile position so it can be manipulated in a different register
    move.l  d5,d6
    
    ; shift tile position to flag we want to check
    lsr.l   d7,d6
    and.l   #RIGHT_MOST_BIT,d6
    cmp.l   #RIGHT_MOST_BIT,d6
    bne     CheckSurroundingBombs                           ; if not flagged, loop again
    
    ; shift d7 to be number of bits offset by address (and move back) TODO: optimize this
    clr.l   d6
    lsl.l   #SHIFT_FOR_BITS,d7
    move.l  (a4,d7.l),d6
    lsr.l   #SHIFT_FOR_BITS,d7
    
    ; calculate tile to check for bomb
    add.w   d4,d6
    
CheckIfCurrentBombTile

    move.l  a0,a1
    adda    d6,a1
    move.b  (a1),(a6)
    
    ; increment num bombs if bomb tile
    cmp.b   #BOMB_TILE,(a6)
    bne     CheckSurroundingBombs
    add.l   #1,d2

    ; use d6 to check type of file at location d6 (need to account for num bytes in bits = 4)   
    ; each time a tile is found, check status of tile and push address if appropriate    
    ; if tile at location is clicked or bomb, ignore (tile type value > 08)
    ; if tile is number or blank, store address on stack to be explored after the current one is explored (tile type value <= 08)
    
CheckSurroundingBombs

    ; increment counter by 1 (used to shift flags to check for each one)
    add.l   #1,d7
    cmp.b   #NUM_TILES_SURROUNDING,d7 
    blt     ContinueCheckingBombs
    rts


* When player clicks first tile in board -- store addresses
Starting_Tile           ds.l    1
Starting_Surrounding    ds.l    9
Starting_Offset         dc.w    00

Relative_Tile_Positions
                        dc.l    TILE_POS_ONE,TILE_POS_TWO,TILE_POS_THREE,TILE_POS_FOUR,TILE_POS_FIVE,TILE_POS_SIX,TILE_POS_SEVEN,TILE_POS_EIGHT

* Used to create random numbers (values were randomly generated using a random number generator)                        
Random_Offset           
                        dc.b    27,45,61,22,71,66,7,54,77,5,74,31,69,13,4,53,75,23,60,8,53,6,0,0












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
