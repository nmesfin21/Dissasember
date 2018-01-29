*JSR implentation
*D2 will indicator for LEA, if the bit the two bit are 01 its SR or if it is 11 is LEA
*D3 will rotation mode, either 0 or 1
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



                    MOVE.W  (A1),D3
                    ANDI.W  #%0000000000111000,D3   *we only care about the three bits
                    LSR.B   #3,D3                   *holds the mode

                    MOVE.B  (A1)+,D7
                    MOVE.B  (A1)+,D4                *register
                    ANDI.B  #%00000111,D4           *We only care about the last beat (D0 - D7)
                    
                  

                    CLR     D7
                    
DETERMINE_MODE                                      *here we will determine the mode
                                                    *the only effective addresses are (An), (xxx).w and (xxx).l
                                                    
                   CMP.B    #%010,D3
                   BEQ      JSR_MODE_VALID          *the mode is valid
                   CMP.B    #%111,D3        
                   BEQ      JSR_VALIDATE_REG        *validate the register, 
                   BRA      JSR_DECODE_ERR          *its error other wise
                   
JSR_VALIDATE_REG                                    *this will the absolute value type
                                                    *if its not (xxx).w or (xxx).l,erro
                   CMP.B    #%000,D4
                   BEQ      JSR_MODE_VALID          *(xxx).w valid
                   CMP.B    #%001,D4
                   BEQ      JSR_MODE_VALID          *(xxx).l valid
                   BRA      JSR_DECODE_ERR          *ERROR
                   
JSR_MODE_VALID                                      *at this point, everything is good, lets print
                   BRA      JSR_PRINT
                   
JSR_PRINT                                           *takes care of the print
                   CMP.B    #%010,D3
                   BEQ      JSR010_PRINT            *branch to print An
                   CMP.B    #%111,D3
                   BEQ      JSR_GET_ABSOLUTE        *branch to print (xxx).w or (xxx).l
                   BRA      JSR_DECODE_ERR
                   
JSR_GET_ABSOLUTE                                    *tells us how much we need to snag
                   CMP.B     #%000,D4
                   MOVE.W    (A1),D5                *snag word
                   CMP.B     #%001,D4
                   MOVE.L    (A1),D5                *snag long
                   BRA       JSR111_PRINT           *jump to print
                   
JSR010_PRINT      
                    
                   LEA      JSRSTRING,A0
                   JSR      PRINT_SR                *prints JSR
                   JSR      SHIFTCURSOR
                   LEA      LPARENSTRING,A0
                   JSR      PRINT_SR                *print (
                   LEA      ASTRING,A0
                   JSR      PRINT_SR                *print A
                   MOVE.L   D4,D7
                   JSR      PRINT_HEX               *prints(0 - 7)
                   LEA      RPARENSTRING,A0
                   JSR      PRINT_SR                *prints )
                   BRA      JSR_DECODE_DONE
                   
JSR111_PRINT       
                                                          
                   LEA      JSRSTRING,A0
                   JSR      PRINT_SR                *prints JSR 
                   JSR      SHIFTCURSOR
                   LEA      DOLLARSTRING,A0
                   JSR      PRINT_SR
                   MOVE.L   D5,D7   
                   JSR      PRINT_HEX               *print the absolute value
                   BRA      JSR_DECODE_DONE

JSR_DECODE_ERR      JSR     PRINTLINE_SR
                    RTS
JSR_DECODE_DONE                                     * we done
                    LEA     LINEEND,A0
                    JSR     PRINT_SR
                    RTS                                                      









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
