*-----------------------------------------------------------
* Title      : Bitmap Chunker
* Written by : Cherish Farmer
* Date       : 5/27/25
* Description: Loads in a provided bitmap

*-----------------------------------------------------------
 
SET_SCREEN                  EQU     33
SET_PEN_COLOR               EQU     80
DRAW_PIXEL                  EQU     82
SET_POSITION                EQU     86

DATA_OFFSET                 EQU     $0A
BMP_WIDTH_OFFSET            EQU     $12
BMP_HEIGHT_OFFSET           EQU     $16
NUM_BITS_OFFSET             EQU     $1C

TWENTYFOUR_BIT              EQU     24
TWENTYFOUR_IN_BYTE          EQU     03
THIRTYTWO_BIT               EQU     32
THIRTYTWO_IN_BYTE           EQU     04
PADDING_DIVISOR             EQU     04

WINDOWS_CHUNK_LEFT          EQU     0 
WINDOWS_CHUNK_TOP           EQU     0 
WINDOWS_CHUNK_WIDTH         EQU     900
WINDOWS_CHUNK_HEIGHT        EQU     700
WINDOWS_OUTPUT_LEFT         EQU     0
WINDOWS_OUTPUT_TOP          EQU     0

RESTART_CHUNK_LEFT          EQU     228
RESTART_CHUNK_TOP           EQU     104 
RESTART_CHUNK_WIDTH         EQU     437
RESTART_CHUNK_HEIGHT        EQU     509
RESTART_OUTPUT_LEFT         EQU     228
RESTART_OUTPUT_TOP          EQU     104

POPUP_CHUNK_LEFT            EQU     0 
POPUP_CHUNK_TOP             EQU     0 
POPUP_CHUNK_WIDTH           EQU     436
POPUP_CHUNK_HEIGHT          EQU     22
POPUP_OUTPUT_LEFT           EQU     228
POPUP_OUTPUT_TOP            EQU     106

HOW_TO_CHUNK_LEFT           EQU     2
HOW_TO_CHUNK_TOP            EQU     0 
HOW_TO_CHUNK_WIDTH          EQU     225
HOW_TO_CHUNK_HEIGHT         EQU     299
HOW_TO_OUTPUT_LEFT          EQU     2
HOW_TO_OUTPUT_TOP           EQU     380

HOW_TO_COVER_CHUNK_TOP      EQU     380     

SEVEN_SEGMENT_CHUNK_LEFT    EQU     0 
SEVEN_SEGMENT_CHUNK_TOP     EQU     0 
SEVEN_SEGMENT_CHUNK_WIDTH   EQU     64
SEVEN_SEGMENT_CHUNK_HEIGHT  EQU     39
SEVEN_SEGMENT_OUTPUT_TOP    EQU     START_Y-TOP_UI_HEIGHT-BORDER_OFFSET-1
BOMBS_OUTPUT_LEFT           EQU     START_X-BORDER_OFFSET
TIMER_OUTPUT_LEFT           EQU     BOMBS_OUTPUT_LEFT+GRID_SIDE_LENGTH-(TILE_SIZE*2)+GRID_OUTER_OFFSET
    
SMILEY_CHUNK_TOP            EQU     0
SMILEY_NEUTRAL_OFFSET       EQU     0
SMILEY_SHOCKED_OFFSET       EQU     35
SMILEY_DEAD_OFFSET          EQU     70
SMILEY_LENGTH               EQU     35

SUNGLASSES_CHUNK_HEIGHT     EQU     27

ROTATION_VALUE              EQU     08 

BMP_STACK                   EQU     00
CHUNK_LEFT_STACK            EQU     04
CHUNK_TOP_STACK             EQU     06
CHUNK_WIDTH_STACK           EQU     08
CHUNK_HEIGHT_STACK          EQU     10
OUTPUT_LEFT_STACK           EQU     12
OUTPUT_TOP_STACK            EQU     14
SP_OFFSET                   EQU     20
SP_ARG                      EQU     04
    
    
GetColor
    cmp.b   #THIRTYTWO_BIT,(NumBits)
    beq     GetColor32    
    ; loop through to: find/set color
    ; 24-bit, loop 3 times
GetColor24
    move.l  #2,d0
