*-----------------------------------------------------------
* Title      : Draw Smiley
* Written by : Cherish Farmer
* Date       : 06/11/25
* Description:
* Key:
* - d0: task codes
* - d1: x pos start
* - d2: y post start
* - d3: x pos end
* - d4: y pos end

* Sunglasses Key:
* - d0: trap codes
* - d1: sunglasses x pos
* - d2: sunglasses y pos (uses fixed point and physics with velocity and acceleration)/bitmap y pos
* - d3: sunglasses ellipse x endpoint
* - d4: sunglasses ellipse y endpoint
* - d5: bitmap x pos
* - a4: sunglasses velocity pointer
* - a5: sunglasses current y position (storage for when updating bitmap)
*-----------------------------------------------------------

SMILEY_X_OFFSET         EQU     4
SMILEY_Y_OFFSET         EQU     5

SMILEY_EXPRESS_OFFSET   EQU     6

SUNGLASSES_X            EQU     433
SUNGLASSES_Y_START      EQU     150
SUNGLASSES_Y_RECOIL     EQU     158
SUNGLASSES_Y_END        EQU     160
SUNGLASSES_LENGTH       EQU     26
SUNGLASSES_SIDE_LENGTH  EQU     3
SUNGLASSES_EYE_LENGTH   EQU     8
SUNGLASSES_MID_LENGTH   EQU     6
SUNGLASSES_PEN_WIDTH    EQU     2
SUNGLASSES_SHADE_OFFSET EQU     1

FIXED_POINT_SHIFT       EQU     1
SUNGLASSES_ACCELERATION EQU     1
*TODO: consider loading in all bitmap arguments into table

DrawSmileyStart

    ; prep positions for blank tile
    jsr     ClearRegisters
    
    move.w  #RESTART_LEFT,d1     ; smiley left
    move.w  d1,d5
    move.w  #RESTART_TOP,d2      ; smiley top
    move.w  #RESTART_RIGHT,d3    ; smiley right
    move.w  #RESTART_BOTTOM,d4   ; smiley down

    ; draw blank tile
    jsr     DrawBlankTile
    
    ; reprep positions for bitmap (TODO: optimize)
    move.l  #(START_X+(GRID_SIDE_LENGTH/2)-(TILE_SIZE/2)-SMILEY_X_OFFSET+3),d5    ; smiley left
    move.w  #(START_Y-TOP_UI_HEIGHT-SMILEY_Y_OFFSET+2),d2                         ; smiley top
    
    ; draw neutral smiley

    jsr     LoadStartSmiley
        
    jsr     ClearRegisters
    rts

*TODO: make equates for bitmap output positions
    
SmileyShocked

    ; prep positions for shocked bitmap (TODO: optimize)
    move.l  #(START_X+(GRID_SIDE_LENGTH/2)-(TILE_SIZE/2)-SMILEY_X_OFFSET+3+SMILEY_EXPRESS_OFFSET),d5    ; smiley left
    move.l  #(START_Y-TOP_UI_HEIGHT-SMILEY_Y_OFFSET+2+SMILEY_EXPRESS_OFFSET),d2                         ; smiley top
    
    ; draw shocked smiley
    
    jsr     LoadShockedSmiley
        
    jsr     ClearRegisters   
    jsr     RepaintScreen
    rts

SmileyNeutral

    ; prep positions for shocked bitmap (TODO: optimize)
    move.l  #(START_X+(GRID_SIDE_LENGTH/2)-(TILE_SIZE/2)-SMILEY_X_OFFSET+3+SMILEY_EXPRESS_OFFSET),d5    ; smiley left
    move.l  #(START_Y-TOP_UI_HEIGHT-SMILEY_Y_OFFSET+2+SMILEY_EXPRESS_OFFSET),d2                         ; smiley top
    
    ; draw neutral smiley
    
    jsr     LoadNeutralSmiley
        
    jsr     ClearRegisters
    jsr     RepaintScreen
    rts
    
SmileyDead
    
    ; prep positions for shocked bitmap (TODO: optimize)
    move.l  #(START_X+(GRID_SIDE_LENGTH/2)-(TILE_SIZE/2)-SMILEY_X_OFFSET+3+SMILEY_EXPRESS_OFFSET),d5    ; smiley left
    move.l  #(START_Y-TOP_UI_HEIGHT-SMILEY_Y_OFFSET+2+SMILEY_EXPRESS_OFFSET),d2                         ; smiley top
    
    ; draw dead smiley 
    
    jsr     LoadDeadSmiley
    
    jsr     ClearRegisters
    jsr     RepaintScreen
    rts
    
