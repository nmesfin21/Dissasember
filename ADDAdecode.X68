*Decode ADDA instruction
*D0 will be size
*D1 will be address register
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


                    MOVE.B  (A1),D0
                    ANDI.B  #%00000001,D0           *we only need the last last bit


                    MOVE.B  (A1),D2                 *address register
                    ANDI.B  #%00001110,D2           *We only need the address register
                    LSR.B   #1,D2



                    MOVE.W  (A1),D3                 *mode
                    ANDI.W  #%0000000000111000,D3   *we only care about the three bits
                    LSR.B   #3,D3

                    MOVE.B  (A1)+,D7
                    MOVE.B  (A1)+,D4                *register
                    ANDI.B  #%00000111,D4           *We only care about the last bit

                    CLR     D7



ADDA_VALIDITY
                    CMP.B   #%000,D4                *Lets check the source register
                    BEQ     ADDA_SR_VALID
                    CMP.B   #%001,D4
                    BEQ     ADDA_SR_VALID
                    CMP.B   #%010,D4
                    BEQ     ADDA_SR_VALID
                    CMP.B   #%011,D4
                    BEQ     ADDA_SR_VALID
                    CMP.B   #%100,D4
                    BEQ     ADDA_SR_VALID
                    BRA     ADDA_DECODE_ERR





ADDA_SR_VALID                                       * VALIDATES THE OPCODES
                                                    * Lets check the Address register
                    CMP.B   #%000,D2
                    BEQ     ADDA_ADDREG_VALID
                    CMP.B   #%001,D2
                    BEQ     ADDA_ADDREG_VALID
                    CMP.B   #%010,D2
                    BEQ     ADDA_ADDREG_VALID
                    CMP.B   #%011,D2
                    BEQ     ADDA_ADDREG_VALID
                    CMP.B   #%100,D2
                    BEQ     ADDA_ADDREG_VALID
                    CMP.B   #%101,D2
                    BEQ     ADDA_ADDREG_VALID
                    CMP.B   #%110,D2
                    BEQ     ADDA_ADDREG_VALID
                    CMP.B   #%111,D2
                    BEQ     ADDA_ADDREG_VALID
                    BRA     ADDA_ADDREG_VALID


ADDA_ADDREG_VALID                                   *WE ARE HERE IF THE ADDRESS REGISTER IS VALID
                                                    *LET'S CHECK THE SIZE
                    CMP.B   #%0,D0
                    BEQ     ADDA_SIZE_VALID
                    CMP.B   #%1,D0
                    BEQ     ADDA_SIZE_VALID
                    BRA     ADDA_DECODE_ERR


ADDA_SIZE_VALID                                     *WE ARE HERE IF THE SIZE AND ADDRESS REGISTER ARE VALID
                                                    *LETS CHECK THE MODE
                                                    *THE MODE CAN BE ANYTHING

                    CMP.B   #%000,D3
                    BEQ     ADDA_MODE_VALID
                    CMP.B   #%001,D3
                    BEQ     ADDA_MODE_VALID
                    CMP.B   #%010,D3
                    BEQ     ADDA_MODE_VALID
                    CMP.B   #%000,D3
                    BEQ     ADDA_MODE_VALID
                    CMP.B   #%011,D3
                    BEQ     ADDA_MODE_VALID
                    CMP.B   #%100,D3
                    BEQ     ADDA_MODE_VALID
                    CMP.B   #%111,D3
                    BEQ     ADDA_MODE_VALID
                    BRA     ADDA_DECODE_ERR



ADDA_MODE_VALID                                     *THE MODE IS CHECKED AND VALID AT THIS POINT
                                                    *LETS CHECK FOR REGISTRATIO MODE
                    CMP.B   #%001,D3
                    BEQ     VALIDATE_ADDA_AR
                    CMP.B   #%010,D3
                    BEQ     VALIDATE_ADDA_AR
                    CMP.B   #%011,D3
                    BEQ     VALIDATE_ADDA_AR
                    CMP.B   #%100,D3
                    BEQ     VALIDATE_ADDA_AR

VALIDATE_ADDA_AR                                    *An,it can be be 7
                    CMP.B   #111,D4
                    BEQ     ADDA_DECODE_ERR
                    JSR     ADDA_IMM_SOURCE
                    BRA     ADDA_VERIFIED


ADDA_IMM_SOURCE     CMP.B   #%111,D3
                    BNE     ADDA_SOURCE
                    CMP.B   #%000,D4
                    BEQ     ADDA_GET_VALUE
                    CMP.B   #%001,D4
                    BEQ     ADDA_GET_VALUE
                    CMP.B   #%100,D4
                    BEQ     ADDA_GET_VALUE
                    BRA     ADDA_DECODE_ERR

ADDA_GET_VALUE                                      *Now we need to figure out how much data to snag after, should we get a word or a long?
                    CMP.B   #%100,D4
                    BEQ     ADDA_POUND
                    CMP.B   #%000,D4
                    BEQ     ADDA_GETWORD
                    CMP.B   #%001,D4
                    BEQ     ADDA_GETLONG

ADDA_POUND
                    CMP.B   #%10,D0                 *The number need to be added is a literal
                    BEQ     ADDA_GETLONG
                    BRA     ADDA_GETWORD


ADDA_GETWORD
                    MOVE.W  (A1)+,D5                *D5 store the word data
                    BRA     ADDA_SOURCE


ADDA_GETLONG
                    MOVE.L  (A1)+,D5                *D5 store the long data
                    BRA     ADDA_SOURCE


