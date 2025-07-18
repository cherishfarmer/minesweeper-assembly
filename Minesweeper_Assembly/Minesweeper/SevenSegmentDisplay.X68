*-----------------------------------------------------------
* Title      : Seven-Segment Display
* Written by : Cherish Farmer
* Date       : 06/04/25
* Description:
* Key:
* - d0: trap codes
* - d1: x pos
* - d2: y pos
* - d3: value to display
* - d4: used for calculations and getting values at certain places
* - d5: used for segment flags
* - d6: offset for position address
* - d7: counter
* - a1: used to load in address of values to display
* - a4: placeholder address
* - a5: used to load in segments address
* - a6: used to load in segment line positions
*-----------------------------------------------------------

* EQUATES
LIGHT_GREY          EQU     $c0c0c0
BLACK               EQU     $000000

SET_PEN_COLOR       EQU     80
SET_FILL_COLOR      EQU     81
DRAW_FILLED_RECT    EQU     87

DISPLAY_ZERO        EQU     $3f
DISPLAY_ONE         EQU     $06
DISPLAY_TWO         EQU     $5b
DISPLAY_THREE       EQU     $4f
DISPLAY_FOUR        EQU     $66
DISPLAY_FIVE        EQU     $6d
DISPLAY_SIX         EQU     $7d
DISPLAY_SEVEN       EQU     $07
DISPLAY_EIGHT       EQU     $7f
DISPLAY_NINE        EQU     $6f

LEFT_DIGIT          EQU     $64
MIDDLE_DIGIT        EQU     $A
RIGHT_DIGIT         EQU     $9

MIDDLE_OFFSET       EQU     20
RIGHT_OFFSET        EQU     60

DECIMAL             EQU     10

SEGMENT_BRIGHT_RED  EQU     $1c15ac
SEGMENT_DARK_RED    EQU     $161445
SEGMENT_WIDTH       EQU     3
SEGMENT_LENGTH      EQU     10

NUM_BIT_FLAGS       EQU     7

SHIFT_FOR_WORD      EQU     1

SEVEN_SEGMENT_TIMER_OFFSET      EQU     336

BOMB_DISPLAY_X_START            EQU     $f5
BOMB_DISPLAY_X_END              EQU     $136

TIMER_DISPLAY_X_START           EQU     $245
TIMER_DISPLAY_X_END             EQU     $286

DISPLAY_Y_START                 EQU     $91
DISPLAY_Y_END                   EQU     $B9

CLEAR_ADDRESS        EQU     0
RESET_VAL            EQU     $FFFFFFFF


PrepDisplayRects

    ; set pen color for rects
    move.b  #SET_PEN_COLOR,d0
    move.l  #BLACK,d1
    trap    #15
    
    ; set fill color for rects
    move.b  #SET_FILL_COLOR,d0
    move.l  #BLACK,d1
    trap    #15
    
    rts
    
    
ResetAfterRectsDrawn

    ; reset fill color
    move.b  #SET_FILL_COLOR,d0
    move.l  #LIGHT_GREY,d1
    trap    #15
    
    ; set width
    move.b  #SET_PEN_WIDTH,d0
    move.l  #SEGMENT_WIDTH,d1
    trap    #15  
    clr.l   d1

    clr.l   d1  
    clr.l   d2
    clr.l   d3
    clr.l   d4
    
    rts
    

DrawNextLine

    ; set positions
    move.w  (a6)+,d1
    move.w  (a6)+,d2
    move.w  (a6)+,d3
    move.w  (a6)+,d4
    
    ; draw line
    trap    #15
    
    rts
    
    
DrawBombBox
    
    ; draw black filled rectangles
    
    jsr     PrepDisplayRects

    ; prep positions for bomb display rect
    move.b  #DRAW_FILLED_RECT,d0
    
    move.w  #BOMB_DISPLAY_X_START,d1 
    move.w  #DISPLAY_Y_START,d2
    move.w  #BOMB_DISPLAY_X_END,d3
    move.w  #DISPLAY_Y_END,d4
    
    ; draw bomb display rect
    trap    #15
    
    jsr     ResetAfterRectsDrawn
    
    rts
    
    