DrawSmileySunglasses

    lea     Sunglasses_Velocity,a4
    lea     Sunglasses_Current_Y,a5
    move.l  #CLEAR_ADDRESS,(a4)
    move.l  #SUNGLASSES_Y_START,(a5)

    ; draw starting sunglasses (use primitives)
    
    jsr     DrawSunglasses
    
    jsr     RepaintScreen
  

SunglassesFalling    
    *TODO:
    
    ; adjust y down and accelerate by adding velocity (fixed-point) also use time
    clr.l   d2
    move.l  (a5),d2
    add.w   #SUNGLASSES_ACCELERATION,(a4)
    add.w   (a4),d2
    move.l  d2,(a5)
    lsr.w   #FIXED_POINT_SHIFT,d2
    
    ; redraw bitmap behind
    move.l  #(START_X+(GRID_SIDE_LENGTH/2)-(TILE_SIZE/2)-SMILEY_X_OFFSET+3),d5    ; smiley left
    move.w  #(START_Y-TOP_UI_HEIGHT-SMILEY_Y_OFFSET+2),d2                         ; smiley top
    jsr     LoadSunglassesSmiley 
    
    ; redraw sunglasses
    jsr     DrawSunglasses
    
    ; paint screen
    jsr     RepaintScreen
    
    ; loop falling down until over eyes
    cmp.l   #SUNGLASSES_Y_END,(a5)
    blt     SunglassesFalling
    
    move.l  #CLEAR_ADDRESS,(a4)
    
SunglassesRecoil
    ; redraw recoil back up
    clr.l   d2
    move.l  (a5),d2
    add.w   #SUNGLASSES_ACCELERATION,(a4)
    sub.w   (a4),d2
    move.l  d2,(a5)
    lsr.w   #FIXED_POINT_SHIFT,d2
    
    ; redraw bitmap behind
    move.l  #(START_X+(GRID_SIDE_LENGTH/2)-(TILE_SIZE/2)-SMILEY_X_OFFSET+3),d5    ; smiley left
    move.w  #(START_Y-TOP_UI_HEIGHT-SMILEY_Y_OFFSET+2),d2                         ; smiley top
    jsr     LoadSunglassesSmiley 
    
    ; redraw sunglasses slightly up
    jsr     DrawSunglasses
    
    ; paint screen
    jsr     RepaintScreen
    
    ; loop recoil
    cmp.l   #SUNGLASSES_Y_RECOIL,(a5)
    bgt     SunglassesRecoil
    
    ; reset fill color
    move.l  #LIGHT_GREY,d1
    move.b  #SET_FILL_COLOR,d0
    trap    #15

    rts
    
DrawSunglasses

    ; set pen color to black
    move.b  #SET_PEN_COLOR,d0
    move.l  #BLACK,d1
    trap    #15
    
    ; set fill color to black
    move.b  #SET_FILL_COLOR,d0
    trap    #15
    
    ; set pen width
    move.b  #SET_PEN_WIDTH,d0
    move.l  #SUNGLASSES_PEN_WIDTH,d1
    trap    #15

    ; draw black horizontal line
    move.b  #DRAW_LINE,d0
    move.l  #SUNGLASSES_X,d1
    move.l  #(SUNGLASSES_X+SUNGLASSES_LENGTH),d3
    move.l  (a5),d2
    move.l  d2,d4
    trap    #15
    
    ; draw left black filled ellipse
    move.b  #DRAW_FILLED_ELLIPSE,d0
    sub.w   #SUNGLASSES_SHADE_OFFSET,d2
    add.w   #SUNGLASSES_SIDE_LENGTH,d1
    move.l  #(SUNGLASSES_X+(SUNGLASSES_SIDE_LENGTH+SUNGLASSES_EYE_LENGTH)),d3
    add.w   #SUNGLASSES_EYE_LENGTH,d4
    trap    #15
    
    ; draw right black filled ellipse
    move.b  #DRAW_FILLED_ELLIPSE,d0
    move.l  #(SUNGLASSES_X+SUNGLASSES_LENGTH-SUNGLASSES_EYE_LENGTH-SUNGLASSES_SIDE_LENGTH),d1
    move.l  #(SUNGLASSES_X+SUNGLASSES_LENGTH-SUNGLASSES_SIDE_LENGTH),d3
    trap    #15
    
    add.w   #SUNGLASSES_SHADE_OFFSET,d2
    
    rts
    
Sunglasses_Velocity     ds.l    1
Sunglasses_Current_Y    ds.l    1  








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
