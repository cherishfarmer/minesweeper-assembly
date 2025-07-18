*-----------------------------------------------------------
* Title      : Minesweeper Main
* Written by : Cherish Farmer
* Date       : 05/29/25
* Description: Simulates the game Minesweeper
*-----------------------------------------------------------

* COLORS
LIGHT_GREY              EQU     $c0c0c0
DARK_GREY               EQU     $7c7c7c
HIGHLIGHT               EQU     $fcfcfc
BLACK                   EQU     $000000
CLICKED_BOMB_COLOR      EQU     $000000fe
FLAG_RED                EQU     $000000fe
WINDOWS_BLUE            EQU     $b04d10
SEGMENT_BRIGHT_RED      EQU     $1c15ac
SEGMENT_DARK_RED        EQU     $161445

* NUMBER TILE COLORS
PADDING_COLOR           EQU     0    
ONE_COLOR               EQU     $00fd0000
TWO_COLOR               EQU     $00007e01
THREE_COLOR             EQU     $000000fe
FOUR_COLOR              EQU     $00800101
FIVE_COLOR              EQU     $00010181
SIX_COLOR               EQU     $00808000
SEVEN_COLOR             EQU     $00000000
EIGHT_COLOR             EQU     $00808080 

* NUMBER TILE POSITIONS AND CALCULATION VALUES
TEXT_POS_DIVISOR        EQU     4    
MULTIPLY_4              EQU     2      
DIVIDE_4                EQU     2
SUBTRACT_2              EQU     2
ASCII_OFFSET            EQU     $30
CLICKED_OFFSET          EQU     $10

* TEXT SETTINGS
TEXT_SETTINGS           EQU     $02140001
DEFAULT_TEXT_COLOR      EQU     $00FFFFFF
DEFAULT_FONT            EQU     $00000000
HOW_TO_LOADING_POS_X    EQU     2
HOW_TO_LOADING_POS_Y    EQU     665

* SCREEN SETTINGS
SCREEN_HEIGHT           EQU     700
SCREEN_WIDTH            EQU     900
SCREEN_VALUE            EQU     (SCREEN_WIDTH<<16)+SCREEN_HEIGHT

* DRAWING PEN WIDTH
PEN_WIDTH               EQU     4
BOMB_PEN_WIDTH          EQU     3
FLAG_POLE_WIDTH         EQU     3
FLAG_WIDTH              EQU     5
TOP_UI_PEN              EQU     PEN_WIDTH/2
SCREEN_BORDER_WIDTH     EQU     4

NUM_FLAG_FILLS          EQU     2

* KEY CODES
RETURN_TIME             EQU     8
CLEAR_SCREEN            EQU     11
DISPLAY_STRING          EQU     14
SET_TEXT_COLOR          EQU     21
TIME_DELAY              EQU     23
SET_SCREEN              EQU     33
READ_MOUSE              EQU     61
PLAY_SOUND              EQU     73
SET_PEN_COLOR           EQU     80
SET_FILL_COLOR          EQU     81
DRAW_PIXEL              EQU     82
DRAW_LINE               EQU     84
DRAW_RECT_FILLED        EQU     87  *TODO: go through files and make sure only one of these is being used 
DRAW_FILLED_RECT        EQU     87
DRAW_FILLED_ELLIPSE     EQU     88
DRAW_ELLIPSE_FILLED     EQU     88  *TODO: same as above
FLOOD_FILL_AREA         EQU     89
DRAW_RECT_UNFILLED      EQU     90
DOUBLE_BUFFERING_CODE   EQU     92
SET_PEN_WIDTH           EQU     93
REPAINT_SCREEN          EQU     94
DRAW_TEXT               EQU     95 

* DOUBLE BUFFERING VALUES
DOUBLE_BUFFERING_ON     EQU     17
DOUBLE_BUFFERING_OFF    EQU     16

* CLEAR SCREEN/TEXT VALUES
CLEAR_SCREEN_VAL        EQU     $FF00
CLEAR_TEXT_START        EQU     3
CLEAR_TEXT_END_X        EQU     200
CLEAR_TEXT_END_Y        EQU     20

* TILE POSITIONS
TILE_SIZE               EQU     40
START_X                 EQU     250
START_Y                 EQU     200
END_X                   EQU     START_X+TILE_SIZE
END_Y                   EQU     START_Y+TILE_SIZE

* TILE/PRIMITIVE SIZES
TILE_HALF               EQU     TILE_SIZE/2
TILE_QUARTER            EQU     TILE_SIZE/4
TILE_EIGTH              EQU     TILE_SIZE/8
TILE_SIXTEENTH          EQU     TILE_SIZE/16
BOMB_WIDTH              EQU     TILE_SIZE-TILE_HALF
HALF_WIDTH              EQU     2