GetColor24Loop
    move.b (a1)+,d1
    lsl.l   #ROTATION_VALUE,d1
    dbra    d0,GetColor24Loop
    ror.l   #ROTATION_VALUE,d1 
    rts   
    ; loop through to: find/set color
    ; 32-bit, loop 2 times 
GetColor32
    move.l  #1,d0    
GetColor32Loop
    move.b  (a1)+,d1
    lsl.l   #ROTATION_VALUE,d1
    dbra    d0,GetColor32Loop
    move.b  (a1)+,d1
    ; last bit is for transparency, not used
    move.b  (a1)+,d0
    rts

LoadChunk
    add.w   #SP_ARG,sp                  ; stack pointer offset to make sure arguments are loaded in correctly
    move.w  OUTPUT_TOP_STACK(sp),d2     ; y output onto display
    move.w  OUTPUT_LEFT_STACK(sp),d3    ; x output onto display -- d3 to shift later into d1
    move.w  CHUNK_HEIGHT_STACK(sp),d6   ; chunk height
    move.w  CHUNK_WIDTH_STACK(sp),d7    ; chunk width
    move.w  CHUNK_TOP_STACK(sp),d4      ; y value of chunk in bmp
    move.w  CHUNK_LEFT_STACK(sp),d5     ; x value of chunk in bmp
    move.l  BMP_STACK(sp),a0            ; address of bmp file
    
    
    ; store x chunk boundary (left + chunk width)
    move.w  d3,d0
    add.w   d7,d0
    move.w  d0,(ChunkXBoundary)
    
    ; store y chunk boundary (top)
    move.w  d2,(ChunkYBoundary)
 
    ; store value of bit (24/32)
    move.w  NUM_BITS_OFFSET(a0),(NumBits)
    
    ; set bytes per color to 3 (24-bit)
    move.b  #TWENTYFOUR_IN_BYTE,(BytesPerColor)
    cmp.b   #THIRTYTWO_BIT,(NumBits)
    bne     SetPadding      

    ; if 32-bits, set bytes per color from 3 to 4
    move.b  #THIRTYTWO_IN_BYTE,(BytesPerColor)
    move.w  #0,(Padding)
    bra     Calculations
    
    ; account for padding to ensure address is always on word boundary
SetPadding    
    move.w  (BMPWidth),d0  
    lsr.l   #2,d0
    and.l   #$0003,d0
    move.w  d0,(Padding)
    clr.l   d0

Calculations   
    ; address offset = (bmp height - chunk top - chunk height) * (bmp width * bytes per color) + (chunk left * bytes per color) + bmp offset
    
    ; calculate numbers of bytes per row
    move.b  (BytesPerColor),d1
    mulu    (BMPWidth),d1
    
    ; bmp height - chunk top - chunk height 
    move.w  (BMPHeight),d0
    sub.w   d4,d0  
    sub.w   d6,d0

    ; multiple above value with number of bytes per row
    mulu    d1,d0    
    clr.l   d1
    
    ; calculate left offset and add to above
    move.b  (BytesPerColor),d1
    mulu    d5,d1
    add.l   d1,d0    
    clr.l   d1
    
    ; (bmp height - chunk top - chunk height) * padding
    move.w  (BMPHeight),d1
    sub.l   d4,d1  
    sub.l   d6,d1
    mulu    (Padding),d1
    
    ; add to everything else
    add.l   d1,d0    
    clr.l   d1
    
    ; above + data offset
    move.b  DATA_OFFSET(a0),d1
    add.l   d1,d0
  
    ; add everything to offset register
    move.l  a0,a1
    adda.l  d0,a1
    
    ; chunk x start = chunk left
    ; chunk y start = chunk top + chunk height
    add.w   d6,d4
    ; output x start = output left
    ; output y start = output top + chunk height
    add.w   d6,d2
    
