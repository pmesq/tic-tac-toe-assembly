NAME "TicTacToe"
ORG 100H
.MODEL small
.STACK 512d

.DATA

board   DB " | | ", 10, 13, " | | ", 10, 13, " | | ", 10, 13, 10, 13, "$"
    
msgTitle            DB "Tic Tac Toe", 10, 13, 10, 13, "$"
msgSquaresNumbers   DB "Squares numbers:", 10, 13, "1|2|3", 10, 13, "4|5|6", 10, 13, "7|8|9", 10, 13, 10, 13, "$"
msgBoard            DB "Current board:", 10, 13, "$"
msgMarkError        DB "Unavailable square. Try again", 10, 13, "$"
msgEnterSquare      DB "Player * plays now", 10, 13, "Enter the square number: $"
msgPlayerWins       DB "Player * wins!", 10, 13, "$"
msgDraw             DB "Draw!$"
msgFinish           DB "Press anything to exit... $"

.CODE

MOV BH, "."; Game is running
MOV BL, "X"; Player X starts playing

JMP run

; Clear screen
clear:
    MOV AX, 00H
    INT 10H
RET

; Print title
printTitle:
    MOV AH, 09H
    LEA DX, msgTitle
    INT 21H
RET

; Print squares numbers
printSquaresNumbers:
    MOV AH, 09H
    LEA DX, msgSquaresNumbers
    INT 21H
RET

; Print board
printBoard:
    MOV AH, 09H
    LEA DX, msgBoard
    INT 21H
    LEA DX, board
    INT 21H
RET

; Reads the square number to be marked
; @return   AL = square number read
read:
    LEA DI, msgEnterSquare
    MOV [DI+7], BL

    MOV AH, 09H
    LEA DX, msgEnterSquare
    INT 21H

    MOV AH, 01H
    INT 21H
RET

; Converts square number into board array position
; @param    AL = square number
; @return   AL = board array position
convertSquareNumber:
    SUB AL, 31H

    MOV DL, 2
    MUL DL

    CMP AL, 6
    JB convertEnd
    INC AL

    CMP AL, 13
    JB convertEnd
    INC AL

    convertEnd:
RET

; Marks in selected board square the current player symbol
; @param    AL = square number
; @param    BL = current player symbol
mark:
    CMP AL, "1"
    JB run

    CMP AL, "9"
    JA run
    
    CALL convertSquareNumber

    LEA DI, board
    MOV AH, 0
    ADD DI, AX

    CMP [DI], " "
    JNE run

    MOV [DI], BL
RET        

; Calculates game result
; @param    board = board
; @return   BH = game result
calculateResult:
    LEA SI, board
    MOV CX, 3
    verifyRow:
        MOV AL, [SI]
        CMP AL, " "
        JE verifyRowContinue
        CMP AL, [SI+2]
        JNE verifyRowContinue
        CMP AL, [SI+4]
        JNE verifyRowContinue
        JMP returnWinner

        verifyRowContinue:
            ADD SI, 7
    LOOP verifyRow
    
    LEA SI, board
    MOV CL, 3
    verifyCol:
        MOV AL, [SI]
        CMP AL, " "
        JE verifyColContinue
        CMP AL, [SI+7]
        JNE verifyColContinue      
        CMP AL, [SI+14]
        JNE verifyColContinue
        JMP returnWinner

        verifyColContinue:
            ADD SI, 2
    LOOP verifyCol
    
    LEA SI, board
    verifyDescDiag:
        MOV AL, [SI]
        CMP AL, " "
        JE verifyAscDiag
        CMP AL, [SI+9]
        JNE verifyAscDiag
        CMP AL, [SI+18]
        JNE verifyAscDiag
        JMP returnWinner

    verifyAscDiag:
        MOV AL, [SI+4]
        CMP AL, " "
        JE verifyDraw
        CMP AL, [SI+9]
        JNE verifyDraw
        CMP AL, [SI+14]
        JNE verifyDraw
        JMP returnWinner

    verifyDraw:
        CMP [SI], " "
        JNE returnResult
        ADD SI, 2
        CMP [SI], " "
        JNE returnResult
        ADD SI, 2
        CMP [SI], " "
        JNE returnResult
        ADD SI, 3
        CMP [SI], " "
        JNE returnResult
        ADD SI, 2
        CMP [SI], " "
        JNE returnResult
        ADD SI, 2
        CMP [SI], " "
        JNE returnResult
        ADD SI, 3
        CMP [SI], " "
        JNE returnResult
        ADD SI, 2
        CMP [SI], " "
        JNE returnResult
        ADD SI, 2
        CMP [SI], " "
        JNE returnResult

    returnDraw:
        MOV BH, " "
        JMP returnResult

    returnWinner:
        MOV BH, AL

    returnResult:
RET

; Handles result
; @param    BH = game result
handleResult:
    CMP BH, "."
    JNE finish
RET

; Changes turn
; @param    BL = current turn
; @retutn   BL = new turn
changeTurn:
    CMP BL, "X"
    JE setTurnO
    MOV BL, "X"
    JMP changeTurnContinue
    setTurnO:
    MOV BL, "O"
    changeTurnContinue:
RET

; Game loop
run:
    CALL clear
    CALL printTitle
    CALL printSquaresNumbers
    CALL printBoard
    CALL read
    CALL mark
    CALL calculateResult
    CALL handleResult
    CALL changeTurn
JMP run
      
; Finishes game
; @param    BH = result
finish:
    CALL clear
    CALL printTitle
    CALL printBoard

    MOV AH, 09H

    CMP BH, " "
    JE leaDraw

    LEA DI, msgPlayerWins
    MOV [DI+7], BH
    LEA DX, msgPlayerWins

    JMP finishContinue

    leaDraw:
        LEA DX, msgDraw

    finishContinue:
        INT 21H

        LEA DX, msgFinish
        INT 21H

        MOV AH, 08H
        INT 21H

        MOV AH, 00H
        INT 21H
