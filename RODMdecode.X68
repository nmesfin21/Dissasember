*RSDM stands for Memory rotation in the direction of D, D is either L or R 
*Decode LSR, LSL instruction
*D0 will be size
*D1 will Rotation, Count/Register
*D2 will be direction
*D3 will be mode
*D4 will be register
*D5 is immediate/source address
*D6 is dest address




RSDM_DATAREG_VALID                                  * LET'S THE DIRECTION NOW
                    CMP.B   #%0,D2
                    BEQ     RSDM_DIRECTION_VALID    * rotate to right
                    CMP.B   #%1,D2
                    BEQ     RSDM_DIRECTION_VALID    * rotate to left
                    BRA     RSDM_DECODE_ERR         * we will never get here

RSDM_DIRECTION_VALID                                * check the rotation mode
                                                    * Branch to the printer      
                    BRA     RSDM_DECODE_PRINT       



RSDM_DECODE_PRINT                                   * Check if it is left or right
                    CMP     #%0,D2
                    BEQ     RSRM_SR                 * right rotaion, M stands for memory
                    BRA     RSLM_SR                 * left Rotation
                    
                    
RSLM_SR                                             * take care of the printing of LSR
                    LEA     ROLSTRING,A0
                    JSR     PRINT_SR                * prints RSL
                    BRA     PRINT_RSDM_SIZE         * branch to LSD SIZE

RSRM_SR                                             * take care of the printing of LSR
                    LEA     RORSTRING,A0
                    JSR     PRINT_SR                * prints RSR
                    BRA     PRINT_RSDM_SIZE         * branch to RSD SIZE

PRINT_RSDM_SIZE                                      * branches to the appropriate print area
                                                     * prints .W, In this case its only word
                    LEA     WORDSTRING,A0
                    JSR     PRINT_SR
                    JSR      SHIFTCURSOR
                    BRA     PRINT_REMAINM            * USES THE PRINTER IN LSDM_DECODER

                    
                    
RSDM_DECODE_ERR     JSR     PRINTLINE_SR
                    RTS
RSDM_DECODE_DONE                                     * we done
                    LEA     LINEEND,A0
                    JSR     PRINT_SR
                    RTS                   
  






                  








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
