*RODR stands for Register rotation in the direction of D, D is either L or R 
*Decode LSR, LSL instruction
*D0 will be size
*D1 will Rotation, Count/Register
*D2 will be direction
*D3 will rotation mode, either 0 or 1
*D4 will be register
*D5 is immediate/source address
*D6 is dest address

RODRVALIDITY                                        * Lets check the data register/count first
                    CMP.B   #%000,D1
                    BEQ     RODR_DATAREG_VALID      * can be D0 or immediate 000
                    CMP.B   #%001,D1
                    BEQ     RODR_DATAREG_VALID      * can be D1 or immediate 001  
                    CMP.B   #%010,D1
                    BEQ     RODR_DATAREG_VALID      * can be D2 or immediate 010
                    CMP.B   #%011,D1
                    BEQ     RODR_DATAREG_VALID      * can be D3 or immediate 011
                    CMP.B   #%100,D1
                    BEQ     RODR_DATAREG_VALID      * can be D4 or immediate 100
                    CMP.B   #%101,D1
                    BEQ     RODR_DATAREG_VALID      * can be D5 or immediate 101
                    CMP.B   #%110,D1
                    BEQ     RODR_DATAREG_VALID      * can be D6 or immediate 110
                    CMP.B   #%111,D1
                    BEQ     RODR_DATAREG_VALID      * can be D7 or immediate 111
                    BRA     RODR_DECODE_ERR


RODR_DATAREG_VALID                                  * LET'S THE DIRECTION NOW
                    CMP.B   #%0,D2
                    BEQ     RODR_DIRECTION_VALID    * rotate to right
                    CMP.B   #%1,D2
                    BEQ     RODR_DIRECTION_VALID    * rotate to left
                    BRA     RODR_DECODE_ERR         * we will never get here

RODR_DIRECTION_VALID                                * check the rotation mode
                    CMP.B   #%0,D3
                    BEQ     RODR_MODE_VALIDATE      * contains shift count, immediate
                    CMP.B   #%1,D3
                    BEQ     RODR_MODE_VALIDATE      * contains the data register specified, (D0 - D7)
                    BRA     RODR_DECODE_ERR         * we will never get here->Dn)



RODR_MODE_VALIDATE                                  * Branch to the printer      
                    BRA     RODR_DECODE_PRINT       



RODR_DECODE_PRINT                                   * Check if it is left or right
                    CMP     #%0,D2
                    BEQ     ROR_SR                  * right rotation
                    BRA     ROL_SR                  * left rotation
                    
                    
ROL_SR                                              * take care of the printing of LSR
                    LEA     ROLSTRING,A0
                    JSR     PRINT_SR                * prints LSR
                    BRA     PRINT_LSD_SIZE          * branch to LSD SIZE

ROR_SR                                              * take care of the printing of LSR
                    LEA     RORSTRING,A0
                    JSR     PRINT_SR                * prints LSR
                    BRA     PRINT_LSD_SIZE          * branch to LSD SIZE

RODR_DECODE_ERR     JSR     PRINTLINE_SR
                    RTS
RODR_DECODE_DONE                                     * we done
                    LEA     LINEEND,A0
                    JSR     PRINT_SR
                    RTS                   
  






                  




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