DrawChunk
    ; update color
    clr.l   d0
    jsr     GetColor
    
    ; set pen color
    move.b  #SET_PEN_COLOR,d0
    trap    #15   

    clr.l   d1 
   
    ; draw pixel
    move.b  #DRAW_PIXEL,d0
    move.w  d3,d1
    trap    #15
    
    clr.l   d1
    
    ; increment output x, check if it has reached chunk width
    addi.l  #1,d3
    cmp.w   (ChunkXBoundary),d3
    bne     DrawChunk
    
    ; account for padding to ensure address is on word boundary
    adda.w  (Padding),a1
    
    ; traverse necessary number of bytes    
    ; (bmp width - chunk width) * bytes per color
    move.w  (BMPWidth),d0
    sub.w   d7,d0
    move.b  (BytesPerColor),d1
    mulu    d1,d0
    adda.l  d0,a1
        
    ; decrement y if x at limit and subtract chunk width from x, check if it has reachead chunk height limit
    sub.l   d7,d3
    sub.l   #1,d2
    cmp.w   (ChunkYBoundary),d2
    bne     DrawChunk
    
    ; add sp offset back
    add.w   #SP_OFFSET,sp
    rts  



LoadWindowsBackground

    ; lea windows background for main menu
    lea     Windows_Background,a0
    
    jsr     StoreBMPDimensions
    
    ; load arguments onto stack
    sub.l   #SP_OFFSET,sp 
    move.l  a0,BMP_STACK(sp)
    move.w  #WINDOWS_CHUNK_LEFT,CHUNK_LEFT_STACK(sp)
    move.w  #WINDOWS_CHUNK_TOP,CHUNK_TOP_STACK(sp)
    move.w  #WINDOWS_CHUNK_WIDTH,CHUNK_WIDTH_STACK(sp)
    move.w  #WINDOWS_CHUNK_HEIGHT,CHUNK_HEIGHT_STACK(sp)
    move.w  #WINDOWS_OUTPUT_LEFT,OUTPUT_LEFT_STACK(sp)
    move.w  #WINDOWS_OUTPUT_TOP,OUTPUT_TOP_STACK(sp) 
    
    jsr     LoadChunk
    rts
    
LoadPopUp

    ; lea windows background for main menu
    lea     Pop_Up,a0
    
    jsr     StoreBMPDimensions
    
    ; load arguments onto stack
    sub.l   #SP_OFFSET,sp 
    move.l  a0,BMP_STACK(sp)
    move.w  #POPUP_CHUNK_LEFT,CHUNK_LEFT_STACK(sp)
    move.w  #POPUP_CHUNK_TOP,CHUNK_TOP_STACK(sp)
    move.w  #POPUP_CHUNK_WIDTH,CHUNK_WIDTH_STACK(sp)
    move.w  #POPUP_CHUNK_HEIGHT,CHUNK_HEIGHT_STACK(sp)
    move.w  #POPUP_OUTPUT_LEFT,OUTPUT_LEFT_STACK(sp)
    move.w  #POPUP_OUTPUT_TOP,OUTPUT_TOP_STACK(sp) 
    
    jsr     LoadChunk
    rts
    
LoadStartSmiley

    ; lea windows background for main menu
    lea     Smiley_Face,a0
    
    jsr     StoreBMPDimensions
    
    ; load arguments onto stack
    sub.l   #SP_OFFSET,sp 
    move.l  a0,BMP_STACK(sp)
    move.w  #SMILEY_NEUTRAL_OFFSET,CHUNK_LEFT_STACK(sp)
    move.w  #SMILEY_CHUNK_TOP,CHUNK_TOP_STACK(sp)
    move.w  #SMILEY_LENGTH,CHUNK_WIDTH_STACK(sp)
    move.w  #SMILEY_LENGTH,CHUNK_HEIGHT_STACK(sp)
    move.w  d5,OUTPUT_LEFT_STACK(sp)
    move.w  d2,OUTPUT_TOP_STACK(sp) 
    
    jsr     LoadChunk
    rts
    
LoadNeutralSmiley

    ; lea windows background for main menu
    lea     Smiley_Face,a0
    
    jsr     StoreBMPDimensions
    
    ; load arguments onto stack
    sub.l   #SP_OFFSET,sp 
    move.l  a0,BMP_STACK(sp)
    move.w  #(SMILEY_NEUTRAL_OFFSET+SMILEY_EXPRESS_OFFSET),CHUNK_LEFT_STACK(sp)
    move.w  #(SMILEY_CHUNK_TOP+SMILEY_EXPRESS_OFFSET),CHUNK_TOP_STACK(sp)
    move.w  #(SMILEY_LENGTH-(SMILEY_EXPRESS_OFFSET*2)),CHUNK_WIDTH_STACK(sp)
    move.w  #(SMILEY_LENGTH-(SMILEY_EXPRESS_OFFSET*2)),CHUNK_HEIGHT_STACK(sp)
    move.w  d5,OUTPUT_LEFT_STACK(sp)
    move.w  d2,OUTPUT_TOP_STACK(sp) 
    
    jsr     LoadChunk
    rts
    
