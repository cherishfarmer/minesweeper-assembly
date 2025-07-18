*-----------------------------------------------------------
* Title      : Clear Memory
* Written by : Cherish Farmer
* Date       : 06/06/25
* Description: Clears/resets memory to be used for a new game.
* Also handles when certain game state-changing buttons are clicked,
* such as restarting (smiley), clicking to go to main menu (pop up x), clicking on how to play (bottom left), and clicking the start button (minesweeper icon)
*-----------------------------------------------------------

* EQUATES
DOUBLE_CLICK_LEFT       EQU     9
RESET_VAL               EQU     $FFFFFFFF
CLEAR_ADDRESS           EQU     0
UNSET_TILE              EQU     $FF
IN_GAME                 EQU     01
RESTART_GAME            EQU     03
NO_FLAGS                EQU     0000

RESTART_TOP             EQU     $91
RESTART_LEFT            EQU     $1AA
RESTART_BOTTOM          EQU     RESTART_TOP+TILE_SIZE
RESTART_RIGHT           EQU     RESTART_LEFT+TILE_SIZE
RESTART_TOP_LEFT        EQU     (RESTART_TOP<<16)+RESTART_LEFT
RESTART_BOTTOM_RIGHT    EQU     (RESTART_BOTTOM<<16)+RESTART_RIGHT

X_TOP                   EQU     108
X_LEFT                  EQU     602
X_BOTTOM                EQU     X_TOP+19
X_RIGHT                 EQU     X_LEFT+58
X_TOP_LEFT              EQU     (X_TOP<<16)+X_LEFT
X_BOTTOM_RIGHT          EQU     (X_BOTTOM<<16)+X_RIGHT

HOW_TO_BUTTON_TOP       EQU     680
HOW_TO_BUTTON_LEFT      EQU     0
HOW_TO_BUTTON_BOTTOM    EQU     700
HOW_TO_BUTTON_RIGHT     EQU     66
HOW_TO_BUTTON_TOP_LEFT          EQU     (HOW_TO_BUTTON_TOP<<16)+HOW_TO_BUTTON_LEFT
HOW_TO_BUTTON_BOTTOM_RIGHT      EQU     (HOW_TO_BUTTON_BOTTOM<<16)+HOW_TO_BUTTON_RIGHT

START_TOP               EQU     420
START_LEFT              EQU     415
START_BOTTOM            EQU     472
START_RIGHT             EQU     483
START_TOP_LEFT          EQU     (START_TOP<<16)+START_LEFT
START_BOTTOM_RIGHT      EQU     (START_BOTTOM<<16)+START_RIGHT


ClearMemory
    jsr ClearRegisters
    jsr ClearAddresses
    
    lea     Bombs_Offset,a0
    move.w  #CLEAR_ADDRESS,(a0)
    lea     BFS_Stack_Offset,a0
    move.w  #CLEAR_ADDRESS,(a0)
    lea     CLICKED_BOMB_ADDRESS,a0
    move.w  #CLICKED_BOMB_UNSTORED,(a0)
    lea     Incorrect_Flags_Offset,a0
    move.w  #NO_FLAGS,(a0)
    lea     Real_Bomb_Counter,a0
    move.w  #NUM_BOMBS,(a0)
    lea     Fake_Bomb_Counter,a0
    move.w  #NUM_BOMBS,(a0)
    lea     Game_State,a0
    move.l  #IN_GAME,(a0)
    lea     Current_Time,a0
    move.l  #RESET_VAL,(a0)
    lea     Non_Bomb_Tiles,a0
    move.l  #((NUM_ROW*NUM_COL)-NUM_BOMBS),(a0)
    lea     First_Tile_Click,a0
    move.l  #RESET_VAL,(a0)
    lea     Starting_Tile,a0
    move.l  #CLEAR_ADDRESS,(a0)
    lea     Starting_Offset,a0
    move.l  #CLEAR_ADDRESS,(a0)
    lea     Current_Mouse_Position,a0
    move.l  #RESET_VAL,(a0)
    lea     Current_Mouse_Click,a0
    move.l  #RESET_VAL,(a0)
    lea     Last_Recorded_Bomb_Display,a0
    move.l  #RESET_VAL,(a0)
    
    move.w  #(Map_End-Map_Start),d0
    lea     Tiles,a0
ClearPreviousMap
    move.b  #UNSET_TILE,(a0)+
    dbra    d0,ClearPreviousMap

    move.w  #(Incorrect_Flags_Offset-Incorrect_Flags),d0
    lea     Incorrect_Flags,a0
ClearIncorrectFlags
    move.b  #RESET_VAL,(a0)+
    dbra    d0,ClearIncorrectFlags
    
    rts
    
    
ClearAddresses
    move.l  #CLEAR_ADDRESS,a0
    move.l  #CLEAR_ADDRESS,a1
    move.l  #CLEAR_ADDRESS,a2
    move.l  #CLEAR_ADDRESS,a3
    move.l  #CLEAR_ADDRESS,a4
    move.l  #CLEAR_ADDRESS,a5
    move.l  #CLEAR_ADDRESS,a6
    
    rts

    
RepaintScreen
    move.b  #REPAINT_SCREEN,d0
    trap    #15
    rts
  
  
CheckRestart
    ; loop through until player clicks on bitmap smiley
    ; once clicked, restart game
    
    lea     Game_State,a4
    
    move.b  #READ_MOUSE,d0
    move.l  #0,d1
    trap    #15
    
    ; make sure to check state of mouse: if 0 loop through again
    cmp.b   #NO_CLICK,d0
    beq     ContinueCurrentGameState   
    
    ; check if mouse is clicking restart button 
WaitRestartBoundTop
    cmp.l   #RESTART_TOP_LEFT,d1
    blt     ContinueCurrentGameState
