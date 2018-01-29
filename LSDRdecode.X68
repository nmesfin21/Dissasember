*LSDR stands for Register logical shift in the direction of D, D is either L or R 
*Decode LSR, LSL instruction
*D0 will be size
*D1 will Rotation, Count/Register
*D2 will be direction
*D3 will rotation mode, either 0 or 1
*D4 will be register
*D5 is immediate/source address
*D6 is dest address

LSDRVALIDITY                                        * Lets check the data register/count first
                    CMP.B   #%000,D1
                    BEQ     LSDR_DATAREG_VALID      * can be D0 or immediate 000
                    CMP.B   #%001,D1
                    BEQ     LSDR_DATAREG_VALID      * can be D1 or immediate 001  
                    CMP.B   #%010,D1
                    BEQ     LSDR_DATAREG_VALID      * can be D2 or immediate 010
                    CMP.B   #%011,D1
                    BEQ     LSDR_DATAREG_VALID      * can be D3 or immediate 011
                    CMP.B   #%100,D1
                    BEQ     LSDR_DATAREG_VALID      * can be D4 or immediate 100
                    CMP.B   #%101,D1
                    BEQ     LSDR_DATAREG_VALID      * can be D5 or immediate 101
                    CMP.B   #%110,D1
                    BEQ     LSDR_DATAREG_VALID      * can be D6 or immediate 110
                    CMP.B   #%111,D1
                    BEQ     LSDR_DATAREG_VALID      * can be D7 or immediate 111
                    BRA     LSDR_DECODE_ERR


LSDR_DATAREG_VALID                                  * LET'S THE DIRECTION NOW
                    CMP.B   #%0,D2
                    BEQ     LSDR_DIRECTION_VALID    * Shift to right
                    CMP.B   #%1,D2
                    BEQ     LSDR_DIRECTION_VALID    * Shift to left
                    BRA     LSDR_DECODE_ERR         * we will never get here

LSDR_DIRECTION_VALID                                * check the rotation mode
                    CMP.B   #%0,D3
                    BEQ     LSDR_MODE_VALIDATE      * contains shift count, immediate
                    CMP.B   #%1,D3
                    BEQ     LSDR_MODE_VALIDATE      * contains the data register specified, (D0 - D7)
                    BRA     LSDR_DECODE_ERR         * we will never get here->Dn)



LSDR_MODE_VALIDATE                                  * Branch to the printer      
                    BRA     LSDR_DECODE_PRINT       



LSDR_DECODE_PRINT                                   * Check if it is left or right
                    CMP     #%0,D2
                    BEQ     LSR_SR                  * right shift
                    BRA     LSL_SR                  * left shift
                    
                    
LSL_SR                                              * take care of the printing of LSR
                    LEA     LSLSTRING,A0
                    JSR     PRINT_SR                * prints LSR
                    BRA     PRINT_LSD_SIZE          * branch to LSD SIZE

LSR_SR                                              * take care of the printing of LSR
                    LEA     LSRSTRING,A0
                    JSR     PRINT_SR                * prints LSR
                    BRA     PRINT_LSD_SIZE          * branch to LSD SIZE

PRINT_LSD_SIZE                                      * branches to the appropriate print area
                    CMP.B   #%00,D0
                    BEQ     LSDR_SIZE_BYTE           * branch to print byte
                    CMP.B   #%01,D0
                    BEQ     LSDR_SIZE_WORD           * branch to print word
                    CMP.B   #%10,D0
                    BEQ     LSDR_SIZE_LONG           * branch to print long 
                    
                    
LSDR_SIZE_BYTE                                       * prints .B
                    LEA     BYTESTRING,A0
                    JSR     PRINT_SR
                    JSR     SHIFTCURSOR
                    BRA     PRINT_REMAIN 
                    
LSDR_SIZE_WORD                                       * prints .W
                    LEA     WORDSTRING,A0
                    JSR     PRINT_SR
                    JSR     SHIFTCURSOR
                    BRA     PRINT_REMAIN   
                    
LSDR_SIZE_LONG                                       * prints .L
                    LEA     LONGSTRING,A0
                    JSR     PRINT_SR
                    JSR     SHIFTCURSOR
                    BRA     PRINT_REMAIN   
                    
                    
                    
PRINT_REMAIN                                        * prints the remaining parts
                    CMP.B   #%000,D3
                    BEQ     PRINT_SHIFTCOUNT        * print shift count
                    BRA     PRINT_DATAREG           * Print data register
                    
PRINT_SHIFTCOUNT        
                    LEA     POUNDSTRING,A0
                    JSR     PRINT_SR                * prints #
                    CMP.B   #%000,D1
                    BEQ     EIGHT
                    BRA     CONTINUE_PR
EIGHT               ADDQ.L  #8,D1
                    BRA     CONTINUE_PR
                    
CONTINUE_PR                    
                    MOVE.L  D1,D7
                    JSR     PRINT_HEX               * Prints the value in D1, from D1 - D7
                    LEA     COMMASTRING,A0          
                    JSR     PRINT_SR                * Prints ","
                    CLR     D7                      * clear D7 for next use
                    LEA     DSTRING,A0
                    JSR     PRINT_SR                * Prints D
                    MOVE.L  D4,D7
                    JSR     PRINT_HEX               * print the hex
                    BRA     LSDR_DECODE_DONE
                    
 
PRINT_DATAREG     
                    LEA     DSTRING,A0
                    JSR     PRINT_SR                * prints #
                    MOVE.L  D1,D7
                    JSR     PRINT_HEX               * Prints the value in D1, from D1 - D7
                    LEA     COMMASTRING,A0          
                    JSR     PRINT_SR                * Prints ","
                    CLR     D7                      * clear D7 for next use
                    LEA     DSTRING,A0
                    JSR     PRINT_SR                * Prints D
                    MOVE.L  D4,D7
                    JSR     PRINT_HEX               * print the hex
                    BRA     LSDR_DECODE_DONE
                     
LSDR_DECODE_ERR     JSR     PRINTLINE_SR
                    RTS
LSDR_DECODE_DONE                                     * we done
                    LEA     LINEEND,A0
                    JSR     PRINT_SR
                    RTS                   
  






                  





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
