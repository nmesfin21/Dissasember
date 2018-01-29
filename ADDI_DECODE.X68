                                                            *Decode ADD instruction
                                                            *D0 will be size
                                                            *D3 will be mode
                                                            *D4 will be register
                                                            *D5 is immediate/source address
                                                           
                        CLR.L       D0
                        CLR.L       D1
                        CLR.L       D2
                        CLR.L       D3
                        CLR.L       D4
                        CLR.L       D5
                        CLR.L       D6
                        CLR.L       D7
                        LEA         LINESTARTLOC,A1

                                                            *store the size on D0
                        MOVE.B      (A1)+,D7
                        MOVE.B      (A1),D0
                        LSR.B       #6,D0
                        ANDI.B      #%00000011,D0           *we have the size on D0
                        MOVE.B      -(A1),D7                *bring th pointer back
                        


                        MOVE.W      (A1),D3
                        ANDI.W      #%0000000000111000,D3   *we only care about the three bits
                        LSR.B       #3,D3

                        MOVE.B      (A1)+,D7
                        MOVE.B      (A1)+,D4                *register
                        ANDI.B      #%00000111,D4           *We only care about the last beat
                        
                        

                        CLR         D7

ADDI_VALIDITY                                                 * Lets check the mode
                        CMP.B       #%000,D3
                        BEQ         ADDI_MODE_VALID
                        CMP.B       #%010,D3
                        BEQ         ADDI_MODE_VALID
                        CMP.B       #%011,D3
                        BEQ         ADDI_MODE_VALID
                        CMP.B       #%100,D3
                        BEQ         ADDI_MODE_VALID
                        CMP.B       #%111,D3
                        BEQ         CHECK_REGISTER            *Check for register
                        BNE         ADDI_MODE_VALID
                        
CHECK_REGISTER                                                *At this point the mode is 111, 
                                                              *need to check if it is immediate
                        CMP.B       #%000,D4
                        BEQ         ADDI_MODE_VALID
                        CMP.B       #%001,D4
                        BEQ         ADDI_MODE_VALID
                        BRA         ADDI_DECODE_ERR           *If reach here, there is a problem
                        
                        
ADDI_MODE_VALID                                               *lets check the size
                        CMP.B       #%00,D0                 
                        BEQ         CHECK_B_VALUE 
                        CMP.B       #%01,D0                 
                        BEQ         CHECK_W_VALUE 
                        CMP.B       #%10,D0                 
                        BEQ         CHECK_L_VALUE 
                        BRA         ADDI_DECODE_ERR
                        
CHECK_B_VALUE                                                   *Lets check he byte value
                                                                *If the value is greater than 255,
                                                                *it will send error value
                        MOVE.W      (A1),D7
                        CMPI.W      #255,D7
                        BHI         ADDI_DECODE_ERR
                        CMPI.W      #0,D7
                        BLO         ADDI_DECODE_ERR
                        BRA         ADDI_SIZE_VALID
                        

CHECK_W_VALUE 
                                                                *Lets check he byte value
                                                                *If the value is greater than 65535,
                                                                *it will send error value
                        MOVE.W      (A1),D7
                        CMPI.W      #65535,D7
                        BHI         ADDI_DECODE_ERR
                        CMPI.W      #0,D7
                        BLO         ADDI_DECODE_ERR
                        BRA         ADDI_SIZE_VALID
                        CLR         D7
                        

CHECK_L_VALUE                                                   *Lets check he byte value
                                                                *If the value is greater than 65535,
                                                                *it will send error value
                        MOVE.L      (A1),D7
                        CMPI.L      #4294967295,D7
                        BHI         ADDI_DECODE_ERR
                        CMPI.L      #0,D7
                        BLO         ADDI_DECODE_ERR
                        BRA         ADDI_SIZE_VALID
                        CLR         D7
                        
                        
                        
ADDI_SIZE_VALID                                                 *IF WE GET HERE, WE EVERYTHING IS FINE
                                                                *this is where we figure out how much we add
                        CMP.B       #%00,D0
                        BEQ         ADDI_BYTE
                        CMP.B       #%01,D0
                        BEQ         ADDI_WORD
                        CMP.B       #%10,D0
                        BEQ         ADDI_LONG
                        CLR         D7
                        
                        
ADDI_BYTE                       
                        MOVE.B      (A1)+,D7                    *Skip to the needed byte
                        MOVE.B      (A1)+,D5                    *D5 store the byte data
                        BRA         ADDI_PRINT
                                    

ADDI_WORD               
                        MOVE.W      (A1)+,D5                    *D5 Store the word data
                        BRA         ADDI_PRINT

ADDI_LONG
                        MOVE.L      (A1)+,D5                    *D5 Store the long data
                        BRA         ADDI_PRINT
                        
                        
ADDI_PRINT              LEA         ADDISTRING,A0
                        JSR         PRINT_SR
                        BRA         PRINT_ADDI_SIZE

PRINT_ADDI_SIZE                                                 *PRINT SIZE
                        CMP.B       #%00,D0
                        BEQ         SIZE_ADDI_B     
                        CMP.B       #%01,D0
                        BEQ         SIZE_ADDI_W
                        CMP.B       #%10,D0
                        BEQ         SIZE_ADDI_L         
                       
