*Decode DIVU.W instruction
*D1 will be data register
*D3 will be mode
*D4 will be register
*D5 is immediate/source address
*D6 is dest address
                    CLR.L   D0
                    CLR.L   D1
                    CLR.L   D2
                    CLR.L   D3
                    CLR.L   D4
                    CLR.L   D5
                    CLR.L   D6
                    CLR.L   D7
                    LEA     LINESTARTLOC,A1


                    MOVE.B  (A1),D1                 *Data register
                    ANDI.B  #%00001110,D1           *We only need the data register
                    LSR.B   #1,D1
                    
                    MOVE.B  (A1),D2                 *Direction,  it has to be 0
                    ANDI.B  #%00000001,D2           *we only need the last bit



                    MOVE.W  (A1),D3
                    ANDI.W  #%0000000000111000,D3   *we only care about the three bits
                    LSR.B   #3,D3

                    MOVE.B  (A1)+,D7
                    MOVE.B  (A1)+,D4                *register
                    ANDI.B  #%00000111,D4           *We only care about the last beat

                    CLR     D7
                    
                    
DIVUWVALIDITY        
                    CMP.B   #%0,D2                   *Checks the value at D2, if it is not 1, its error
                    BEQ     DIVUW_DIR_VALID
                    BRA     DIVUW_DECODE_ERR

DIVUW_DIR_VALID                                       * Lets check the data register first
                                                    * the data register is going to be one of the
                                                    * eight registers (D0 - D7)
                    CMP.B   #%000,D1
                    BEQ     DIVUW_DATAREG_VALID
                    CMP.B   #%001,D1
                    BEQ     DIVUW_DATAREG_VALID
                    CMP.B   #%010,D1
                    BEQ     DIVUW_DATAREG_VALID
                    CMP.B   #%011,D1
                    BEQ     DIVUW_DATAREG_VALID
                    CMP.B   #%100,D1
                    BEQ     DIVUW_DATAREG_VALID
                    CMP.B   #%101,D1
                    BEQ     DIVUW_DATAREG_VALID
                    CMP.B   #%110,D1
                    BEQ     DIVUW_DATAREG_VALID
                    CMP.B   #%111,D1
                    BEQ     DIVUW_DATAREG_VALID
                    BRA     DIVUW_DECODE_ERR


DIVUW_DATAREG_VALID                                 *check mode
                                                    *Valid addressing modeS include
                                                    *Dn,(An),(An)+, -(An), (xxx).w, (xxx).L and #<data>
                                                    *otherwise, it is invalid addressing code or
                                                    *out of this assignment scope 
                    CMP.B   #%000,D3
                    BEQ     DIVUW_SOURCE
                    CMP.B   #%010,D3
                    BEQ     DIVUW_SOURCE
                    CMP.B   #%011,D3
                    BEQ     DIVUW_SOURCE
                    CMP.B   #%100,D3
                    BEQ     DIVUW_SOURCE
                    CMP.B   #%111,D3                *If the mode is 111,branch to immediate data
                    BEQ     DIVUW_IMM_SOURCE
                    BRA     DIVUW_DECODE_ERR

                              
DIVUW_IMM_SOURCE                                    *if we get here, the source operand is an immediate value
                                                    *it is either, (xxx).w, (xxx).L or #<data>, otherwise error
                                                    *let's check what it is and figure out how much it is
                    CMP.B   #%000,D4
                    BEQ     DIVUW_GETWORD           *the absolute value is (xxx).w
                    CMP.B   #%001,D4
                    BEQ     DIVUW_GETLONG           *the absolute value is (xxx).L
                    CMP.B   #%100,D4
                    BEQ     DIVUW_POUND             *the absolute value is #<data>
                    BRA     DIVUW_DECODE_ERR



DIVUW_POUND                                         *here, we know the immediate value is literal #<data>
                    BRA     DIVUW_GETWORD

DIVUW_GETWORD
                    MOVE.W  (A1)+,D5                *D5 store the word data
                    CMPI.W  #65535,D5
                    BHI     DIVUW_DECODE_ERR        *if the value is greater than 16 bits, its invalid
                    BRA     DIVUW_VERIFIED

DIVUW_GETLONG
                    MOVE.L  (A1)+,D5                *D5 store the long data
                    BRA     DIVUW_VERIFIED

DIVUW_SOURCE
                    CMP.B   #%111,D3
                    BNE     DIVUW_VERIFIED


                                                    *we need two different ways to handle the printing
                                                    *for each scenarios Dn + <ea> -> Dn
                                                    *and for <ea> + Dn -> <ea>

DIVUW_VERIFIED
                    CLR     D0                      *clear d0
                    MOVE.B  #%11,D0                 *MOVE %11 D0, so that the decoder use move printer, correctly
                    BRA     DIVUW_PRINT

                                                    *prints add when Dn + <ea>->dn

DIVUW_PRINT         LEA     DIVUWSTRING,A0          *prints DIVU
                    JSR     PRINT_SR
                    LEA     WORDSTRING,A0           *Prints .w
                    JSR     PRINT_SR
                    BRA     MOVEAS                  *branch to MOVEAS to print the remaining instructions






DIVUW_DECODE_ERR    JSR     PRINTLINE_SR            *Prints the error memory address with related junk
                    RTS                             *we are done


DIVUW_DECODE_DONE   LEA     LINEEND,A0              *prints line end
                    JSR     PRINT_SR    
                    RTS
                                                    *~Font name~Courier New~
                                                    *~Font size~10~
                                                    *~Tab type~1~
                                                    *~Tab size~4~








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
