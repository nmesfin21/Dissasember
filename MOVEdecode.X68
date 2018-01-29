*Decode a move instruction
*D0 will be size
*D1 will be destreg
*D2 will be destmode
*D3 will be source mode
*D4 will be sourcereg
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

                                        *first get size
                MOVE.B  (A1),D0
                LSR.B   #4,D0
                ANDI.B  #%00000011,D0

                                        *dest reg
                MOVE.B  (A1),D1
                LSR.B   #1,D1
                ANDI.B  #%00000111,D1

                                        *dest mode, first bit is at end of first byte :c
                MOVE.B  (A1)+,D7
                ANDI.B  #%00000001,D7
                LSL.B   #2,D7

                MOVE.B  (A1),D2
                LSR.B   #6,D2           *Just want first two bits
                OR.B    D7,D2           *Add in that first bit
                CLR.L   D7

                                        *source mode
                MOVE.B  (A1),D3
                LSR.B   #3,D3
                ANDI.B  #%00000111,D3

                                        *source reg
                MOVE.B  (A1)+,D4
                ANDI.B  #%00000111,D4


MOVEVALIDITY                            *First, is dest mode valid?
                CMP.B   #%000,D2
                BEQ     MOVEDESTMVALID
                CMP.B   #%010,D2
                BEQ     MOVEDESTMVALID
                CMP.B   #%011,D2
                BEQ     MOVEDESTMVALID
                CMP.B   #%100,D2
                BEQ     MOVEDESTMVALID
                CMP.B   #%111,D2
                BEQ     MOVEDESTMVALID
                CMP.B   #%001,D2
                BEQ     MOVEDESTMVALID
                BRA     MOVEDECODE_ERR

MOVEDESTMVALID                          *Is dest register valid? Should be 0-7, or 0-6 if move
                CMP.B   #%001,D2
                BEQ     MOVEDRCANBEADD
                CMP.B   #%010,D2
                BEQ     MOVEDRCANBEADD
                CMP.B   #%011,D2
                BEQ     MOVEDRCANBEADD
                CMP.B   #%100,D2
                BEQ     MOVEDRCANBEADD
                BRA     MOVEDESTRVALID

MOVEDRCANBEADD  CMP.B   #%111,D1        *If dest register can be an address, it can't be 7
                BEQ     MOVEDECODE_ERR
                BRA     MOVEDESTRVALID

MOVEDESTRVALID                          *Is source mode valid?
                CMP.B   #%000,D3
                BEQ     MOVESOURCEMV
                CMP.B   #%010,D3
                BEQ     MOVESOURCEMV
                CMP.B   #%001,D3
                BEQ     MOVESOURCEMV
                CMP.B   #%010,D3
                BEQ     MOVESOURCEMV
                CMP.B   #%011,D3
                BEQ     MOVESOURCEMV
                CMP.B   #%100,D3
                BEQ     MOVESOURCEMV
                CMP.B   #%111,D3
                BEQ     MOVESOURCEMV
                BRA     MOVEDECODE_ERR

MOVESOURCEMV                            *Is source register valid?
                CMP.B   #%001,D3
                BEQ     MOVESRCANBEADD
                CMP.B   #%010,D3
                BEQ     MOVESRCANBEADD
                CMP.B   #%011,D3
                BEQ     MOVESRCANBEADD
                CMP.B   #%100,D3
                BEQ     MOVESRCANBEADD
                BRA     MOVEIMMSOURCE


MOVESRCANBEADD  CMP.B   #%111,D4        *If source register can be an address, it can't be 7
                BEQ     MOVEDECODE_ERR
                BRA     MOVEIMMSOURCE

