*-----------------------------------------------------------
* Title      : LoadScreen
* Written by : Cherish Farmer
* Date       : 06/02/25
* Description: Loads screen and displays any loading segments for bitmaps
*-----------------------------------------------------------

* EQUATES

LIGHT_GREY                      EQU     $c0c0c0
BLACK                           EQU     $000000

CLEAR_SCREEN                    EQU     11
DISPLAY_STRING                  EQU     14
SET_TEXT_COLOR                  EQU     21
SET_FILL_COLOR                  EQU     81
DOUBLE_BUFFERING_CODE           EQU     92
REPAINT_SCREEN                  EQU     94
SET_SCREEN                      EQU     33

DOUBLE_BUFFERING_ON             EQU     17
DOUBLE_BUFFERING_OFF            EQU     16
CLEAR_SCREEN_VAL                EQU     $FF00

CLEAR_TEXT_START                EQU     3
CLEAR_TEXT_END_X                EQU     200
CLEAR_TEXT_END_Y                EQU     20

DEFAULT_TEXT_COLOR              EQU     $00FFFFFF
DEFAULT_FONT                    EQU     $00000000

SCREEN_HEIGHT                   EQU     700
SCREEN_WIDTH                    EQU     900
SCREEN_VALUE                    EQU     (SCREEN_WIDTH<<16)+SCREEN_HEIGHT

START_X                         EQU     250
START_Y                         EQU     200
NUM_ROW                         EQU     9
NUM_COL                         EQU     9
GRID_BOX_WIDTH                  EQU     PEN_WIDTH
BORDER_OFFSET                   EQU     PEN_WIDTH
GRID_SIDE_LENGTH                EQU     TILE_SIZE*(NUM_COL+1)
GRID_OUTER_OFFSET               EQU     PEN_WIDTH*4
WINDOW_OFFSET                   EQU     PEN_WIDTH
TOP_UI_HEIGHT                   EQU     50
TOP_UI_WIDTH                    EQU     GRID_SIDE_LENGTH
SCREEN_OFFSET                   EQU     4

TITLE_SCREEN                    EQU     00
IN_GAME                         EQU     01
END_GAME                        EQU     02
RESTART_GAME                    EQU     03

    ; loading screen
LoadingMainMenu

    ; enable double buffering
    move.b  #DOUBLE_BUFFERING_CODE,d0
    move.b  #DOUBLE_BUFFERING_ON,d1
    trap    #15
    
    ; set fill color for loading screen
    move.b  #SET_FILL_COLOR,d0
    move.l  #BLACK,d1
    trap    #15
    clr.l   d1

    ; set screen size
    move.b  #SET_SCREEN,d0
    move.l  #SCREEN_VALUE,d1
    trap    #15
        
    ; reset font size
    move.b  #SET_TEXT_COLOR,d0
    move.l  #DEFAULT_TEXT_COLOR,d1
    move.l  #DEFAULT_FONT,d2
    trap    #15
    
    ; display loading text
    lea     Loading_String,a1
    move.b  #DISPLAY_STRING,d0
    trap    #15
    
    ; show double buffer
    jsr     RepaintScreen
    
    ; clear loading screen
    move.b  #CLEAR_SCREEN,d0
    move.l  #CLEAR_SCREEN_VAL,d1
    trap    #15
    
    rts
    

SetBackground    
    ; set fill color for background
    move.b  #SET_FILL_COLOR,d0
    move.l  #LIGHT_GREY,d1
    trap    #15
    clr.l   d1
    
    ; draw light grey background for grid behind
    move.w  #(START_X-GRID_OUTER_OFFSET),d1
    move.w  #(START_Y-GRID_OUTER_OFFSET-TOP_UI_HEIGHT),d2
    move.w  d1,d3
    move.w  d2,d4
    add.w   #(GRID_SIDE_LENGTH+(GRID_OUTER_OFFSET+BORDER_OFFSET*2)),d3
    add.w   #(GRID_SIDE_LENGTH+(GRID_OUTER_OFFSET+BORDER_OFFSET*2)+TOP_UI_HEIGHT),d4
    
    move.b  #DRAW_FILLED_RECT,d0
    trap    #15
    
    jsr     ClearRegisters
    
    rts
    
MainMenuLoaded   
    
    ; show double buffer
    jsr     RepaintScreen
    
    jsr     ClearRegisters
    jsr     WaitStart
    
    rts
    
GameLoaded   
    
    ; show double buffer
    jsr     RepaintScreen
    
    jsr     ClearRegisters
    
    lea     Game_State,a4
    move.l  #IN_GAME,(a4)
    move.l  #CLEAR_ADDRESS,a4
    
    jsr     PlayStartSound
    
    rts
    
LoadingNewGame

    ; set pen color
    move.b  #SET_PEN_COLOR,d0
    move.l  #DARK_GREY,d1
    trap    #15

    ; draw rect over top ui
    move.b  #DRAW_FILLED_RECT,d0
    move.l  #(START_X-(BORDER_OFFSET*2)),d1
    move.l  #(START_Y-(TOP_UI_HEIGHT+(BORDER_OFFSET*2))),d2
    move.l  d1,d3
    add.w   #(GRID_SIDE_LENGTH+BORDER_OFFSET*2),d3
    move.l  #(START_Y-(BORDER_OFFSET*3)),d4
    trap    #15
    
    ; reset font size
    move.b  #SET_TEXT_COLOR,d0
    move.l  #DEFAULT_TEXT_COLOR,d1
    move.l  #DEFAULT_FONT,d2
    trap    #15
    
    ; display loading text
    lea     Loading_String,a1
    move.b  #DRAW_TEXT,d0
    move.l  #(START_X+(GRID_SIDE_LENGTH/2)-(BORDER_OFFSET*8)),d1
    move.l  #(START_Y-(BORDER_OFFSET*10)),d2
    trap    #15
    
    ; show double buffer
    jsr     RepaintScreen

    rts
    
Loading_String      dc.l    'Loading...',0
















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