WaitRestartBoundLeft
    cmp.w   #RESTART_LEFT,d1
    blt     ContinueCurrentGameState
WaitRestartBoundBottom
    cmp.l   #RESTART_BOTTOM_RIGHT,d1
    bgt     ContinueCurrentGameState
WaitRestartBoundRight
    cmp.w   #RESTART_RIGHT,d1
    bgt     ContinueCurrentGameState
    
    ; if made it all the way through, set the game state to title screen
    move.l  #RESTART_GAME,(a4)
    jsr     PlayClickSound
    rts

    
CheckXOut
    ; exits to main menu when clicked
    
    lea     Game_State,a4
    
    move.b  #READ_MOUSE,d0
    move.l  #0,d1
    trap    #15
    
    ; make sure to check state of mouse: if 0 loop through again
    cmp.b   #NO_CLICK,d0
    beq     ContinueCurrentGameState   
    
    ; check if mouse is clicking restart button 
CheckXBoundTop
    cmp.l   #X_TOP_LEFT,d1
    blt     ContinueCurrentGameState
CheckXBoundLeft
    cmp.w   #X_LEFT,d1
    blt     ContinueCurrentGameState
CheckXBoundBottom
    cmp.l   #X_BOTTOM_RIGHT,d1
    bgt     ContinueCurrentGameState
CheckXBoundRight
    cmp.w   #X_RIGHT,d1
    bgt     ContinueCurrentGameState
    
    ; if made it all the way through, set the game state to title screen
    move.l  #TITLE_SCREEN,(a4)
    jsr     PlayClickSound
    rts
    
    
CheckHowToPlay
    ; opens/closes how to play
    
    move.b  #READ_MOUSE,d0
    move.l  #0,d1
    trap    #15
    
    ; make sure to check state of mouse: if 0 loop through again
    cmp.b   #NO_CLICK,d0
    beq     ContinueCurrentGameState   
    
    ; check if mouse is clicking restart button 
CheckHowToPlayBoundTop
    cmp.l   #HOW_TO_BUTTON_TOP_LEFT,d1
    blt     ContinueCurrentGameState
CheckHowToPlayBoundLeft
    cmp.w   #HOW_TO_BUTTON_LEFT,d1
    blt     ContinueCurrentGameState
CheckHowToPlayBoundBottom
    cmp.l   #HOW_TO_BUTTON_BOTTOM_RIGHT,d1
    bgt     ContinueCurrentGameState
CheckHowToPlayBoundRight
    cmp.w   #HOW_TO_BUTTON_RIGHT,d1
    bgt     ContinueCurrentGameState
    
    ; if made it all the way through, update how to play state
    jsr     PlayClickSound
    jsr     UpdateHowToState
    
    ; repaint screen
    jsr     RepaintScreen    
    jsr     ClearRegisters
    jsr     ClearAddresses
    rts
    
CheckMystery

    move.b  #READ_MOUSE,d0
    move.l  #0,d1
    trap    #15
    
    ; only start game when double click
    cmp.b   #DOUBLE_CLICK_LEFT,d0
    bne     ContinueCurrentGameState   
    
    ; check if mouse is clicking restart button 
MysteryBoundTop
    cmp.l   #MYSTERY_TOP_LEFT,d1
    blt     ContinueCurrentGameState
MysteryBoundLeft
    cmp.w   #MYSTERY_LEFT,d1
    blt     ContinueCurrentGameState
MysteryBoundBottom
    cmp.l   #MYSTERY_BOTTOM_RIGHT,d1
    bgt     ContinueCurrentGameState
MysteryBoundRight
    cmp.w   #MYSTERY_RIGHT,d1
    bgt     ContinueCurrentGameState
    
    ; if made it all the way through, load in mystery
    jsr     PlayClickSound
    
    ; draw mystery image
    move.l  #(START_X+(GRID_SIDE_LENGTH/2)-(TILE_SIZE/2)-SMILEY_X_OFFSET+3),d5   
    move.w  #(START_Y-TOP_UI_HEIGHT-SMILEY_Y_OFFSET+2),d2                         
    jsr     LoadMystery
    jsr     RepaintScreen
    
    lea     Game_State,a0
    cmp.l   #IN_GAME,(a0)
    bne     ContinueCurrentGameState
    
    ; redraw smiley guy if in game
    move.l  #(START_X+(GRID_SIDE_LENGTH/2)-(TILE_SIZE/2)-SMILEY_X_OFFSET+3),d5   
    move.w  #(START_Y-TOP_UI_HEIGHT-SMILEY_Y_OFFSET+2),d2
    jsr     LoadStartSmiley
    
    rts
    
    
ContinueCurrentGameState
    rts


WaitStart

    jsr     CheckHowToPlay
    jsr     CheckMystery
    
    move.b  #READ_MOUSE,d0
    move.l  #0,d1
    trap    #15
    
    ; only start game when double click
    cmp.b   #DOUBLE_CLICK_LEFT,d0
    bne     WaitStart   
    
    ; check if mouse is clicking restart button 
WaitStartBoundTop
    cmp.l   #START_TOP_LEFT,d1
    blt     WaitStart
WaitStartBoundLeft
    cmp.w   #START_LEFT,d1
    blt     WaitStart
WaitStartBoundBottom
    cmp.l   #START_BOTTOM_RIGHT,d1
    bgt     WaitStart
WaitStartBoundRight
    cmp.w   #START_RIGHT,d1
    bgt     WaitStart
    
    ; if made it all the way through, go back to main and load game
    rts

    
    
ClearRegisters

    clr.l   d0
    clr.l   d1
    clr.l   d2
    clr.l   d3
    clr.l   d4
    clr.l   d5
    clr.l   d6
    clr.l   d7
    
    rts



















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