MOVEIMMSOURCE                           *First check if our register is valid (could be (xxx).W, (xxx).L, or #<data>)
                CMP.B   #%111,D3
                BNE     MOVEDEST
                CMP.B   #%000,D4
                BEQ     MOVEIMMVR
                CMP.B   #%001,D4
                BEQ     MOVEIMMVR
                CMP.B   #%100,D4
                BEQ     MOVEIMMVR
                BRA     MOVEDECODE_ERR
MOVEIMMVR                               *Now we need to figure out how much data to snag after, should we get a word or a long?
                CMP.B   #%100,D4
                BEQ     MOVESPOUND
                CMP.B   #%000,D4
                BEQ     MOVESGETWORD
                CMP.B   #%001,D4
                BEQ     MOVESGETLONG
MOVESPOUND                              *The source is a literal, how long is determined by size
                CMP.B   #%10,D0
                BEQ     MOVESGETLONG
                BRA     MOVESGETWORD
MOVESGETWORD                            *Get a word!
                MOVE.W  (A1)+,D5
                BRA     MOVEDEST
MOVESGETLONG                            *Get a long!
                MOVE.L  (A1)+,D5
                BRA     MOVEDEST

MOVEDEST        CMP.B   #%111,D2
                BNE     MOVEVERIFIED
                CMP.B   #%10,D1
                BEQ     MOVEDGETLONG
                BRA     MOVEDGETWORD

MOVEDGETWORD    MOVE.W  (A1)+,D6
                BRA     MOVECHECKLENGTH
MOVEDGETLONG    MOVE.L  (A1)+,D6
                BRA     MOVECHECKLENGTH

MOVECHECKLENGTH MOVEM.L D0-D7,-(SP)
                MOVE.L  A1,D0
                MOVE.L  LINESTARTLOC,D1
                SUB.L   D1,D0           *D0 now has the length of the instruction in bytes
                MULU    #8,D0           *Now D0 has the number of bits
                ANDI.L  #$000000FF,D0
                MOVE.B  (LINELENGTH),D2 *D2 has line length in bits
                CMP.B   D0,D2
                BNE     MOVEDECODE_ERR
                MOVEM.L (SP)+,D0-D7
                BRA     MOVEVERIFIED


MOVEVERIFIED    BRA     MOVEDECODE_PRNT

                                        *If any data can't be verified or is invalid, throw error
MOVEDECODE_ERR  JSR     PRINTLINE_SR
                BRA     MOVEDECODE_DONE


                                        *print add

                                        *After all of the data is separated and verified, we start printing
MOVEDECODE_PRNT CMP.B   #%001,D2
                BEQ     ISMOVEA
                LEA     MOVESTRING,A0
                JSR     PRINT_SR
                BRA     MOVEAFP
ISMOVEA         LEA     MOVEASTRING,A0
                JSR     PRINT_SR
MOVEAFP         CMP.B   #%01,D0
                BEQ     MOVEB
                CMP.B   #%11,D0
                BEQ     MOVEW
                CMP.B   #%10,D0
                BEQ     MOVEL

MOVEB           LEA     BYTESTRING,A0
                JSR     PRINT_SR
                BRA     MOVEAS
MOVEW           LEA     WORDSTRING,A0
                JSR     PRINT_SR
                BRA     MOVEAS
MOVEL           LEA     LONGSTRING,A0
                JSR     PRINT_SR
                BRA     MOVEAS
MOVEAS                                  *Done displaying size, now display source
                JSR     SHIFTCURSOR
                CMP.B   #%000,D3
                BEQ     MOVES000
                CMP.B   #%001,D3
                BEQ     MOVES001
                CMP.B   #%010,D3
                BEQ     MOVES010
                CMP.B   #%011,D3
                BEQ     MOVES011
                CMP.B   #%111,D3
                BEQ     MOVES111
                CMP.B   #%100,D3
                BEQ     MOVES100

                BRA     MOVEPRNTDEST

MOVES000                                *Source is data register
                LEA     DSTRING,A0
                JSR     PRINT_SR
                MOVE.L  D4,D7
                JSR     PRINT_HEX
                BRA     MOVEPRNTDEST
MOVES001                                *Source is address register
                LEA     ASTRING,A0
                JSR     PRINT_SR
                MOVE.L  D4,D7
                JSR     PRINT_HEX
                BRA     MOVEPRNTDEST
MOVES010                                *Address register indirect
                LEA     LPARENSTRING,A0
                JSR     PRINT_SR
                LEA     ASTRING,A0
                JSR     PRINT_SR
                MOVE.L  D4,D7
                JSR     PRINT_HEX
                LEA     RPARENSTRING,A0
                JSR     PRINT_SR
                BRA     MOVEPRNTDEST
MOVES011                                *Address register indirect postincrement
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
                BRA     MOVEPRNTDEST
MOVES111                                *Immediate source, could be immediate data or word/long address
                CMP.B   #%000,D4
                BEQ     MOVES111000
                CMP.B   #%001,D4
                BEQ     MOVES111001
                CMP.B   #%100,D4
                BEQ     MOVES111100
MOVES111000                             *Is word address
                LEA     DOLLARSTRING,A0
                JSR     PRINT_SR
                CLR.L   D7
                MOVE.W  D5,D7
                JSR     PRINT_HEX
                BRA     MOVEPRNTDEST
MOVES111001                             *Is long address
                LEA     DOLLARSTRING,A0
                JSR     PRINT_SR
                CLR.L   D7
                MOVE.L  D5,D7
                JSR     PRINT_HEX
                BRA     MOVEPRNTDEST
MOVES111100                             *Is immediate data
                LEA     POUNDSTRING,A0
                JSR     PRINT_SR
                LEA     DOLLARSTRING,A0
                JSR     PRINT_SR
                CLR.L   D7
                CMP.B   #%01,D0
                BEQ     MOVES111100B
                CMP.B   #%11,D0
                BEQ     MOVES111100W
                CMP.B   #%10,D0
                BEQ     MOVES111100L
MOVES111100B    MOVE.B  D5,D7
                BRA     MOVES111100CONT
MOVES111100W    MOVE.W  D5,D7
                BRA     MOVES111100CONT
MOVES111100L    MOVE.L  D5,D7
                BRA     MOVES111100CONT
MOVES111100CONT
                JSR     PRINT_HEX
                BRA     MOVEPRNTDEST
MOVES100                                *Source is address with predecrement
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
                BRA     MOVEPRNTDEST

MOVEPRNTDEST                            *Now print the destination
                LEA     COMMASTRING,A0
                JSR     PRINT_SR
                CMP.B   #%000,D2
                BEQ     MOVED000
                CMP.B   #%001,D2
                BEQ     MOVED001
                CMP.B   #%010,D2
                BEQ     MOVED010
                CMP.B   #%011,D2
                BEQ     MOVED011
                CMP.B   #%100,D2
                BEQ     MOVED100
                CMP.B   #%111,D2
                BEQ     MOVED111

MOVED000                                *Destination mode is just data register
                LEA     DSTRING,A0
                JSR     PRINT_SR
                MOVE.L  D1,D7
                JSR     PRINT_HEX
                BRA     MOVEDECODE_DONE

MOVED001                                *Destination is just address register
                LEA     ASTRING,A0
                JSR     PRINT_SR
                MOVE.L  D1,D7
                JSR     PRINT_HEX
                BRA     MOVEDECODE_DONE
MOVED010                                *Destination is address indirect
                LEA     LPARENSTRING,A0
                JSR     PRINT_SR
                LEA     ASTRING,A0
                JSR     PRINT_SR
                MOVE.L  D1,D7
                JSR     PRINT_HEX
                LEA     RPARENSTRING,A0
                JSR     PRINT_SR
                BRA     MOVEDECODE_DONE
MOVED011                                *Destination is address indirect postincrement
                LEA     LPARENSTRING,A0
                JSR     PRINT_SR
                LEA     ASTRING,A0
                JSR     PRINT_SR
                JSR     PRINT_SR
                MOVE.L  D1,D7
                LEA     RPARENSTRING,A0
                JSR     PRINT_SR
                LEA     PLUSSTRING,A0
                JSR     PRINT_SR
                BRA     MOVEDECODE_DONE
MOVED100                                *Destination is address indirect predecrement
                LEA     MINUSSTRING,A0
                JSR     PRINT_SR
                LEA     LPARENSTRING,A0
                JSR     PRINT_SR
                LEA     ASTRING,A0
                JSR     PRINT_SR
                MOVE.L  D1,D7
                JSR     PRINT_HEX
                LEA     RPARENSTRING,A0
                JSR     PRINT_SR
                BRA     MOVEDECODE_DONE

MOVED111                                *Destination is word or long address
                LEA     DOLLARSTRING,A0
                JSR     PRINT_SR
                CLR.L   D7
                CMP.B   #%000,D1
                BEQ     MOVED111W
                CMP.B   #%001,D1
                BEQ     MOVED111L

MOVED111W       MOVE.W  D6,D7
                BRA     MOVEDCONT
MOVED111L       MOVE.L  D6,D7
                BRA     MOVEDCONT
MOVEDCONT       JSR     PRINT_HEX
                BRA     MOVEDECODE_DONE

MOVEDECODE_DONE LEA     LINEEND,A0
                JSR     PRINT_SR
                RTS


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
