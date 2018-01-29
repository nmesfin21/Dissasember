*Decode LEA instruction
*D2 holds address register
*D3 will be mode
*D4 will be register
*D5 is immediate/source address
*D6 is holds a bit that indicates if JSR or JMP is the instruction
                    CLR.L   D0
                    CLR.L   D1
                    CLR.L   D2
                    CLR.L   D3
                    CLR.L   D4
                    CLR.L   D5
                    CLR.L   D6
                    CLR.L   D7
                    LEA     LINESTARTLOC,A1


                    MOVE.W  (A1),D1                 *check if it islea
                    ANDI.W  #%0000000110000000,D1   *we need only the two bits in the middle
                    LSR.W   #7,D1
                    
                    MOVE.B  (A1),D2                 *address register
                    ANDI.B  #%00001110,D2           *We only need the address register
                    LSR.B   #1,D2

                

                    MOVE.W  (A1),D3                 *mode
                    ANDI.W  #%0000000000111000,D3   *we only care about the three bits
                    LSR.B   #3,D3

                    MOVE.B  (A1)+,D7                *we use it to check for CLR
                    ANDI.B  #%00000001,D7           *we need only the last digit
                    
                    MOVE.B  (A1),D6                 *D6 holds the bit that determine whether its JSR or JMP
                    ANDI.B  #%01000000,D6
                    LSR.B   #6,D6                   *shift the byte
                            
                    MOVE.B  (A1)+,D4                *register
                    ANDI.B  #%00000111,D4           *We only care about the last bit
                    
              
                    CMP.B   #%01,D1                 *if the bits at D1 are 01 it could be JSR or JMP
                    BEQ     CHECK_FOR_JSR           *branch to see if it is a JSR
                    BRA     CHECK_FOR_CLR           *it could be CLR
                    
CHECK_FOR_CLR                                       *it could be clear
                    CMP.B   #%1,D7
                    BEQ     LEA_MODE                *Its load
                    BRA     COULD_BECLR             *It could be CLR 

COULD_BECLR                                         *Check if it is CLR
                    CMP.B   #%001,D2                *check the address register
                    BEQ     CLR_SR                  *its CLR
                    BRA     LEA_DECODE_ERR          *otherwise its error          
                    
                    
                    
CHECK_FOR_JSR                                       *check if its JSR
                    CMP.B   #%111,D2
                    BEQ     CHECK_FOR_ERR           *check if it it is JMP
                    BRA     LEA_DECODE_ERR
                    

CHECK_FOR_ERR   
                    CMP.B   #%1,D6                  *If this bit is 1, its jmp, not required for this assignment
                    BEQ     LEA_DECODE_ERR          *its ERROR
                    BRA     JSR_SR                  *its jSR
                    
                    CLR     D6
                    CLR     D7



LEA_MODE                                            *here we will determine the mode
                                                    *the only effective addresses are (An), (xxx).w and (xxx).l
                                                    
                   CMP.B    #%010,D3
                   BEQ      LEA_MODE_VALID          *the mode is valid
                   CMP.B    #%111,D3        
                   BEQ      LEA_VALIDATE_REG        *validate the register, 
                   BRA      LEA_DECODE_ERR          *its error other wise
                   
LEA_VALIDATE_REG                                    *this will the absolute value type
                                                    *if its not (xxx).w or (xxx).l,erro
                   CMP.B    #%000,D4
                   BEQ      LEA_MODE_VALID          *(xxx).w valid
                   CMP.B    #%001,D4
                   BEQ      LEA_MODE_VALID          *(xxx).l valid
                   BRA      LEA_DECODE_ERR          *ERROR


LEA_MODE_VALID                                      *at this point, everything is good, lets print
                   BRA      LEA_PRINT
                   
LEA_PRINT                                           *takes care of the print
                   CMP.B    #%010,D3
                   BEQ      LEA010_PRINT            *branch to print An
                   CMP.B    #%111,D3
                   BEQ      LEA_GET_ABSOLUTE        *branch to print (xxx).w or (xxx).l
                   BRA      LEA_DECODE_ERR
                   
LEA_GET_ABSOLUTE                                    *tells us how much we need to snag
                   CMP.B     #%000,D4
                   MOVE.W    (A1),D5                *snag word
                   CMP.B     #%001,D4
                   MOVE.L    (A1),D5                *snag long
                   BRA       LEA111_PRINT           *jump to print
                   
LEA010_PRINT       
                   LEA      LEASTRING,A0
                   JSR      PRINT_SR                *prints LEA
                   JSR      SHIFTCURSOR
                   LEA      LPARENSTRING,A0
                   JSR      PRINT_SR                *print (
                   LEA      ASTRING,A0
                   JSR      PRINT_SR                *print A
                   MOVE.L   D4,D7
                   JSR      PRINT_HEX               *prints(0 - 7)
                   LEA      RPARENSTRING,A0
                   JSR      PRINT_SR                *prints )
                   BRA      PRINT_LEA_RMN
                   
LEA111_PRINT       
                                                          
                   LEA      LEASTRING,A0
                   JSR      PRINT_SR                *prints LEA 
                   JSR      SHIFTCURSOR
                   LEA      DOLLARSTRING,A0
                   JSR      PRINT_SR
                   MOVE.L   D5,D7   
                   JSR      PRINT_HEX               *print the absolute value
                   BRA      PRINT_LEA_RMN           *branch to print the rest
    
PRINT_LEA_RMN      
                    CLR     D7                                *print the destination
                    LEA     COMMASTRING,A0
                    JSR     PRINT_SR                *prints comma
                    LEA     ASTRING,A0
                    JSR     PRINT_SR                *prinst A
                    MOVE.L  D2,D7
                    JSR     PRINT_HEX               *prinst (0 - 7)
                    BRA     LEA_DECODE_DONE
                    

LEA_DECODE_ERR      JSR     PRINTLINE_SR
                    RTS
LEA_DECODE_DONE                                     * we done
                    LEA     LINEEND,A0
                    JSR     PRINT_SR
                    RTS                                                      















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