DrawTimerBox

    jsr     PrepDisplayRects

    ; shift positions right for timer box
    move.l  #(BOMBS_OUTPUT_LEFT-1+SEVEN_SEGMENT_TIMER_OFFSET),d1 
    
    move.w  #TIMER_DISPLAY_X_START,d1 
    move.w  #DISPLAY_Y_START,d2
    move.w  #TIMER_DISPLAY_X_END,d3
    move.w  #DISPLAY_Y_END,d4
     
    ; draw timer display rect
    move.b  #DRAW_FILLED_RECT,d0
    trap    #15
    
    jsr     ResetAfterRectsDrawn
    
    rts
    
    
UpdateSevenSegment  
    
    ; check if last recorded values are set
    lea     Last_Recorded_Bomb_Display,a1
    cmp.l   #RESET_VAL,(a1)
    beq     SetStartingSevenSegmentDisplays
  
    ; check if bombs have changed
    lea     Last_Recorded_Bomb_Display,a1
    move.l  (a1),d1
    lea     Fake_Bomb_Counter,a1
    cmp.w   (a1),d1
    beq     TimerSevenSegmentDisplay
    bne     FakeBombSevenSegmentDisplay
    
SetStartingSevenSegmentDisplays
    
    jsr     DrawBombBox
    jsr     DrawTimerBox
    
    ; value in main, kept there in case it's adjusted (15)
    move.l  #NUM_BOMBS,(a1)
    
    move.l  #CLEAR_ADDRESS,a1
    
    
FakeBombSevenSegmentDisplay 

    ; load in tables
    lea     Display_Segments,a5
    lea     Seven_Segment_Positions,a6
    
    ; check fake bomb counter
    lea     Fake_Bomb_Counter,a1
    move.w  (a1),d3
    
    * retrieve each place and call to draw segment:    
    * right: move d3 to d4 and divide by 10, use remainder as ones place and store not remainder in d3
    * middle: move d3 (updated) to d4 and divide by 10, use remainder as tens place and store not remainder in d3
    * left: move d3 to d4, should already be hundreds place
    
    
    ; - rightmost: mod d3 by 10
    move.w  d3,d4
    divu    #DECIMAL,d4
    
    ; save result in d3 for later
    move.w  d4,d3
    clr.w   d4
    
    ; draw remainder
    swap    d4
    swap    d3
    jsr     DrawValue  
    
 
    ; - middle: divide d3 by 10
    
    clr.w   d3
    clr.l   d4
    swap    d3
    move.w  d3,d4
    
    ; get tens place
    divu    #DECIMAL,d4
    move.w  d4,d3
    clr.w   d4
    swap    d4
    swap    d3

    jsr     DrawValue
    
    
    ; - leftmost: divide by 10 again

    ; get hundreds place
    clr.w   d3
    swap    d3
    clr.l   d4
    move.w  d3,d4
    jsr     DrawValue
    
    
    ; repaint screen
    jsr     RepaintScreen
    
    
TimerSevenSegmentDisplay 

    ; load in last recorded time
    lea     Current_Time,a1

    ; check if current time is set
    move.l  (a1),d3
    cmp.l   #RESET_VAL,d3
    beq     PrepUpdateTime
    
    ; check time elapsed
    jsr     CheckTimeElapsed
    
    ; check if time elapsed is greater than last recorded time
    cmp.w   d1,d3
    
    ; if current time is not less than time elapsed, no need to update (return)
    blt     PrepUpdateTime
    rts
    
    ; update current time to reflect on display
    
PrepUpdateTime

    ; redraw timer box
    jsr     DrawTimerBox
    
    ; reload in current time
    lea Current_Time,a1
    move.l  (a1),d3
    add.l   #1,d3
    
    ; store updated current time
    move.l  d3,(a1)
    
    ; check if clock loop has passed
    cmp.l   #CLOCK_LOOP,(a1)
    
    ; if clock loop has not passed, continue the clock
    bne     ContinueClock
    
    ; restart time if it reaches 999
    jsr     StartTime
    