* GRID
NUM_ROW                 EQU     9
NUM_COL                 EQU     9
GRID_BOX_WIDTH          EQU     PEN_WIDTH
BORDER_OFFSET           EQU     PEN_WIDTH
GRID_SIDE_LENGTH        EQU     TILE_SIZE*(NUM_COL+1)
GRID_OUTER_OFFSET       EQU     PEN_WIDTH*4
WINDOW_OFFSET           EQU     PEN_WIDTH
TOP_UI_HEIGHT           EQU     50
TOP_UI_WIDTH            EQU     GRID_SIDE_LENGTH
SCREEN_OFFSET           EQU     4

GRID_TOP                EQU     START_Y
GRID_LEFT               EQU     START_X
GRID_RIGHT              EQU     START_X+GRID_SIDE_LENGTH
GRID_BOTTOM             EQU     START_Y+GRID_SIDE_LENGTH
GRID_TOP_LEFT           EQU     (GRID_TOP<<16)+GRID_LEFT
GRID_BOTTOM_RIGHT       EQU     (GRID_BOTTOM<<16)+GRID_RIGHT

* CALCULATION VALUES
ONE_BEFORE              EQU     -1
CLEAR_ADDRESS           EQU     0
RESET_VAL               EQU     $FFFFFFFF
ADDRESS_SPACE           EQU     2
NUM_BYTES_SKIP          EQU     NUM_COL*4
SHIFT_FOUR              EQU     4
RIGHT_MOST_BIT          EQU     1
SHIFT_FOR_BITS          EQU     2
DECIMAL                 EQU     10
NUM_BIT_FLAGS           EQU     7
SHIFT_FOR_WORD          EQU     1
GET_X_COORDINATE        EQU     2

* GAME SETTINGS
NUM_BOMBS               EQU     15
START_TIME              EQU     0

* TILE TYPES
BOMB_TILE               EQU     $A
BLANK_TILE              EQU     00
FLAG_TILE               EQU     2
CORRECT_FLAG            EQU     $0A
UNSET_TILE              EQU     $FF
TILE_MAX_PLUS_ONE       EQU     9

* TILE OFFSETS
CLICKED_OFFSET          EQU     $10
FLAGGED_OFFSET          EQU     $20

* TILE STATES/CLICKS
TILE_CLICKED            EQU     1
REVEAL_CLICK            EQU     01
FLAG_CLICK              EQU     02
DOUBLE_CLICK_LEFT       EQU     9       ; double click on main menu
NO_CLICK                EQU     00      ; mouse is not currently clicking
DOUBLE_CLICK_RIGHT      EQU     $A      ; no double clicking
REVEAL_CLICK            EQU     01      ; left click
FLAG_CLICK              EQU     02      ; right click

* GAME STATES
TITLE_SCREEN            EQU     00
IN_GAME                 EQU     01
END_GAME                EQU     02
RESTART_GAME            EQU     03

NO_TILES_LEFT           EQU     00
NO_FLAGS_LEFT           EQU     0
NO_BOMBS_LEFT           EQU     0
NO_FLAGS                EQU     0000

* RESTART BUTTON POSITIONS (SMILEY)
RESTART_TOP             EQU     $91
RESTART_LEFT            EQU     $1AA
RESTART_BOTTOM          EQU     RESTART_TOP+TILE_SIZE
RESTART_RIGHT           EQU     RESTART_LEFT+TILE_SIZE
RESTART_TOP_LEFT        EQU     (RESTART_TOP<<16)+RESTART_LEFT
RESTART_BOTTOM_RIGHT    EQU     (RESTART_BOTTOM<<16)+RESTART_RIGHT

* MAIN MENU BUTTON POSITIONS (X TAB)
X_TOP                   EQU     108
X_LEFT                  EQU     602
X_BOTTOM                EQU     X_TOP+19
X_RIGHT                 EQU     X_LEFT+58
X_TOP_LEFT              EQU     (X_TOP<<16)+X_LEFT
X_BOTTOM_RIGHT          EQU     (X_BOTTOM<<16)+X_RIGHT

* MYSTERY BUTTON POSITIONS (? ICON)
MYSTERY_TOP             EQU     0
MYSTERY_LEFT            EQU     0
MYSTERY_BOTTOM          EQU     70
MYSTERY_RIGHT           EQU     60
MYSTERY_TOP_LEFT        EQU     (MYSTERY_TOP<<16)+MYSTERY_LEFT
MYSTERY_BOTTOM_RIGHT    EQU     (MYSTERY_BOTTOM<<16)+MYSTERY_RIGHT

* START BUTTON POSITIONS (MINESWEEPER ICON MAIN MENU)
START_TOP               EQU     420
START_LEFT              EQU     415
START_BOTTOM            EQU     472
START_RIGHT             EQU     483
START_TOP_LEFT          EQU     (START_TOP<<16)+START_LEFT
START_BOTTOM_RIGHT      EQU     (START_BOTTOM<<16)+START_RIGHT