LoadShockedSmiley

    ; lea windows background for main menu
    lea     Smiley_Face,a0
    
    jsr     StoreBMPDimensions
    
    ; load arguments onto stack
    sub.l   #SP_OFFSET,sp 
    move.l  a0,BMP_STACK(sp)
    move.w  #(SMILEY_SHOCKED_OFFSET+SMILEY_EXPRESS_OFFSET),CHUNK_LEFT_STACK(sp)
    move.w  #(SMILEY_CHUNK_TOP+SMILEY_EXPRESS_OFFSET),CHUNK_TOP_STACK(sp)
    move.w  #(SMILEY_LENGTH-(SMILEY_EXPRESS_OFFSET*2)),CHUNK_WIDTH_STACK(sp)
    move.w  #(SMILEY_LENGTH-(SMILEY_EXPRESS_OFFSET*2)),CHUNK_HEIGHT_STACK(sp)
    move.w  d5,OUTPUT_LEFT_STACK(sp)
    move.w  d2,OUTPUT_TOP_STACK(sp) 
    
    jsr     LoadChunk
    rts
    
LoadDeadSmiley

    ; lea windows background for main menu
    lea     Smiley_Face,a0
    
    jsr     StoreBMPDimensions
    
    ; load arguments onto stack
    sub.l   #SP_OFFSET,sp 
    move.l  a0,BMP_STACK(sp)
    move.w  #(SMILEY_DEAD_OFFSET+SMILEY_EXPRESS_OFFSET),CHUNK_LEFT_STACK(sp)
    move.w  #(SMILEY_CHUNK_TOP+SMILEY_EXPRESS_OFFSET),CHUNK_TOP_STACK(sp)
    move.w  #(SMILEY_LENGTH-(SMILEY_EXPRESS_OFFSET*2)),CHUNK_WIDTH_STACK(sp)
    move.w  #(SMILEY_LENGTH-(SMILEY_EXPRESS_OFFSET*2)),CHUNK_HEIGHT_STACK(sp)
    move.w  d5,OUTPUT_LEFT_STACK(sp)
    move.w  d2,OUTPUT_TOP_STACK(sp) 
    
    jsr     LoadChunk
    rts
    
LoadSunglassesSmiley

    ; lea windows background for main menu
    lea     Smiley_Face,a0
    
    jsr     StoreBMPDimensions
    
    ; load arguments onto stack
    sub.l   #SP_OFFSET,sp 
    move.l  a0,BMP_STACK(sp)
    move.w  #SMILEY_NEUTRAL_OFFSET,CHUNK_LEFT_STACK(sp)
    move.w  #SMILEY_CHUNK_TOP,CHUNK_TOP_STACK(sp)
    move.w  #SMILEY_LENGTH,CHUNK_WIDTH_STACK(sp)
    move.w  #SUNGLASSES_CHUNK_HEIGHT,CHUNK_HEIGHT_STACK(sp)
    move.w  d5,OUTPUT_LEFT_STACK(sp)
    move.w  d2,OUTPUT_TOP_STACK(sp) 
    
    jsr     LoadChunk
    rts
    
LoadMainMenuRestart

    ; lea windows background for main menu
    lea     Windows_Background,a0
    
    jsr     StoreBMPDimensions
    
    ; load arguments onto stack
    sub.l   #SP_OFFSET,sp 
    move.l  a0,BMP_STACK(sp)
    move.w  #RESTART_CHUNK_LEFT,CHUNK_LEFT_STACK(sp)
    move.w  #RESTART_CHUNK_TOP,CHUNK_TOP_STACK(sp)
    move.w  #RESTART_CHUNK_WIDTH,CHUNK_WIDTH_STACK(sp)
    move.w  #RESTART_CHUNK_HEIGHT,CHUNK_HEIGHT_STACK(sp)
    move.w  #RESTART_OUTPUT_LEFT,OUTPUT_LEFT_STACK(sp)
    move.w  #RESTART_OUTPUT_TOP,OUTPUT_TOP_STACK(sp) 
    
    jsr     LoadChunk
    rts
    
