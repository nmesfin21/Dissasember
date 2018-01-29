* Uses the format 0 1 1 1 | 3 register bits | 0 | 8 data bits
*   where register bits is the number of the data register
*   to move to
*
*
*
                CLR.L   D0
                CLR.L   D1
                CLR.L   D2
                CLR.L   D3
                CLR.L   D4
                CLR.L   D5
                CLR.L   D6
                CLR.L   D7
                LEA     LINESTARTLOC,A1
                CMPI.B  #16,(LINELENGTH)
                BNE     MOVEQ_ERROR        *instruction is too long
                        
                MOVE.B  (A1)+,D3            *D3 will contain the number of register
                LSR.B   #1,D3
                BCS     MOVEQ_ERROR         *Must have 0 between data and register
                
                *At this point we know instruction is valid
                ANDI.B  #%00000111,D3      *Clear out the leading bits
                MOVE.B  (A1),D1             *D3 will now have the data

                *Print out the MOVEQ.L part
                LEA     MOVEQSTRING,A0
                JSR     PRINT_SR
                JSR     SHIFTCURSOR
                *Then print out data follow by comma and data register
                LEA     POUNDSTRING,A0
                JSR     PRINT_SR
                LEA     DOLLARSTRING,A0
                JSR     PRINT_SR
                MOVE.B  D1,D2               *Copy data into D2, D1 will be first hex
                LSR.B   #4,D1
                ANDI.B  #%00001111,D2
                CMP.B   #9,D1
                BGT     MOVEQ_FLETTER
                ADDI.B  #48,D1       
                BRA     MOVEQ_SECOND
MOVEQ_FLETTER   ADDI.B  #55,D1
                BRA     MOVEQ_SECOND
MOVEQ_SECOND    MOVE.B  #6,D0
                TRAP    #15                *Finish printing first character
                CMP.B   #9,D2
                BGT     MOVEQ_SLETTER
                ADDI.B  #48,D2
                BRA     MOVEQ_PRNTS
MOVEQ_SLETTER   ADDI.B  #55,D2
                BRA     MOVEQ_PRNTS
MOVEQ_PRNTS     MOVE.B  D2,D1   
                TRAP    #15
                LEA     COMMASTRING,A0
                JSR     PRINT_SR
                LEA     DSTRING,A0
                JSR     PRINT_SR
                MOVE.B  D3,D1
                MOVE.B  #10,D2
                MOVE.B  #15,D0
                TRAP    #15
                LEA     LINEEND,A0
                JSR     PRINT_SR
                RTS
                
MOVEQ_ERROR     JSR     PRINTLINE_SR
                RTS



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
