*Decode ADD instruction
*D0 will be size
*D1 will be data register
*D2 will be direction
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
                    BEQ     ADD_DECODE_ERR           *Its actually ADDA


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

SUBVALIDITY                                         * Lets check the data register first
                    CMP.B   #%000,D1
                    BEQ     SUB_DATAREG_VALID
                    CMP.B   #%001,D1
                    BEQ     SUB_DATAREG_VALID
                    CMP.B   #%010,D1
                    BEQ     SUB_DATAREG_VALID
                    CMP.B   #%011,D1
                    BEQ     SUB_DATAREG_VALID
                    CMP.B   #%100,D1
                    BEQ     SUB_DATAREG_VALID
                    CMP.B   #%101,D1
                    BEQ     SUB_DATAREG_VALID
                    CMP.B   #%110,D1
                    BEQ     SUB_DATAREG_VALID
                    CMP.B   #%111,D1
                    BEQ     SUB_DATAREG_VALID
                    BRA     ADD_DECODE_ERR


SUB_DATAREG_VALID                                   * LET'S THE DIRECTION NOW
                    CMP.B   #0,D2
                    BEQ     SUB_DN_DESTINATION      *Dn is destination, Dn + <ea>->Dn all effective address are valid
                    CMP.B   #1,D2
                    BEQ     SUB_DN_SOURCE           *Dn is source, <ea> + Dn-><ea>some effectve addresses are not valid
                    BRA     ADD_DECODE_ERR

SUB_DN_DESTINATION                                  *check mode for Dn is destination (Dn + <ea>->Dn)
                    CMP.B   #%000,D3
                    BEQ     SUB_MODE_VALIDATE
                    CMP.B   #%001,D3
                    BEQ     CHECK_SIZE_SUB_AR         *If An is the effective address, check the size, if byte invalid
                    CMP.B   #%010,D3
                    BEQ     SUB_MODE_VALIDATE
                    CMP.B   #%011,D3
                    BEQ     SUB_MODE_VALIDATE
                    CMP.B   #%100,D3
                    BEQ     SUB_MODE_VALIDATE
                    CMP.B   #%111,D3
                    BEQ     SUB_MODE_VALIDATE
                    BRA     ADD_DECODE_ERR

                                                    *Check if source register is valid (Dn + <ea>->Dn)

SUB_MODE_VALIDATE
                    CMP.B   #%001,D3
                    BEQ     VALIDATE_SUBAR
                    CMP.B   #%010,D3
                    BEQ     VALIDATE_SUBAR
                    CMP.B   #%011,D3
                    BEQ     VALIDATE_SUBAR
                    CMP.B   #%100,D3
                    BEQ     VALIDATE_SUBAR

VALIDATE_SUBAR                                     *An,it can be be 7
                    CMP.B   #111,D4
                    BEQ     ADD_DECODE_ERR
                    BRA     SUB_IMM_SOURCE


SUB_IMM_SOURCE      CMP.B   #%111,D3
                    BNE     SUB_SOURCE
                    CMP.B   #%000,D4
                    BEQ     SUB_GET_VALUE
                    CMP.B   #%001,D4
                    BEQ     SUB_GET_VALUE
                    CMP.B   #%100,D4
                    BEQ     SUB_GET_VALUE
                    BRA     ADD_DECODE_ERR

SUB_GET_VALUE                                       *Now we need to figure out how much data to snag after, should we get a word or a long?
                    CMP.B   #%100,D4
                    BEQ     SUBS_POUND
                    CMP.B   #%000,D4
                    BEQ     SUBS_GETWORD
                    CMP.B   #%001,D4
                    BEQ     SUBS_GETLONG

SUBS_POUND
                    CMP.B   #%10,D0                 *The number need to be added is a literal
                    BEQ     SUBS_GETLONG
                    BRA     SUBS_GETWORD


SUBS_GETWORD
                    MOVE.W  (A1)+,D5                *D5 store the word data
                    BRA     SUB_SOURCE


SUBS_GETLONG
                    MOVE.L  (A1)+,D5                *D5 store the long data
                    BRA     SUB_SOURCE

SUB_SOURCE
                    CMP.B   #%111,D2
                    BNE     SUB_VERIFIED
                    CMP.B   #%10,D1
                    BEQ     SUB_GETLONG
                    BRA     SUB_GETWORD

SUB_GETLONG
                    MOVE.L  (A1)+,D6
                    BRA     SUB_CHECKLENGTH
SUB_GETWORD
                    MOVE.W  (A1)+,D6
                    BRA     SUB_CHECKLENGTH

SUB_CHECKLENGTH     MOVEM.L D0-D7,-(SP)
                    MOVE.L  A1,D0
                    MOVE.L  LINESTARTLOC,D1
                    SUB.L   D1,D0                   *D0 now has the length of the instruction in bytes
                    MULU    #8,D0                   *Now D0 has the number of bits
                    ANDI.L  #$000000FF,D0
                    MOVE.B  (LINELENGTH),D2         *D2 has line length in bits
                    CMP.B   D0,D2
                    BNE     ADD_DECODE_ERR
                    MOVEM.L (SP)+,D0-D7
                    BRA     SUB_VERIFIED
                    
                    
                    
CHECK_SIZE_SUB_AR   CMP.B   #%00,D0                 *The size is byte, invalid size
                    BNE     SUB_MODE_VALIDATE       *The size is not byte
                    BEQ     ADD_DECODE_ERR          *ERROR



SUB_DN_SOURCE                                       *check mode for Dn is source

                    CMP.B   #%000,D3
                    BEQ     ADD_DECODE_ERR
                    CMP.B   #%001,D3
                    BEQ     ADD_DECODE_ERR
                    CMP.B   #%111,D3
                    BEQ     CHECK_SUB_REG           *Check register to tell if this is valid or not
                    CMP.B   #%010,D3
                    BEQ     SUB_MODE_VALIDATE       *Check if the absolute value is short or long
                    CMP.B   #%011,D3
                    BEQ     SUB_MODE_VALIDATE
                    CMP.B   #%100,D3
                    BEQ     SUB_MODE_VALIDATE
                    CMP.B   #%011,D3
                    BEQ     SUB_MODE_VALIDATE
                    BRA     ADD_DECODE_ERR


CHECK_SUB_REG       CMP.B   #%100,D4
                    BEQ     ADD_DECODE_ERR
                    BNE     SUB_MODE_VALIDATE


                                                    *we need two different ways to handle the printing
                                                    *for each scenarios Dn + <ea> -> Dn
                                                    *and for <ea> + Dn -> <ea>

SUB_VERIFIED
                    CMP.B   #%0,D2
                    BEQ     SUB_DECODE_PRINT        *deployed when Dn + <ea> -> Dn, Uses the print method from MOVE
                    BNE     SUB_DECODE_PRINT_2      *deployed when <ea> + Dn -> <ea>

                                                    *prints add when Dn + <ea>->dn

SUB_DECODE_PRINT    LEA     SUBSTRING,A0
                    JSR     PRINT_SR
                    BRA     PRINT_SIZE


SUB_DECODE_PRINT_2                                  *prints add when <ea> + Dn -><ea>
                    LEA     SUBSTRING,A0
                    JSR     PRINT_SR
                    BRA     PRINT_SIZE_2




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
