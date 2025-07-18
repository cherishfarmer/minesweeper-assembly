*-----------------------------------------------------------
* Title      : Timer
* Written by : Cherish Farmer
* Date       : 06/11/25
* Description: Used for the seven-segment display to update the timer display.
*-----------------------------------------------------------

* EQUATES
RETURN_TIME             EQU     8
START_TIME              EQU     0
ONE_SECOND              EQU     100


StartTime
    
    ; called to start/restart the timer
    lea     Start_Since_Midnight,a0  
    move.b  #RETURN_TIME,d0
    trap    #15
    
    ; save time since midnight
    move.l  d1,(a0)
    clr.l   d1
    
    ; move start time (000) into current time
    lea     Current_Time,a0
    move.l  #START_TIME,(a0)
    
    rts
    
CheckTimeElapsed
    
    ; get current time since midnight
    move.b  #RETURN_TIME,d0
    trap #15
    
    ; sub by start since midnight to get time difference (in centiseconds)
    sub.l   (Start_Since_Midnight),d1
    
    ; divide by 100 to get time elapsed from centiseconds to seconds
    divu    #ONE_SECOND,d1
    
    rts
    





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