SIZE_ADDI_B   
                        LEA         BYTESTRING,A0               *size is byte
                        JSR         PRINT_SR
                        JSR         SHIFTCURSOR
                        BRA         PRINT_I_VALUE               *BRANCH TO IMMEDIATE PRINT
                        
  
SIZE_ADDI_W  
                        LEA         WORDSTRING,A0               *size is WORD
                        JSR         PRINT_SR
                        JSR         SHIFTCURSOR
                        BRA         PRINT_I_VALUE               *BRANCH TO IMMEDIATE PRINT
                        
SIZE_ADDI_L  

                        LEA         LONGSTRING,A0               *size is LONG
                        JSR         PRINT_SR
                        JSR         SHIFTCURSOR
                        BRA         PRINT_I_VALUE               *BRANCH TO IMMEDIATE PRINT
                        

PRINT_I_VALUE                                                   *THIS PRINTS THE IMMEDIATE VALUE
                        
                        LEA         POUNDSTRING,A0
                        JSR         PRINT_SR
                        LEA         DOLLARSTRING,A0
                        JSR         PRINT_SR
                        CLR.L       D7
                        CMP.B       #%00,D0
                        BEQ         BYTE_IMM
                        CMP.B       #%01,D0
                        BEQ         WORD_IMM
                        CMP.B       #%10,D0
                        BEQ         LONG_IMM
                        
BYTE_IMM                                                        *Prints the byte
                        

WORD_IMM                                                        *HANDLES WORD
                        MOVE.W      D5,D7                        
                        BRA         PRINT_IMM_CONT

LONG_IMM                MOVE.L      D5,D7                       *HANDLES LONG
                        BRA         PRINT_IMM_CONT
                        
PRINT_IMM_CONT          JSR         PRINT_HEX
                        BRA         ADDI_DEST_PRT       

ADDI_DEST_PRT                                                   *now prints the destination
                        CMP.B       #%000,D3
                        BEQ         ADDI_000
                        CMP.B       #%010,D3
                        BEQ         ADDI_010
                        CMP.B       #%011,D3
                        BEQ         ADDI_011
                        CMP.B       #%100,D3
                        BEQ         ADDI_100
                        CMP.B       #%111,D3
                        BEQ         ADDI_111
                        
                        
                        
ADDI_000                                                        *Destination is data register
                        LEA         COMMASTRING,A0
                        JSR         PRINT_SR
                        LEA         DSTRING,A0
                        JSR         PRINT_SR
                        MOVE.L      D4,D7
                        JSR         PRINT_HEX
                        BRA         ADDI_DECODE_DONE
               
ADDI_010                                                        *Destination is address register indirect
                        LEA         COMMASTRING,A0
                        JSR         PRINT_SR
                        LEA         LPARENSTRING,A0
                        JSR         PRINT_SR
                        LEA         ASTRING,A0
                        JSR         PRINT_SR
                        MOVE.L      D4,D7
                        JSR         PRINT_HEX
                        LEA         RPARENSTRING,A0
                        JSR         PRINT_SR
                        BRA         ADDI_DECODE_DONE
                        
                        
ADDI_011                                                         *Address register indirect postincrement
                        LEA         COMMASTRING,A0
                        JSR         PRINT_SR
                        LEA         LPARENSTRING,A0
                        JSR         PRINT_SR
                        LEA         ASTRING,A0
                        JSR         PRINT_SR
                        MOVE.L      D4,D7
                        JSR         PRINT_HEX
                        LEA         RPARENSTRING,A0
                        JSR         PRINT_SR
                        LEA         PLUSSTRING,A0
                        JSR         PRINT_SR
                        BRA         ADDI_DECODE_DONE
                        
ADDI_100                                                        *Destination pre_decrement
                        LEA         COMMASTRING,A0
                        JSR         PRINT_SR
                        LEA         MINUSSTRING,A0
                        JSR         PRINT_SR
                        LEA         LPARENSTRING,A0
                        JSR         PRINT_SR
                        LEA         ASTRING,A0
                        JSR         PRINT_SR
                        MOVE.L      D4,D7
                        JSR         PRINT_HEX
                        LEA         RPARENSTRING,A0
                        JSR         PRINT_SR
                        BRA         ADDI_DECODE_DONE

ADDI_111                                                        *Destination absolute value
                        LEA         COMMASTRING,A0
                        JSR         PRINT_SR
                        CMP.B       #%000,D4
                        BEQ         ADDI_111000
                        CMP.B       #%001,D4
                        BEQ         ADDI_111001
                        
ADDI_111000            
                        
                        LEA         DOLLARSTRING,A0             *IS WORD
                        JSR         PRINT_SR
                        CLR         D7
                        MOVE.W      (A1),D7
                        JSR         PRINT_HEX
                        BRA         ADDI_DECODE_DONE
                        

ADDI_111001            
                                                                *Is long address
                        LEA         DOLLARSTRING,A0
                        JSR         PRINT_SR
                        CLR.L       D7
                        MOVE.L      (A1),D7
                        JSR         PRINT_HEX
                        BRA         ADDA_DECODE_DONE
                 
                        
                                         

ADDI_DECODE_ERR         JSR         PRINTLINE_SR               *Something went wrong
                        RTS
                        
                        
ADDI_DECODE_DONE        LEA         LINEEND,A0
                        JSR         PRINT_SR
                        RTS     
                        
                        
   


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
