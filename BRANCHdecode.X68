*this is a branch stuff
*Decode LSR, LSL instruction
*D2 holds the bit that determines whether it is negative or positive
*D3 holds the condition code, determine which condition code is
*D4 holds the Displacement
*D5 will be used to print the next printer
*D6 holds a 16 bit displacement if D4 holds $00 or 32 bit displacement if D4 holds $FF

                    CLR.L   D0
                    CLR.L   D1
                    CLR.L   D2
                    CLR.L   D3
                    CLR.L   D4
                    CLR.L   D5
                    CLR.L   D6
                    CLR.L   D7
                    LEA     LINESTARTLOC,A1


                    MOVE.B  (A1),D3
                    ANDI.B  #%00001111,D3           *we only care about last 4 bits
                                                    *determines the conditionality
                                                    
                    
                    MOVE.B  (A1)+,D7
                    MOVE.B  (A1)+,D4                *holds the 8-bit displacement
                    
                    MOVE.B  D4,D2               
                    ANDI.B  #%10000000,D2           *we only cares a bout the fit determine if
                                                    *it's negative or positve

 
                    
DETERMINE_CONDITION                                 *here we will determine condition
                                                    *for this assignment, it has to be either BCC(0100),BGT(1110) or BLE(1111) 
                                                    *to be valid, invalid otherwise
                    CMP.B   #%00000100,D3
                    BEQ     CONDITION_VALID         *its BCC
                    CMP.B   #%00001110,D3
                    BEQ     CONDITION_VALID         *its BGT
                    CMP.B   #%00001111,D3
                    BEQ     CONDITION_VALID         *Its BLE
                    BRA     BRANCH_DECODE_ERR       *If we get here, its ERROR
                    
CONDITION_VALID                                     *If we get here, the condition is valid
                                                    *lets check the 8bit displacement
                                                    *if its $00, the displacement is in the next 16 bit
                                                    *if its $FF, the displacement is in the next 32 bit
                    CMP.B   #$00,D4
                    BEQ     IT_WORD_DIS             *the displacement stored in the next 16 bits field
                    CMP.B   #$FF,D4
                    BEQ     IT_LONG_DIS             *the displacement stored in the next 32 bits field
                    BRA     IT_BYTE_DIS             *the displacement stored in the 8-bit field
                            
IT_BYTE_DIS                                         *the displacement is stored in the 8-bit field
                                                    *compare the bit at D2 to figure out whether 
                                                    *we need to add or substract the displacement 
                                                    *from the PC, if 0 we add, subtract otherwise
                    MOVE.B  D4,D6
                    CMP.B   #%0,D2
                    BEQ     PC_ADD                  *add the displacement on the PC
                    BRA     PC_SUB                  *otherwise,subtract the displacement from the PC
                    

                    
IT_WORD_DIS                                         *the displacement is stored in the 16 -bit field
                                                    *compare the bit at D2 to figure out whether 
                                                    *we need to add or substract the displacement 
                                                    *from the PC, if 0 we add, subtract otherwise
                    MOVE.W  (A1),D6                 
                    CMP.B   #%0,D2                  *MOVE word field
                    BEQ     PC_ADD
                    BRA     PC_SUB

             
IT_LONG_DIS                                         *the displacement is stored in the 16 -bit field
                                                    *compare the bit at D2 to figure out whether 
                                                    *we need to add or substract the displacement 
                                                    *from the PC, if 0 we add, subtract otherwise
                    MOVE.L  (A1),D6                 
                    CMP.B   #%0,D2                  *MOVE long field
                    BEQ     PC_ADD                  *the next PC is greater than the current PC
                    BRA     PC_SUB                  *the next PC is less than the current pc
 

PC_ADD                                              *Add the displacement on PC
                    MOVE.L  (CURRENTMEM),D5
                    ADD.L   D6,D5                   *add and store in D5 
                    BRA     BRANCH_VERIFIED
PC_SUB                                              *Sub the displacement from pc
                    MOVE.L  (CURRENTMEM),D5
                    SUB.L   D6,D5                   *sub and store in D5
                    BRA     BRANCH_VERIFIED 




BRANCH_VERIFIED                                     *at this point, everything is good
                    BRA     BRANCH_PRINT            *branch to print for Branch Stuff
                    

BRANCH_PRINT                                        *Lets print
                    CMP.B   #%00000100,D3
                    BEQ     PRINT_BCC               *branch to print BCC
                    CMP.B   #%00001110,D3
                    BEQ     PRINT_BGT               *branch to print BGT
                    CMP.B   #%00001111,D3
                    BEQ     PRINT_BLE               *branch to print BLE
                    BRA     BRANCH_DECODE_ERR       *ERROR
                    
PRINT_BCC                                           *prints BCC
                                   
                    LEA     BCCSTRING,A0
                    JSR     PRINT_SR                *prints bcc
                    JSR     SHIFTCURSOR
                    LEA     DOLLARSTRING,A0
                    JSR     PRINT_SR                *prints $
                    MOVE.L  D5,D7
                    JSR     PRINT_HEX               *Prints the next instruction address
                    BRA     BRANCH_DECODE_DONE
                    
                                      
                            

PRINT_BGT
                    LEA     BGTSTRING,A0
                    JSR     PRINT_SR                *prints BGT
                    JSR     SHIFTCURSOR
                    LEA     DOLLARSTRING,A0
                    JSR     PRINT_SR                *prints $
                    MOVE.L  D5,D7
                    JSR     PRINT_HEX               *Prints the new address
                    BRA     BRANCH_DECODE_DONE
                    

PRINT_BLE
                    LEA     BLESTRING,A0
                    JSR     PRINT_SR                *prints BLE
                    JSR     SHIFTCURSOR
                    LEA     DOLLARSTRING,A0
                    JSR     PRINT_SR                *prints $
                    MOVE.L  D5,D7
                    JSR     PRINT_HEX               *Prints the next instruction addresss
                    BRA     BRANCH_DECODE_DONE
                    
 

BRANCH_DECODE_ERR   JSR     PRINTLINE_SR
                    RTS
BRANCH_DECODE_DONE                                     * we done
                    LEA     LINEEND,A0
                    JSR     PRINT_SR
                    RTS   













*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
