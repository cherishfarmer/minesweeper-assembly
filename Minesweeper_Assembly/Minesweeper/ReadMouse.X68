*-----------------------------------------------------------
* Title      : Read Mouse
* Written by : Cherish Farmer
* Date       : 06/02/25
* Description: Uses the task that reads mouse input to store in d1 (x position) and d2 (y position).
* These values are used in FindTileClicked to find the corresponding tile the mouse clicked.
*
* Key:
* - d0: trap code -> type of click (left = 0/reveal and right = 1/flag)
* - d1: initial: y<<16+x -> mouse x
* - d2: mouse y
* - d3: keep track of time
* - a0: address of where tile data is stoed
* - a2: address of coordinates of tiles
*-----------------------------------------------------------

* EQUATES

READ_MOUSE              EQU     61

TITLE_SCREEN            EQU     00
IN_GAME                 EQU     01
END_GAME                EQU     02
RESTART_GAME            EQU     03

NO_CLICK                EQU     00      ; mouse is not currently clicking
DOUBLE_CLICK_RIGHT      EQU     $A      ; no double clicking
REVEAL_CLICK            EQU     01
FLAG_CLICK              EQU     02

GRID_TOP                EQU     START_Y
GRID_LEFT               EQU     START_X
GRID_RIGHT              EQU     START_X+GRID_SIDE_LENGTH
GRID_BOTTOM             EQU     START_Y+GRID_SIDE_LENGTH
GRID_TOP_LEFT           EQU     (GRID_TOP<<16)+GRID_LEFT
GRID_BOTTOM_RIGHT       EQU     (GRID_BOTTOM<<16)+GRID_RIGHT

CLEAR_ADDRESS           EQU     0


    ; read mouse input
ReadMouseInput
    
    ; check if player is clicking any buttons (restart game, x out, how to play)
    
    ; check if player clicks restart (smiley guy)
    jsr     CheckRestart
    cmp.l   #RESTART_GAME,(a4)
    beq     ReturnToGameLoop
    
    ; check if player xs out to main menu (x pop up)
    jsr     CheckXOut   
    cmp.l   #TITLE_SCREEN,(a4)
    beq     ReturnToGameLoop
    
    ; check if player clicked how to play button
    jsr     CheckHowToPlay
    
    ; check if player clicked mystery
    jsr     CheckMystery
   
    jsr     ClearRegisters   
   
    ; if at this point, read mouse input like the player is clicking a tile on the grid
    move.b  #READ_MOUSE,d0
    move.l  #0,d1
    trap    #15
    
    ; make sure to check state of mouse: if 0 loop through again
    cmp.b   #NO_CLICK,d0
    beq     ReturnToGameLoop  
    
    ; don't read double clicking
    cmp.b   #DOUBLE_CLICK_RIGHT,d0
    beq     ReturnToGameLoop 
    
    ; make sure coordinates are within the bounds of the grid
MouseBoundTop
    cmp.l   #GRID_TOP_LEFT,d1
    blt     ReturnToGameLoop
MouseBoundLeft
    cmp.w   #GRID_LEFT,d1
    blt     ReturnToGameLoop
MouseBoundBottom
    cmp.l   #GRID_BOTTOM_RIGHT,d1
    bgt     ReturnToGameLoop
MouseBoundRight
    cmp.w   #GRID_RIGHT,d1
    bgt     ReturnToGameLoop
    
    ; temp store d1 to update bitmap
    lea     Current_Mouse_Position,a4
    move.l  d1,(a4)
    lea     Current_Mouse_Click,a4
    move.l  d0,(a4)
    
    ; update smiley to shocked and hold while mouse is down
    jsr     SmileyShocked

    ; loop through until player lets go of mouse, maintains shocked face
MouseHeld    
    move.b  #READ_MOUSE,d0
    move.l  #0,d1
    trap    #15
    
    cmp.b   #REVEAL_CLICK,d0
    beq     MouseHeld
    
    cmp.b   #FLAG_CLICK,d0
    beq     MouseHeld
    
    ; once mouse is let go, play click sound
    jsr     PlayClickSound
    
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
    
    ; prep addresses to search tiles
    lea     Tiles,a0
    move.l  a0,a1
    adda.w  #1,a0
    lea     Coordinates,a2
    move.l  a2,a3
    move.l  #CLEAR_ADDRESS,a4
    
    ; once location is confirmed to be a tile, find corresponding tile that mouse clicked
    jsr FindTileClicked


    ; goes back to main if mouse clicked somewhere invalid (ensures jsr is returned to and not branched to)   
ReturnToGameLoop

    rts

* Stores state of mouse while loading in new bitmap for mouse held    
Current_Mouse_Position      ds.l        1
Current_Mouse_Click         ds.l        1
First_Tile_Click            ds.l        1















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
