*Decode AND instruction
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


                    MOVE.W  (A1),D0                 *move the word in do
                    LSR.W   #6,D0                   *shift the word 6 place to the right
                    ANDI.B  #%00000011,D0           *we only need the two bits for the sized
                    CMP.B   #%11,D0                 *check if 11,holds the size
                    BEQ     MULSW_SR                *Its actually MULS.W



                    MOVE.B  (A1),D1                 *Data register
                    ANDI.B  #%00001110,D1           *We only need the three bits data register
                    LSR.B   #1,D1                   *shift 1 bit to the right


                    MOVE.B  (A1),D2                 *Direction,    *determine if AND Dn, <ea> or AND <ea>, Dn
                    ANDI.B  #%00000001,D2           *we only need the lat bit


                    MOVE.W  (A1),D3
                    ANDI.W  #%0000000000111000,D3   *we only care about the three bits
                    LSR.B   #3,D3

                    MOVE.B  (A1)+,D7
                    MOVE.B  (A1)+,D4                *register
                    ANDI.B  #%00000111,D4           *We only care about the last beat

                    CLR     D7

ANDVALIDITY                                         * Lets check the data register first
                    CMP.B   #%000,D1
                    BEQ     AND_DATAREG_VALID       *the data register is D0
                    CMP.B   #%001,D1
                    BEQ     AND_DATAREG_VALID       *the data register is D1 
                    CMP.B   #%010,D1
                    BEQ     AND_DATAREG_VALID       *the data register is D2
                    CMP.B   #%011,D1
                    BEQ     AND_DATAREG_VALID       *the data register is D3
                    CMP.B   #%100,D1
                    BEQ     AND_DATAREG_VALID       *the data register is D4
                    CMP.B   #%101,D1
                    BEQ     AND_DATAREG_VALID       *the data register is D5
                    CMP.B   #%110,D1
                    BEQ     AND_DATAREG_VALID       *the data register is D6
                    CMP.B   #%111,D1
                    BEQ     AND_DATAREG_VALID       *the data register is D7
                    BRA     AND_DECODE_ERR          *we will never get here, if we do error


AND_DATAREG_VALID                                   * LET'S THE DIRECTION NOW
                    CMP.B   #0,D2
                    BEQ     AND_DN_DESTINATION      *Dn is destination, AND <ea>, Dn 
                    CMP.B   #1,D2
                    BEQ     AND_DN_SOURCE           *Dn is source, AND Dn, <ea> some effectve addresses are not valid
                    BRA     AND_DECODE_ERR

AND_DN_DESTINATION                                  *check mode for Dn is destination (Dn + <ea>->Dn)
                                                    *<EA> cant be address register
                    CMP.B   #%000,D3
                    BEQ     AND_MODE_VALIDATE       *<EA> is Dn
                    CMP.B   #%001,D3
                    BEQ     AND_DECODE_ERR          *If An is the effective address, check the size, if byte invalid
                    CMP.B   #%010,D3
                    BEQ     AND_MODE_VALIDATE       *<EA> is address register indirect
                    CMP.B   #%011,D3
                    BEQ     AND_MODE_VALIDATE       *<EA> is address register post increment
                    CMP.B   #%100,D3
                    BEQ     AND_MODE_VALIDATE       *<EA> is address register pre decrement
                    CMP.B   #%111,D3
                    BEQ     AND_MODE_VALIDATE       *<EA> could be (xxx).w, (xxx).l or #<data>
                    BRA     AND_DECODE_ERR

                                                    
                                                    

AND_MODE_VALIDATE                                   *Lets check what we need to do next
                
                    CMP.B   #%111,D3
                    BNE     AND_SOURCE              *the <EA> is not absolute value            
                    CMP.B   #%000,D4
                    BEQ     AND_GET_VALUE           *the <EA> is absolute word
                    CMP.B   #%001,D4
                    BEQ     AND_GET_VALUE           *the <EA> is absolute long
                    CMP.B   #%100,D4
                    BEQ     AND_GET_VALUE           *the <EA> is immediate value
                    BRA     AND_DECODE_ERR