* HOW TO PLAY POSITIONS (BOTTOM LEFT -- WHERE WINDOWS START BUTTON IS)
HOW_TO_BUTTON_TOP       EQU     680
HOW_TO_BUTTON_LEFT      EQU     0
HOW_TO_BUTTON_BOTTOM    EQU     700
HOW_TO_BUTTON_RIGHT     EQU     66
HOW_TO_BUTTON_TOP_LEFT          EQU     (HOW_TO_BUTTON_TOP<<16)+HOW_TO_BUTTON_LEFT
HOW_TO_BUTTON_BOTTOM_RIGHT      EQU     (HOW_TO_BUTTON_BOTTOM<<16)+HOW_TO_BUTTON_RIGHT

* HOW TO PLAY STATES
HOW_TO_OFF              EQU     00
HOW_TO_ON               EQU     01

* FIRST TILE CLICK STATES
FIRST_TILE_CLICKED      EQU     01
FIRST_TILE_UNCLICKED    EQU     00

* BFS BITMASKS
TOP_LEFT_TILE           EQU     %11010000
TOP_TILE                EQU     %11111000
TOP_RIGHT_TILE          EQU     %01101000
RIGHT_TILE              EQU     %01101011
BOTTOM_RIGHT_TILE       EQU     %00001011
BOTTOM_TILE             EQU     %00011111
BOTTOM_LEFT_TILE        EQU     %00010110
LEFT_TILE               EQU     %11010110
MIDDLE_TILE             EQU     %11111111

* TILE POSITIONS -- USED FOR BFS SEARCHING NEARBY TILES
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

* BOMB TILE EVENT STATES/CHECKS
CLICKED_BOMB_UNSTORED   EQU     $FFFF
CLICKED_OFFSET          EQU     $10
CLICKED_BOMB            EQU     $1A
UNCLICKED_BOMB          EQU     $0A

* TIME
MOUSE_CLICK_DELAY       EQU     1
SS_TIMER_OFFSET         EQU     336
ONE_SECOND              EQU     100
CLOCK_LOOP              EQU     999
SHIFT_DELAY             EQU     7

* SEVEN SEGMENT DISPLAY
DISPLAY_ZERO            EQU     $3f
DISPLAY_ONE             EQU     $06
DISPLAY_TWO             EQU     $5b
DISPLAY_THREE           EQU     $4f
DISPLAY_FOUR            EQU     $66
DISPLAY_FIVE            EQU     $6d
DISPLAY_SIX             EQU     $7d
DISPLAY_SEVEN           EQU     $07
DISPLAY_EIGHT           EQU     $7f
DISPLAY_NINE            EQU     $6f

LEFT_DIGIT              EQU     $64
MIDDLE_DIGIT            EQU     $A
RIGHT_DIGIT             EQU     $9
MIDDLE_OFFSET           EQU     20
RIGHT_OFFSET            EQU     60
TIMER_ADDRESS_OFFSET    EQU     360

SEGMENT_WIDTH           EQU     3
SEGMENT_LENGTH          EQU     10
SS_X_OFFSET             EQU     3
SS_Y_OFFSET             EQU     6

* SMILEY POSITIONS
SMILEY_X_OFFSET         EQU     4
SMILEY_Y_OFFSET         EQU     5
SMILEY_EXPRESS_OFFSET   EQU     6

* SUNGLASSES POSITIONS/DRAWING/PHYSICS
SUNGLASSES_X            EQU     433
SUNGLASSES_Y_START      EQU     150
SUNGLASSES_Y_RECOIL     EQU     158
SUNGLASSES_Y_END        EQU     160
SUNGLASSES_LENGTH       EQU     26
SUNGLASSES_SIDE_LENGTH  EQU     3
SUNGLASSES_EYE_LENGTH   EQU     8
SUNGLASSES_MID_LENGTH   EQU     6
SUNGLASSES_SHADE_OFFSET EQU     1
SUNGLASSES_PEN_WIDTH    EQU     2
FIXED_POINT_SHIFT       EQU     1
SUNGLASSES_ACCELERATION EQU     1

    ORG    $1000
    
START:                  ; first instruction of program   
    jsr     LoadingMainMenu
    jsr     LoadMenu
    
StartAfterGoMain
    jsr     MainMenuLoaded
    
RestartGame
    jsr     ClearMemory
    jsr     LoadPopUp 
    jsr     SetBackground
    jsr     DrawGridBox
    jsr     DrawScreenBorder
    jsr     DrawSmileyStart
    jsr     PrepInitialBoard
    jsr     UpdateSevenSegment
    jsr     GameLoaded
     
    ; first click generates map   
