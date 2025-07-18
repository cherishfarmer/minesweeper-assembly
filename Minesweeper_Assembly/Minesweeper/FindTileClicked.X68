*-----------------------------------------------------------
* Title      : Find Tile Clicked
* Written by : Cherish Farmer
* Date       : 06/03/25
* Description:
* Looping through rows and columns:
* - Count number of rows, and after row is found, multiply that number by number of columns (number of tiles in each row) (d4)
* - Count columns in row to tile. Add d4 to d5
* Tile size is added to each value to encompass limit of tile. When d1 or d2 is greater than d3, that means it will be the tile/row
* before d3 
*
* Key:
* - d0: type of click (left = 0/reveal and right = 1/flag)* - d1: x position of mouse
* - d2: y position of mouse
* - d3: current x/y value being compared after adding tile size
* - d4: used to check 4th bit of d3 to determine tile type
* - d5: counts number of tiles in row to get to desired tile
* - a0: address to where tiles are stored
* - a1: pointer to current tile clicked in grid
* - a2: holds pointer to coordinate values (not modified)
* - a3: address pointing to coordinate values, where d3 gets values from
*-----------------------------------------------------------

* EQUATES

NUM_BYTES_SKIP          EQU     NUM_COL*4
SHIFT_FOUR              EQU     4

TILE_CLICKED            EQU     1

REVEAL_CLICK            EQU     01
FLAG_CLICK              EQU     02

TILE_SIZE               EQU     40
NUM_ROW                 EQU     9
NUM_COL                 EQU     9

FIRST_TILE_CLICKED      EQU     01
FIRST_TILE_UNCLICKED    EQU     00


FindTileClicked
    ; move address for coordinates into new address since it will be modified
    move.w  a2,a3
    
    ; count tiles in d5
    ; start at 0 for zero-based indexing
    clr.w   d5
    
    ; motor (only moves one word to loop through only y values)           
    move.w  (a3)+,d3        ; first y value
    addi.w  #TILE_SIZE,d3
    ; reset address
    move.w  a2,a3   
    cmp.w   d2,d3
    bgt     LoopCols        ; if d2 is less than d3, tile is in first row
    
    ; find row that y value (d2) falls within
LoopRows
    addi.w  #NUM_COL,d5     ; incremenet by number of tiles in each row (number of columns)
    adda.w  #NUM_BYTES_SKIP,a3    
    move.w  (a3),d3         ; move to next row
    addi.w  #TILE_SIZE,d3
    cmp.w   d2,d3
    blt     LoopRows   

LoopCols    
    ; find col that x value (d1) falls within
    addi.w  #1,d5           ; increment number of tiles
    adda.w  #2,a3           ; add 2 to address to skip y values
    move.w  (a3)+,d3        ; move twice for x values
    addi.w  #TILE_SIZE,d3
    cmp.w   d1,d3
    blt     LoopCols
    
    ; go back 1 tile
    subi.w  #1,d5

CalculateTilePosition
    
    ; reset map pointer to be -1, reset d3 to store tile
    suba.w  #1,a0
    move.w  a0,a1
    clr.w   d3
    
    ; check if first time clicked
    lea     First_Tile_Click,a2
    cmp.l   #FIRST_TILE_CLICKED,(a2)
    beq     MapAlreadyGenerated
    ; if first time clicked, generate map
    move.l  #FIRST_TILE_CLICKED,(a2)
    jsr     StartTime
    jsr     LoadMap
    ;lea     Coordinates,a2
    ;move.w  a2,a3
    ;move.w  a0,a1
    
    
    ; retrieve mouse position and put back in d1
    lea     Current_Mouse_Position,a4
    move.l  (a4),d1
    lea     Current_Mouse_Click,a4
    move.l  (a4),d0
    
    ; store x in d1 and y in d2
    swap    d1
    move.w  d1,d2
    clr.w   d1
    swap    d1
    
 
MapAlreadyGenerated
    lea     Coordinates,a2
    move.w  a2,a3
    move.w  a0,a1   
    ; check status of tile and move to d3
    move.b  (a1,d5.l),d3
    
    ; clear mouse input coordinates to make space for tile coordinates
    clr.l   d1
    clr.l   d2
    
    ; if not clicked or flagged (byte starts with 0), trigger event (change to if upper nybble is not equal to 1)
    move.b  d3,d4
    lsr.b   #SHIFT_FOUR,d4 ; shift by 4 to check upper bits in word
    cmp.b   #TILE_CLICKED,d4
    beq     AlreadyClicked
    
    jsr     ClickEventHandler
    
    ; if clicked, return (don't do anything)
AlreadyClicked 
    rts
    











*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
