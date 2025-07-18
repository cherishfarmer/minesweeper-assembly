*-----------------------------------------------------------
* Title      : Sounds
* Written by : Cherish Farmer
* Date       : 06/13/25
* Description: Plays corresponding sound to denote an event change in the game.
*-----------------------------------------------------------

* EQUATES
PLAY_SOUND              EQU     73
; used in multiple files, see main
CLEAR_ADDRESS           EQU     0


; plays when a new game starts
PlayStartSound
    move.b  #PLAY_SOUND,d0
    lea     Start_Sound,a1
    trap    #15
    move.l  #CLEAR_ADDRESS,a1
    rts

; plays when a tile/button is clicked
PlayClickSound
    move.b  #PLAY_SOUND,d0
    lea     Click_Sound,a1
    trap    #15
    move.l  #CLEAR_ADDRESS,a1
    rts

; plays when the player clicks a bomb
PlayLoseSound
    move.b  #PLAY_SOUND,d0
    lea     Lose_Sound,a1
    trap    #15
    move.l  #CLEAR_ADDRESS,a1
    rts

; plays when the player clicks all non-bomb tiles
PlayWinSound
    move.b  #PLAY_SOUND,d0
    lea     Win_Sound,a1
    trap    #15
    move.l  #CLEAR_ADDRESS,a1
    rts

* Sound files
Start_Sound      dc.b      'Start.wav',0
Click_Sound      dc.b      'Click.wav',0
Lose_Sound       dc.b      'Lose.wav',0
Win_Sound        dc.b      'Win.wav',0


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