WaitForFirstClick
    jsr     ReadMouseInput
    jsr     ClearRegisters

    cmp.l   #TITLE_SCREEN,(Game_State)
    beq     GoMainMenu
    
    jsr     SmileyNeutral
    
    cmp.l   #RESTART_GAME,(Game_State)
    beq     RestartGame
    
    ; delay when game starts (TODO: rename since delay was removed)
    ; TODO: check what last click type was and compare to determine if bitmap needs to be updated
StartDelay
    jsr     SmileyNeutral
    lea     First_Tile_Click,a2
    cmp.l   #FIRST_TILE_CLICKED,(a2)
    bne     WaitForFirstClick    

    ; continuously reads where user is clicking
ReadMouseLoop
    jsr     UpdateSevenSegment 
    jsr     ClearRegisters 
    jsr     ReadMouseInput
    jsr     ClearRegisters
    jsr     GameStateHandler
    
    cmp.l   #IN_GAME,(Game_State)
    beq     StartDelay
    
    cmp.l   #TITLE_SCREEN,(Game_State)
    beq     GoMainMenu
    
    cmp.l   #END_GAME,(Game_State)
    beq     WaitRestart
    bne     RestartGame
    
WaitRestart

    jsr     CheckRestart
    cmp.l   #RESTART_GAME,(a4)
    beq     RestartGame
    
    jsr     CheckXOut   
    cmp.l   #TITLE_SCREEN,(a4)
    beq     GoMainMenu
    
    bne     WaitRestart
    
GoMainMenu

    ; set game mode to title screen and cover up 
    
    jsr     LoadingNewGame
    jsr     LoadMainMenuRestart
    
    lea     Game_State,a4
    cmp.l   #TITLE_SCREEN,(a4)
    beq     StartAfterGoMain
    bne     WaitRestart
    
    SIMHALT             ; halt simulator

* Map start and end are used to get grid size TODO: this is probably not necessary, can adjust code
Map_Start
* Grid Data - 81 tiles for 9 x 9 grid (each tile is a byte)
Tiles                           ds.b    81
Map_End

* Coordinates of each tile in grid, every odd word is y, every even word is x
Coordinates                     ds.l    162

* Addresses of bombs in map
Bombs                           ds.l    162
* Size for bombs stack
Bombs_Offset                    dc.w    00

* Stack for BFS when blank tile clicked
BFS_Stack                       ds.l    162
* Size for BFS stack
BFS_Stack_Offset                dc.w    00

* Addresses of flags in map (used to check if any flags are incorrect if game is lost)
Incorrect_Flags                 ds.l    162
* Size for flags stack
Incorrect_Flags_Offset          dc.w    00

* Used to keep track of how many bombs have been flagged to determine if the game has been won
Real_Bomb_Counter               dc.w    NUM_BOMBS
* Used to display how many bombs left, decremented anytime a flag is placed even if it is incorrect
Fake_Bomb_Counter               dc.w    NUM_BOMBS
* Found from grid size - num bombs, used to determine if game has been won
Non_Bomb_Tiles                  dc.l    (NUM_ROW*NUM_COL)-NUM_BOMBS

* Used to keep track of time
Current_Time                    dc.l    START_TIME
* Used to calculate time throughout game
Start_Since_Midnight            ds.l    1

* Used to keep track of game state
* - 00 - title screen (default)
* - 01 - in game
* - 02 - end game 
* - 03 - reset game
Game_State                      dc.l    TITLE_SCREEN

* Keeps track if how to is open or closed (can toggle)
* - 00 - closed (default)
* - 01 - open
How_To_State                    dc.l    HOW_TO_OFF


* Includes
    include 'DrawBlankTile.X68'
    include 'ReadMouse.X68'
    include 'FindTileClicked.X68'
    include 'Timer.X68'
    include 'LoadScreen.X68'
    include 'LoadMap.X68'
    include 'PrintInitialBoard.X68'
    include 'DrawGridBox.X68'
    include 'DrawSmiley.X68'
    include 'ClickEventHandler.X68'
    include 'GameStateHandler.X68'
    include 'DrawNumberTile.X68'
    include 'BlankTileEvent.X68'
    include 'DrawClicked.X68'
    include 'DrawScreenBorder.X68'
    include 'ValidateSurroundingTiles.X68'
    include 'PushSurroundingTiles.X68'
    include 'DrawBomb.X68'
    include 'BombTileEvent.X68'
    include 'ClearMemory.X68'
    include 'FlagClickEvent.X68'
    include 'DrawFlag.X68'
    include 'SevenSegmentDisplay.X68'
    include 'MenuScreen.X68'
    include 'BitmapChunker.X68'
    include 'Sounds.X68'
    

    END    START        ; last line of source
































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