AND_GET_VALUE                                       *Now we need to figure out how much data to snag after?
                    CMP.B   #%100,D4
                    BEQ     AND_POUND               *immediate value
                    CMP.B   #%000,D4
                    BEQ     AND_GETS_WORD             *absolute word
                    CMP.B   #%001,D4
                    BEQ     AND_GETS_LONG             *absolute long

AND_POUND
                    CMP.B   #%10,D0                 
                    BEQ     AND_GETS_LONG           *the abolute value is long
                    BRA     AND_GETS_WORD           *the absolute value need to be added is word


AND_GETS_WORD
                    MOVE.W  (A1)+,D5                *D5 store the word data
                    BRA     AND_SOURCE


AND_GETS_LONG
                    MOVE.L  (A1)+,D5                *D5 store the long data
                    BRA     AND_SOURCE

AND_SOURCE
                    CMP.B   #%111,D2
                    BNE     AND_VERIFIED
                    CMP.B   #%10,D1
                    BEQ     ANDED_GETLONG
                    BRA     ANDED_GETWORD

ANDED_GETLONG
                    MOVE.L  (A1)+,D6
                    BRA     AND_CHECKLENGTH
ANDED_GETWORD
                    MOVE.W  (A1)+,D6
                    BRA     AND_CHECKLENGTH

AND_CHECKLENGTH   MOVEM.L D0-D7,-(SP)
                    MOVE.L  A1,D0
                    MOVE.L  LINESTARTLOC,D1
                    SUB.L   D1,D0                   *D0 now has the length of the instruction in bytes
                    MULU    #8,D0                   *Now D0 has the number of bits
                    ANDI.L  #$000000FF,D0
                    MOVE.B  (LINELENGTH),D2         *D2 has line length in bits
                    CMP.B   D0,D2
                    BNE     AND_DECODE_ERR
                    MOVEM.L (SP)+,D0-D7
                    BRA     AND_VERIFIED


                                                    *we need two different ways to handle the printing
                                                    *for each scenarios Dn + <ea> -> Dn
                                                    *and for <ea> + Dn -> <ea>

AND_VERIFIED
                    CMP.B   #%0,D2
                    BEQ     AND_DECODE_PRINT        *deployed when AND.SIZE <EA>,DN, Uses the print method from MOVE
                    BNE     AND_DECODE_PRINT_2      *deployed when AND.SIZE Dn,<EA>

                                                    *prints add when Dn + <ea>->dn

AND_DECODE_PRINT    LEA     ANDSTRING,A0
                    JSR     PRINT_SR
                    BRA     PRINT_SIZE              *uses printer from ADD decoder


AND_DECODE_PRINT_2                                  *prints add when AND  Dn, <EA>
                    LEA     ANDSTRING,A0
                    JSR     PRINT_SR
                    BRA     PRINT_SIZE_2


AND_DN_SOURCE                                       *check mode when Dn is the source

                    CMP.B   #%000,D3
                    BEQ     AND_DECODE_ERR          *<ea> cant be Dn
                    CMP.B   #%001,D3
                    BEQ     AND_DECODE_ERR          *<ea> can't be  An
                    CMP.B   #%111,D3
                    BEQ     CHECK_REG_AND           *Check register to tell if its valid, cant be immediate
                    CMP.B   #%010,D3
                    BEQ     AND_MODE_VALIDATE       *Check if the absolute value is short or long
                    CMP.B   #%011,D3
                    BEQ     AND_MODE_VALIDATE
                    CMP.B   #%100,D3
                    BEQ     AND_MODE_VALIDATE
                    CMP.B   #%011,D3
                    BEQ     AND_MODE_VALIDATE
                    BRA     AND_DECODE_ERR
                                                    

CHECK_REG_AND       CMP.B   #%100,D4
                    BEQ     AND_DECODE_ERR          *cant be immediate
                    BNE     AND_MODE_VALIDATE       *the mode is validate



AND_DECODE_ERR      JSR     PRINTLINE_SR
                    RTS                             *and decoder is done


AND_DECODE_DONE     LEA     LINEEND,A0
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