LoadInHowToPlay

    ; lea windows background for main menu
    lea     How_To,a0
    
    jsr     StoreBMPDimensions
    
    ; load arguments onto stack
    sub.l   #SP_OFFSET,sp 
    move.l  a0,BMP_STACK(sp)
    move.w  #HOW_TO_CHUNK_LEFT,CHUNK_LEFT_STACK(sp)
    move.w  #HOW_TO_CHUNK_TOP,CHUNK_TOP_STACK(sp)
    move.w  #HOW_TO_CHUNK_WIDTH,CHUNK_WIDTH_STACK(sp)
    move.w  #HOW_TO_CHUNK_HEIGHT,CHUNK_HEIGHT_STACK(sp)
    move.w  #HOW_TO_OUTPUT_LEFT,OUTPUT_LEFT_STACK(sp)
    move.w  #HOW_TO_OUTPUT_TOP,OUTPUT_TOP_STACK(sp) 
    
    lea     How_To_State,a4
    move.l  #HOW_TO_ON,(a4)
    move.l  #CLEAR_ADDRESS,a4
    
    jsr     LoadChunk
    rts
    
LoadOutHowToPlay

    ; lea windows background for main menu
    lea     Windows_Background,a0
    
    jsr     StoreBMPDimensions
    
    ; load arguments onto stack
    sub.l   #SP_OFFSET,sp 
    move.l  a0,BMP_STACK(sp)
    move.w  #HOW_TO_CHUNK_LEFT,CHUNK_LEFT_STACK(sp)
    move.w  #HOW_TO_COVER_CHUNK_TOP,CHUNK_TOP_STACK(sp)
    move.w  #HOW_TO_CHUNK_WIDTH,CHUNK_WIDTH_STACK(sp)
    move.w  #HOW_TO_CHUNK_HEIGHT,CHUNK_HEIGHT_STACK(sp)
    move.w  #HOW_TO_OUTPUT_LEFT,OUTPUT_LEFT_STACK(sp)
    move.w  #HOW_TO_OUTPUT_TOP,OUTPUT_TOP_STACK(sp) 
    
    lea     How_To_State,a4
    move.l  #HOW_TO_OFF,(a4)
    move.l  #CLEAR_ADDRESS,a4
    
    jsr     LoadChunk   
    rts
    
LoadMystery

    ; lea windows background for main menu
    lea     Mystery_BMP,a0
    
    jsr     StoreBMPDimensions
    
    ; load arguments onto stack
    sub.l   #SP_OFFSET,sp 
    move.l  a0,BMP_STACK(sp)
    move.w  #SMILEY_NEUTRAL_OFFSET,CHUNK_LEFT_STACK(sp)
    move.w  #SMILEY_CHUNK_TOP,CHUNK_TOP_STACK(sp)
    move.w  #SMILEY_LENGTH,CHUNK_WIDTH_STACK(sp)
    move.w  #SMILEY_LENGTH,CHUNK_HEIGHT_STACK(sp)
    move.w  d5,OUTPUT_LEFT_STACK(sp)
    move.w  d2,OUTPUT_TOP_STACK(sp)  
    
    ; flash image
    jsr     LoadChunk 
 
    rts
    
StoreBMPDimensions

    ; store value of bmp width
    move.w  BMP_WIDTH_OFFSET(a0),d1
    ror.w   #ROTATION_VALUE,d1
    move.w  d1,(BMPWidth)
    
    ; store value of bmp height
    move.w  BMP_HEIGHT_OFFSET(a0),d1
    ror.w   #ROTATION_VALUE,d1
    move.w  d1,(BMPHeight)
    
    clr.l   d1
    
    rts

    
Windows_Background          INCBIN  "windowsbackground.bmp"
Smiley_Face                 INCBIN  "smiley.bmp"
Pop_Up                      INCBIN  "popup.bmp"
How_To                      INCBIN  "howtoplay.bmp"
Mystery_BMP                 INCBIN  "mystery.bmp"

Mystery_Padding         ds.w    1

NumBits                 ds.b    1
BytesPerColor           ds.b    1
Padding                 ds.w    1
BMPWidth                ds.w    1
BMPHeight               ds.w    1
ChunkXBoundary          ds.w    1
ChunkYBoundary          ds.w    1































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
