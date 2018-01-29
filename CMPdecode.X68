*Decode CMP instruction
*D0 will be size
*D1 will be data register
*D2 will be direction, 0
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

                                                    *check if it is ADDA instead
                    MOVE.W  (A1),D0
                    LSR.W   #6,D0
                    ANDI.B  #%00000011,D0
                    CMP.B   #%11,D0                 *check if 11,holds the size
                    BEQ     ADDADECODE_SR           *Its actually ADDA


                    MOVE.B  (A1),D1                 *Data register
                    ANDI.B  #%00001110,D1           *We only need the data register
                    LSR.B   #1,D1


                    MOVE.B  (A1),D2                 *Direction,    *determine if dn + <ea>-><ea> or <ea> + dn->dn
                    ANDI.B  #%00000001,D2           *we only need the lat bit


                    MOVE.W  (A1),D3
                    ANDI.W  #%0000000000111000,D3   *we only care about the three bits
                    LSR.B   #3,D3

                    MOVE.B  (A1)+,D7
                    MOVE.B  (A1)+,D4                *register
                    ANDI.B  #%00000111,D4           *We only care about the last beat

                    CLR     D7

CMPVALIDITY                                         * Lets check the data register first, 
                                                    * it has to be between (d0 - d7), error otherwise
                    CMP.B   #%000,D1
                    BEQ     CMP_DATAREG_VALID       * data register D0
                    CMP.B   #%001,D1
                    BEQ     CMP_DATAREG_VALID       * data register D1
                    CMP.B   #%010,D1
                    BEQ     CMP_DATAREG_VALID       * data register D2
                    CMP.B   #%011,D1
                    BEQ     CMP_DATAREG_VALID       * data register D3
                    CMP.B   #%100,D1
                    BEQ     CMP_DATAREG_VALID       * data register D4
                    CMP.B   #%101,D1
                    BEQ     CMP_DATAREG_VALID       * data register D5
                    CMP.B   #%110,D1
                    BEQ     CMP_DATAREG_VALID       * data register D6
                    CMP.B   #%111,D1
                    BEQ     CMP_DATAREG_VALID       * data register D7
                    BRA     CMP_DECODE_ERR


CMP_DATAREG_VALID                                   * lets check the direction, if d2 is is not 0, its invalid
                    CMP.B   #0,D2
                    BEQ     CMP_DIRECTION_VALID     *Dn is destination, Dn - souce->cc all effective address are valid
                    BRA     CMP_DECODE_ERR
                        
CMP_DIRECTION_VALID                                 *At this point we know the data register and the direction are valid
                                                    *The size bits could only be %01, %10 and %00, otherwise its error
                    CMP.B   #%00,d0
                    BEQ     CMP_SIZE_VALID
                    CMP.B   #%01,d0
                    BEQ     CMP_SIZE_VALID
                    CMP.B   #%10,d0
                    BEQ     CMP_SIZE_VALID
                    BRA     CMP_DECODE_ERR
                    


CMP_SIZE_VALID                                      *At this point the size,direction and data register are valid 
                                                    *check mode (Dn - <ea>->CC), All effective address are valid
                    CMP.B   #%000,D3
                    BEQ     CMP_IMM_SOURCE
                    CMP.B   #%001,D3
                    BEQ     CHECK_SIZE_4CMP_AR      *If An is the effective address, check the size, if byte invalid
                    CMP.B   #%010,D3
                    BEQ     CMP_IMM_SOURCE
                    CMP.B   #%011,D3
                    BEQ     CMP_IMM_SOURCE
                    CMP.B   #%100,D3
                    BEQ     CMP_IMM_SOURCE
                    CMP.B   #%111,D3
                    BEQ     CMP_IMM_SOURCE
                    BRA     CMP_DECODE_ERR

                                                    
                                                    

CMP_MODE_VALIDATE                                   *Check if source register is valid (Dn - <ea>->CC)
                                                    *in this case An can be 7, *this section could be removed
                                                    *i just left it to be here
                    BRA     CMP_IMM_SOURCE

CMP_IMM_SOURCE      CMP.B   #%111,D3                * if the mode is not Literal value, we are done, let jump
                    BNE     CMP_VERIFIED            * its has been verified by previous stages
                    CMP.B   #%000,D4
                    BEQ     CMP_GET_VALUE           * the literal is (xxx).w
                    CMP.B   #%001,D4
                    BEQ     CMP_GET_VALUE           * the literal is (xxx).l
                    CMP.B   #%100,D4
                    BEQ     CMP_GET_VALUE           * the literal is #<data>
                    BRA     CMP_DECODE_ERR          * error

CMP_GET_VALUE                                       *Now we need to figure out how much data to snag after, should we get a word or a long?
                    CMP.B   #%100,D4
                    BEQ     CMP_POUND               * branch to add the value of the literal #<data>
                    CMP.B   #%000,D4
                    BEQ     CMP_GETWORD             * branch to add the value of the absolute (xxx).w
                    CMP.B   #%001,D4
                    BEQ     CMP_GETLONG             * branch to add the value of the absolute (xxx).l

CMP_POUND
                    CMP.B   #%10,D0                 *The number need to be added is a literal
                    BEQ     CMP_GETLONG
                    BRA     CMP_GETWORD


CMP_GETWORD
                    MOVE.W  (A1)+,D5                *D5 store the word data
                    BRA     CMP_SOURCE


CMP_GETLONG
                    MOVE.L  (A1)+,D5                *D5 store the long data
                    BRA     CMP_SOURCE

CMP_SOURCE                                          *everything is good if we get here
                    BRA    CMP_VERIFIED


                                                

CMP_VERIFIED                                        *At this point cmp is verfied, lets print
                    CMP.B   #%0,D2
                    BEQ     CMP_DECODE_PRINT        *deployed when Dn - <ea> -> CC, Uses the print method from MOVE
                    BNE     CMP_DECODE_ERR          

                                                    *prints CMP when Dn - <ea>->cc

CMP_DECODE_PRINT    LEA     CMPSTRING,A0
                    JSR     PRINT_SR
                    BRA     PRINT_SIZE

PRINT_CMPSIZE       CMP.B   #%00,D0                 *Branch to print size .B
                    BEQ     SIZE_CMPB
                    CMP.B   #%01,D0
                    BEQ     SIZE_CMPW               *Branch to print size .W
                    CMP.B   #%10,D0
                    BEQ     SIZE_CMPL               *Branch to print size .L

SIZE_CMPB           LEA     BYTESTRING,A0           *size is byte, prints .B
                    JSR     PRINT_SR
                    BRA     MOVEAS
SIZE_CMPW           LEA     WORDSTRING,A0           *size is word, prints .w
                    JSR     PRINT_SR
                    BRA     MOVEAS
SIZE_CMPL           LEA     LONGSTRING,A0           *size is long, prints .l
                    JSR     PRINT_SR
                    BRA     MOVEAS




CHECK_SIZE_4CMP_AR  CMP.B   #%00,D0                 *The size is byte, invalid size
                    BNE     CMP_MODE_VALIDATE       *The size is not byte
                    BEQ     CMP_DECODE_ERR          *ERROR

CMP_DECODE_ERR      JSR     PRINTLINE_SR
                    RTS


CMP_DECODE_DONE     LEA     LINEEND,A0
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