ContinueClock
    
    * retrieve each place and call to draw segment:
    * right: move d3 to d4 and divide by 10, use remainder as ones place and store not remainder in d3
    * middle: move d3 (updated) to d4 and divide by 10, use remainder as tens place and store not remainder in d3
    * left: move d3 to d4, should already be hundreds place
    
    ; make sure address is at right place
    ; load in tables
    lea     Display_Segments,a5
    lea     Seven_Segment_Positions,a6
    adda    #TIMER_ADDRESS_OFFSET,a6    
    
    
    ; - rightmost: mod d3 by 10
     
    move.w  d3,d4
    divu    #DECIMAL,d4
    
    ; save result in d3 for later
    move.w  d4,d3
    clr.w   d4
    
    ; draw remainder
    swap    d4
    swap    d3
    jsr     DrawValue  
    
 
    ; - middle: divide d3 by 10
    sub.w   #MIDDLE_OFFSET,d1
    
    clr.w   d3
    clr.l   d4
    swap    d3
    move.w  d3,d4
    
    ; get tens place
    divu    #DECIMAL,d4
    move.w  d4,d3
    clr.w   d4
    swap    d4
    swap    d3

    jsr     DrawValue
    
    
    ; - leftmost: divide by 10 again
    
    ; get hundreds place
    clr.w   d3
    swap    d3
    clr.l   d4
    move.w  d3,d4
    jsr     DrawValue
    

UpdateSevenSegmentDisplay
    
    ; repaint screen
    jsr     RepaintScreen
    
    ; start updating current time if at start time
    cmp.l   #START_TIME,(a1)
    bne     TimeAlreadyStarted
    add.l   #1,(a1)
    
TimeAlreadyStarted
    jsr     ClearRegisters
    move.l  #CLEAR_ADDRESS,a0
    move.l  #CLEAR_ADDRESS,a1
    
    rts
    
    
    
DrawValue
    
    ; find appropriate segment combination
    lsl.w   #SHIFT_FOR_WORD,d4
    move.w  (a5,d4.l),d5
    
    ; restart counter
    move.w  #0,d7

DrawValueLoop
    
    ; set pen color
    move.b  #SET_PEN_COLOR,d0
    move.l  #SEGMENT_DARK_RED,d1
    trap    #15
    
    ; move to different register to be manipulated
    move.l  d5,d6
    
    ; shift to check bit
    lsr.l   d7,d6
    and.l   #RIGHT_MOST_BIT,d6
    cmp.l   #RIGHT_MOST_BIT,d6
    bne     OffBitColor
    
OnBitColor

    ; set pen color
    move.b  #SET_PEN_COLOR,d0
    move.l  #SEGMENT_BRIGHT_RED,d1
    trap    #15

OffBitColor    
    ; shift d7 to be number of bits offset by address (and move back) TODO: optimize this
    
    ; prep to draw line
    move.b  #DRAW_LINE,d0
    
    ; each segment is made of two lines, so call twice
    jsr     DrawNextLine
    jsr     DrawNextLine
                       
    ; loop through to draw appropriate segments
    add.w   #1,d7
    cmp.b   #(NUM_BIT_FLAGS),d7
    beq     DrawThirdLine
    bne     DrawValueLoop                  
    
DrawThirdLine

    ; last segment has a third line
    jsr     DrawNextLine
    
    rts
    
    
    
Display_Segments
        *1-7 for 0-9 on seven segment display (only uses first seven bits) extra 0s are for padding
            dc.w    DISPLAY_ZERO,DISPLAY_ONE,DISPLAY_TWO,DISPLAY_THREE,DISPLAY_FOUR,DISPLAY_FIVE,DISPLAY_SIX,DISPLAY_SEVEN,DISPLAY_EIGHT,DISPLAY_NINE,0,0
            
