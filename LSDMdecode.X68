*LSDM stands for Memory logical shift in the direction of D, D is either L or R 
*Decode LSR, LSL instruction
*D0 will be size
*D1 will Rotation, Count/Register
*D2 will be direction
*D3 will be mode
*D4 will be register
*D5 is immediate/source address
*D6 is dest address




LSDM_DATAREG_VALID                                  * LET'S THE DIRECTION NOW
                    CMP.B   #%0,D2
                    BEQ     LSDM_DIRECTION_VALID    * Shift to right
                    CMP.B   #%1,D2
                    BEQ     LSDM_DIRECTION_VALID    * Shift to left
                    BRA     LSDM_DECODE_ERR         * we will never get here

LSDM_DIRECTION_VALID                                * check the rotation mode
                                                    * Branch to the printer      
                    BRA     LSDM_DECODE_PRINT       



LSDM_DECODE_PRINT                                   * Check if it is left or right
                    CMP     #%0,D2
                    BEQ     LSRM_SR                 * right shift, M stands for memory
                    BRA     LSLM_SR                  * left shift
                    
                    
LSLM_SR                                              * take care of the printing of LSR
                    LEA     LSLSTRING,A0
                    JSR     PRINT_SR                * prints LSR
                    BRA     PRINT_LSDM_SIZE          * branch to LSD SIZE

LSRM_SR                                             * take care of the printing of LSR
                    LEA     LSRSTRING,A0
                    JSR     PRINT_SR                * prints LSR
                    BRA     PRINT_LSDM_SIZE         * branch to LSD SIZE

PRINT_LSDM_SIZE                                      * branches to the appropriate print area
                                                     * prints .W, In this case its only word
                   
                    LEA     WORDSTRING,A0
                    JSR     PRINT_SR
                    JSR     SHIFTCURSOR
                    BRA     PRINT_REMAINM   

                    
                    
PRINT_REMAINM       
                    JSR     SHIFTCURSOR             * prints the remaining parts
                    CMP.B   #%010,D3
                    BEQ     PRINT_M010              * branch to pring (An)
                    CMP.B   #%011,D3
                    BEQ     PRINT_M011              * Branch to print (An)+
                    CMP.B   #%100,D3
                    BEQ     PRINT_M100              * branch to pring -(An)
                    CMP.B   #%111,D3                
                    BEQ     ADD_ABSOLUTE            * branch to ADD either (xxx).w or (xxx).l
                    BRA     LSDM_DECODE_ERR         * ERROR  

ADD_ABSOLUTE                                         * Check how much it needs
                    CMP.B   #%000,D4
                    BEQ     ADD_ABS_WORD            * (xxx).w
                    CMP.B   #%001,D4
                    BEQ     ADD_ABS_LONG            * (xxx).l
                    BRA     LSDM_DECODE_ERR         *ERROR
  
ADD_ABS_WORD
                    MOVE.W  (A1)+,D5                * D5 Store the word value
                    BRA     PRINT_M111
ADD_ABS_LONG
                    MOVE.L  (A1)+,D5                * D5 Store the word value
                    BRA     PRINT_M111          
                     
  
PRINT_M010                                          * Prints (An), (n is from A0 - A7
                    LEA     LPARENSTRING,A0
                    JSR     PRINT_SR                * Prints "("
                    LEA     ASTRING,A0
                    JSR     PRINT_SR                * Prints A
                    MOVE.L  D4,D7    
                    JSR     PRINT_HEX               * Prints hex from 0 to 7 
                    LEA     RPARENSTRING,A0
                    JSR     PRINT_SR                * Prints ")"
                    BRA     LSDM_DECODE_DONE     
                    
PRINT_M011                                          * Prints (An)+, (n is from A0 - A7
                    LEA     LPARENSTRING,A0
                    JSR     PRINT_SR                * Prints "("
                    LEA     ASTRING,A0
                    JSR     PRINT_SR                * Prints A
                    MOVE.L  D4,D7    
                    JSR     PRINT_HEX               * Prints hex from 0 to 7 
                    LEA     RPARENSTRING,A0
                    JSR     PRINT_SR                * Prints ")"
                    LEA     PLUSSTRING,A0              
                    JSR     PRINT_SR                * Prints "+"
                    BRA     LSDM_DECODE_DONE  

PRINT_M100                                          * Prints -(An), (n is from A0 - A7)
                    LEA     MINUSSTRING,A0
                    JSR     PRINT_SR                * Prints "-"
                    LEA     LPARENSTRING,A0
                    JSR     PRINT_SR                * Prints "("
                    LEA     ASTRING,A0
                    JSR     PRINT_SR                * Prints A
                    MOVE.L  D4,D7    
                    JSR     PRINT_HEX               * Prints hex from 0 to 7 
                    LEA     RPARENSTRING,A0
                    JSR     PRINT_SR                * Prints ")"
                    BRA     LSDM_DECODE_DONE        
                    
PRINT_M111                                          * lets print the absolute value
                    LEA     DOLLARSTRING,A0
                    JSR     PRINT_SR                * Print that Dollllar
                    MOVE.L  D5,D7
                    JSR     PRINT_HEX
                    BRA     LSDM_DECODE_DONE        
                                              
                     
LSDM_DECODE_ERR     JSR     PRINTLINE_SR
                    RTS
LSDM_DECODE_DONE                                     * we done
                    LEA     LINEEND,A0
                    JSR     PRINT_SR
                    RTS                   
  






                  







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