VERIFIED_ADDA       RTS

ADDA_SOURCE
                    CMP.B   #%111,D2
                    BNE     VERIFIED_ADDA
                    CMP.B   #%10,D1
                    BEQ     ADDED_GETLONG
                    BRA     ADDED_GETWORD

ADDA_VERIFIED       BRA     ADDA_PRINT

ADDA_PRINT          LEA     ADDASTRING,A0
                    JSR     PRINT_SR
                    BRA     PRINT_ADDA_SIZE

PRINT_ADDA_SIZE     CMP.B   #%0,D0                  *Print size
                    BEQ     SIZEA_W
                    CMP.B   #%1,D0
                    BEQ     SIZEA_L
                    BRA     ADDA_DECODE_ERR


SIZEA_W             LEA     WORDSTRING,A0           *size is word
                    JSR     PRINT_SR
                    BRA     ADDA_P
SIZEA_L             LEA     LONGSTRING,A0           *size is long
                    JSR     PRINT_SR
                    BRA     ADDA_P


ADDA_P              JSR     SHIFTCURSOR             *Done displaying size, now display source
                    CMP.B   #%000,D3
                    BEQ     ADDA_000
                    CMP.B   #%001,D3
                    BEQ     ADDA_001
                    CMP.B   #%010,D3
                    BEQ     ADDA_010
                    CMP.B   #%011,D3
                    BEQ     ADDA_011
                    CMP.B   #%111,D3
                    BEQ     ADDA_111
                    CMP.B   #%100,D3
                    BEQ     ADDA_100

                    BRA     ADDA_DEST_PRT

ADDA_000                                            *Source is data register
                    LEA     DSTRING,A0
                    JSR     PRINT_SR
                    MOVE.L  D4,D7
                    JSR     PRINT_HEX
                    BRA     ADDA_DEST_PRT
ADDA_001                                            *Source is address register
                    LEA     ASTRING,A0
                    JSR     PRINT_SR
                    MOVE.L  D4,D7
                    JSR     PRINT_HEX
                    BRA     ADDA_DEST_PRT
ADDA_010                                            *Address register indirect
                    LEA     LPARENSTRING,A0
                    JSR     PRINT_SR
                    LEA     ASTRING,A0
                    JSR     PRINT_SR
                    MOVE.L  D4,D7
                    JSR     PRINT_HEX
                    LEA     RPARENSTRING,A0
                    JSR     PRINT_SR
                    BRA     ADDA_DEST_PRT
ADDA_011                                            *Address register indirect postincrement
                    LEA     LPARENSTRING,A0
                    JSR     PRINT_SR
                    LEA     ASTRING,A0
                    JSR     PRINT_SR
                    MOVE.L  D4,D7
                    JSR     PRINT_HEX
                    LEA     RPARENSTRING,A0
                    JSR     PRINT_SR
                    LEA     PLUSSTRING,A0
                    JSR     PRINT_SR
                    BRA     ADDA_DEST_PRT
ADDA_111                                            *Immediate source, could be immediate data or word/long address
                    CMP.B   #%000,D4
                    BEQ     ADDA_111000
                    CMP.B   #%001,D4
                    BEQ     ADDA_111001
                    CMP.B   #%100,D4
                    BEQ     ADDA_111100
ADDA_111000                                         *Is word address
                    LEA     DOLLARSTRING,A0
                    CLR.L   D7
                    MOVE.W  D5,D7
                    JSR     PRINT_HEX
                    BRA     ADDA_DEST_PRT
ADDA_111001                                         *Is long address
                    LEA     DOLLARSTRING,A0
                    JSR     PRINT_SR
                    CLR.L   D7
                    MOVE.L  D5,D7
                    JSR     PRINT_HEX
                    BRA     ADDA_DEST_PRT
ADDA_111100                                         *Is immediate data
                    LEA     POUNDSTRING,A0
                    JSR     PRINT_SR
                    LEA     DOLLARSTRING,A0
                    JSR     PRINT_SR
                    CLR.L   D7
                    CMP.B   #%0,D0
                    BEQ     ADDA_111100W
                    CMP.B   #%1,D0
                    BEQ     ADDA_111100L
ADDA_111100W        MOVE.W  D5,D7
                    BRA     ADDA_111100CONT
ADDA_111100L        MOVE.L  D5,D7
                    BRA     ADDA_111100CONT
ADDA_111100CONT
                    JSR     PRINT_HEX
                    BRA     ADDA_DEST_PRT
ADDA_100                                            *Source is address with predecrement
                    LEA     MINUSSTRING,A0
                    JSR     PRINT_SR
                    LEA     LPARENSTRING,A0
                    JSR     PRINT_SR
                    LEA     ASTRING,A0
                    JSR     PRINT_SR
                    MOVE.L  D4,D7
                    JSR     PRINT_HEX
                    LEA     RPARENSTRING,A0
                    JSR     PRINT_SR
                    BRA     ADDA_DEST_PRT

ADDA_DEST_PRT                                       *Now print the destination

                    LEA     COMMASTRING,A0
                    JSR     PRINT_SR                *Destination is just address register
                    LEA     ASTRING,A0
                    JSR     PRINT_SR
                    MOVE.L  D2,D7
                    JSR     PRINT_HEX
                    BRA     ADDA_DECODE_DONE


ADDA_DECODE_ERR     JSR     PRINTLINE_SR
                    RTS


ADDA_DECODE_DONE    LEA     LINEEND,A0
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
