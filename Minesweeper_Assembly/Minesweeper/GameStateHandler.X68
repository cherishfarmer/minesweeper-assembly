*-----------------------------------------------------------
* Title      : Game State Handler
* Written by : Cherish Farmer
* Date       : 06/11/25
* Description: Checks current state of game and handles appropriate game endings
*-----------------------------------------------------------

* EQUATES

WINDOWS_BLUE            EQU     $b04d10
LIGHT_GREY              EQU     $c0c0c0

SET_TEXT_COLOR          EQU     21
SET_FILL_COLOR          EQU     81
DRAW_TEXT               EQU     95

DEFAULT_TEXT_COLOR      EQU     $00FFFFFF
DEFAULT_FONT            EQU     $00000000

NO_TILES_LEFT           EQU     00

TITLE_SCREEN            EQU     00
IN_GAME                 EQU     01
END_GAME                EQU     02
RESTART_GAME            EQU     03

HOW_TO_LOADING_POS_X    EQU     2
HOW_TO_LOADING_POS_Y    EQU     665
HOW_TO_OFF              EQU     00
HOW_TO_ON               EQU     01


GameStateHandler

    ; TODO: make game state make more sense

    ; check if all non bomb tiles have been clicked (trigger win game if so)
    lea     Non_Bomb_Tiles,a4
    cmp.l   #NO_TILES_LEFT,(a4)
    beq     AllNonBombTilesClicked
    
    ; return to read mouse loop if state is unchanged
    rts
    
AllNonBombTilesClicked

    jsr     GameWinEvent
    rts
    
GameLoseEvent

    jsr     UpdateSevenSegment
    jsr     SmileyDead
    jsr     PlayLoseSound
    jsr     SetEndGameState
    rts

GameWinEvent

    jsr     UpdateSevenSegment
    jsr     DrawSmileySunglasses
    jsr     PlayWinSound
    jsr     SetEndGameState
    rts
    
SetEndGameState
    lea     Game_State,a4
    move.l  #END_GAME,(a4)
    rts

    
UpdateHowToState

    ; put loading text
    
    ; set fill color for loading screen
    move.b  #SET_FILL_COLOR,d0
    move.l  #WINDOWS_BLUE,d1
    trap    #15
    clr.l   d1
    
    ; reset font size
    move.b  #SET_TEXT_COLOR,d0
    move.l  #DEFAULT_TEXT_COLOR,d1
    move.l  #DEFAULT_FONT,d2
    trap    #15
    
    ; set location of loading text
    move.w  #HOW_TO_LOADING_POS_X,d1
    move.w  #HOW_TO_LOADING_POS_Y,d2
    
    ; display loading text
    lea     Loading_String,a1
    move.b  #DRAW_TEXT,d0
    trap    #15
    
    ; repaint screen
    jsr     RepaintScreen
    
    ; reset pos and fill color
    move.b  #SET_FILL_COLOR,d0
    move.l  #LIGHT_GREY,d1
    trap    #15
    clr.l   d1
    
    clr.l   d1
    clr.l   d2
    move.l  #CLEAR_ADDRESS,a1
    
    ; load in bitmap
    lea     How_To_State,a4
    cmp.l   #HOW_TO_OFF,(a4)
    beq     OpenHowToPlay
    bne     CloseHowToPlay
    
OpenHowToPlay
    jsr     LoadInHowToPlay
    rts

CloseHowToPlay
    jsr     LoadOutHowToPlay
    rts










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
