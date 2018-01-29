*ASDM stands for Memory arthimetical shift in the direction of D, D is either L or R 
*Decode LSR, LSL instruction
*D0 will be size
*D1 will Rotation, Count/Register
*D2 will be direction
*D3 will be mode
*D4 will be register
*D5 is immediate/source address
*D6 is dest address




ASDM_DATAREG_VALID                                  * LET'S THE DIRECTION NOW
                    CMP.B   #%0,D2
                    BEQ     ASDM_DIRECTION_VALID    * Shift to right
                    CMP.B   #%1,D2
                    BEQ     ASDM_DIRECTION_VALID    * Shift to left
                    BRA     ASDM_DECODE_ERR         * we will never get here

ASDM_DIRECTION_VALID                                * check the rotation mode
                                                    * Branch to the printer      
                    BRA     ASDM_DECODE_PRINT       



ASDM_DECODE_PRINT                                   * Check if it is left or right
                    CMP     #%0,D2
                    BEQ     ASRM_SR                 * right shift, M stands for memory
                    BRA     ASLM_SR                 * left shift
                    
                    
ASLM_SR                                             * take care of the printing of LSR
                    LEA     ASLSTRING,A0
                    JSR     PRINT_SR                * prints LSR
                    BRA     PRINT_ASDM_SIZE         * branch to LSD SIZE

ASRM_SR                                             * take care of the printing of LSR
                    LEA     ASRSTRING,A0
                    JSR     PRINT_SR                * prints LSR
                    BRA     PRINT_ASDM_SIZE         * branch to LSD SIZE

PRINT_ASDM_SIZE                                      * branches to the appropriate print area
                                                     * prints .W, In this case its only word
                    LEA     WORDSTRING,A0
                    JSR     PRINT_SR
                    BRA     PRINT_REMAINM            * USES THE PRINTER IN LSDM_DECODER

                    
                    
ASDM_DECODE_ERR     JSR     PRINTLINE_SR
                    RTS
ASDM_DECODE_DONE                                     * we done
                    LEA     LINEEND,A0
                    JSR     PRINT_SR
                    RTS                   
  






                  





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