* Position sets are for each line. Segments A-F have 2 lines and G has 3. The order of the seven segments are bombs right->left and timer right->left
* Groups are d1,d2,d3,d4
Seven_Segment_Positions
            * Bomb display right
            dc.w    $12f,$97,$125,$97, $12d,$98,$127,$98, $131,$99,$131,$a3, $130,$9a,$130,$a2, $131,$a7,$131,$b1, $130,$a8,$130,$b0, $12f,$b3,$125,$b3, $12d,$b2,$127,$b2
            dc.w    $123,$a7,$123,$b1, $124,$a8,$124,$b0, $123,$99,$123,$a3, $124,$9a,$124,$a2, $12f,$a5,$125,$a5, $12d,$a6,$127,$a6, $12d,$a4,$127,$a4
            * Bomb display middle
            dc.w    $11b,$97,$111,$97, $119,$98,$113,$98, $11d,$99,$11d,$a3, $11c,$9a,$11c,$a2, $11d,$a7,$11d,$b1, $11c,$a8,$11c,$b0, $11b,$b3,$111,$b3, $119,$b2,$113,$b2
            dc.w    $10f,$a7,$10f,$b1, $110,$a8,$110,$b0, $10f,$99,$10f,$a3, $110,$9a,$110,$a2, $11b,$a5,$111,$a5, $119,$a6,$113,$a6, $119,$a4,$113,$a4
            * Bomb display left
            dc.w    $107,$97,$fd,$97, $105,$98,$ff,$98, $109,$99,$109,$a3, $108,$9a,$108,$a2, $109,$a7,$109,$b1, $108,$a8,$108,$b0, $107,$b3,$fd,$b3, $105,$b2,$ff,$b2
            dc.w    $fb,$a7,$fb,$b1, $fc,$a8,$fc,$b0, $fb,$99,$fb,$a3, $fc,$9a,$fc,$a2, $107,$a5,$fd,$a5, $105,$a6,$ff,$a6, $105,$a4,$ff,$a4
            * Timer display right
            dc.w    $27f,$97,$275,$97, $27d,$98,$277,$98, $281,$99,$281,$a3, $280,$9a,$280,$a2, $281,$a7,$281,$b1, $280,$a8,$280,$b0, $27f,$b3,$275,$b3, $27d,$b2,$277,$b2
            dc.w    $273,$a7,$273,$b1, $274,$a8,$274,$b0, $273,$99,$273,$a3, $274,$9a,$274,$a2, $27f,$a5,$275,$a5, $27d,$a6,$277,$a6, $27d,$a4,$277,$a4
            * Timer display middle
            dc.w    $26b,$97,$261,$97, $269,$98,$263,$98, $26d,$99,$26d,$a3, $26c,$9a,$26c,$a2, $26d,$a7,$26d,$b1, $26c,$a8,$26c,$b0, $26b,$b3,$261,$b3, $269,$b2,$263,$b2
            dc.w    $25f,$a7,$25f,$b1, $260,$a8,$260,$b0, $25f,$99,$25f,$a3, $260,$9a,$260,$a2, $26b,$a5,$261,$a5, $269,$a6,$263,$a6, $269,$a4,$263,$a4
            * Timer display left
            dc.w    $257,$97,$24d,$97, $255,$98,$24f,$98, $259,$99,$259,$a3, $258,$9a,$258,$a2, $259,$a7,$259,$b1, $258,$a8,$258,$b0, $257,$b3,$24d,$b3, $255,$b2,$24f,$b2
            dc.w    $24b,$a7,$24b,$b1, $24c,$a8,$24c,$b0, $24b,$99,$24b,$a3, $24c,$9a,$24c,$a2, $257,$a5,$24d,$a5, $255,$a6,$24f,$a6, $255,$a4,$24f,$a4

* Saves last recorded bomb, used to check if bomb display needs to be updated            
Last_Recorded_Bomb_Display
            ds.l    1
    










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
