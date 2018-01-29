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

                    MOVE.B  (A1),D2                 *Direction, it has to be 1 for MULS.W
                    ANDI.B  #%00000001,D2           *we only need the last bit


                    MOVE.W  (A1),D3
                    ANDI.W  #%0000000000111000,D3   *we only care about the three bits
                    LSR.B   #3,D3

                    MOVE.B  (A1)+,D7
                    MOVE.B  (A1)+,D4                *register
                    ANDI.B  #%00000111,D4           *We only care about the last beat

                    CLR     D7

MULSWVALIDITY        
                    CMP.B   #%1,D2                   *Checks the value at D2, if it is not 1, its error
                    BEQ     MULSW_DIR_VALID
                    BRA     MULSW_DECODE_ERR

MULSW_DIR_VALID
                                                    * Lets check the data register first
                                                    * the data register is going to be one of the
                                                    * eight registers (D0 - D7)
                    CMP.B   #%000,D1
                    BEQ     MULSW_DATAREG_VALID     * data register D0
                    CMP.B   #%001,D1
                    BEQ     MULSW_DATAREG_VALID     * data register D1
                    CMP.B   #%010,D1
                    BEQ     MULSW_DATAREG_VALID     * data register D2
                    CMP.B   #%011,D1
                    BEQ     MULSW_DATAREG_VALID     * data register D3
                    CMP.B   #%100,D1
                    BEQ     MULSW_DATAREG_VALID     * data register D4
                    CMP.B   #%101,D1
                    BEQ     MULSW_DATAREG_VALID     * data register D5
                    CMP.B   #%110,D1
                    BEQ     MULSW_DATAREG_VALID     * data register D6
                    CMP.B   #%111,D1
                    BEQ     MULSW_DATAREG_VALID     * data register d7
                    BRA     MULSW_DECODE_ERR        * error
                     
                    
                    


MULSW_DATAREG_VALID                                 *check mode
                                                    *Valid addressing modeS include
                                                    *Dn,(An),(An)+, -(An), (xxx).w, (xxx).L and #<data>
                                                    *otherwise, it is invalid addressing code or
                                                    *out of this assignment scope 
                    CMP.B   #%000,D3
                    BEQ     MULSW_SOURCE
                    CMP.B   #%010,D3
                    BEQ     MULSW_SOURCE
                    CMP.B   #%011,D3
                    BEQ     MULSW_SOURCE
                    CMP.B   #%100,D3
                    BEQ     MULSW_SOURCE
                    CMP.B   #%111,D3                *If the mode is 111,branch to immediate data
                    BEQ     MULSW_IMM_SOURCE
                    BRA     MULSW_DECODE_ERR

                              
MULSW_IMM_SOURCE                                    *if we get here, the source operand is an immediate value
                                                    *it is either, (xxx).w, (xxx).L or #<data>, otherwise error
                                                    *let's check what it is and figure out how much it is
                    CMP.B   #%000,D4
                    BEQ     MULSW_GETWORD           *the absolute value is (xxx).w
                    CMP.B   #%001,D4
                    BEQ     MULSW_GETLONG           *the absolute value is (xxx).L
                    CMP.B   #%100,D4
                    BEQ     MULSW_POUND             *the absolute value is #<data>
                    BRA     MULSW_DECODE_ERR



MULSW_POUND                                         *here, we know the immediate value is literal #<data>
                    BRA     MULSW_GETWORD

MULSW_GETWORD
                    MOVE.W  (A1)+,D5                *D5 store the word data
                    CMPI.W  #65535,D5
                    BHI     MULSW_DECODE_ERR        *if the value is greater than 16 bits, its invalid
                    BRA     MULSW_VERIFIED

MULSW_GETLONG
                    MOVE.L  (A1)+,D5                *D5 store the long data
                    BRA     MULSW_VERIFIED

MULSW_SOURCE
                    CMP.B   #%111,D3
                    BNE     MULSW_VERIFIED


                                                    *we need two different ways to handle the printing
                                                    *for each scenarios Dn + <ea> -> Dn
                                                    *and for <ea> + Dn -> <ea>

MULSW_VERIFIED
                    CLR     D0                      *clear d0
                    MOVE.B  #%11,D0                 *MOVE %11 D0, so that the decoder use move printer, correctly
                    CLR     D2                      *clear D2, so that the decoder use move printer
                    BRA     MULSW_PRINT

                                                    *prints add when Dn + <ea>->dn

MULSW_PRINT         LEA     MULSWSTRING,A0          *prints MULS
                    JSR     PRINT_SR
                    LEA     WORDSTRING,A0           *Prints .w
                    JSR     PRINT_SR
                    BRA     MOVEAS                  *branch to MOVEAS to print the remaining instructions






MULSW_DECODE_ERR    JSR     PRINTLINE_SR            *Prints the error memory address with related junk
                    RTS                             *we are done


MULSW_DECODE_DONE   LEA     LINEEND,A0              *prints line end
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
