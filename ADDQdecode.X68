                                                            *Decode ADD instruction
                                                            *D0 will be size
                                                            *D2 holds data
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
                        
                        
                        MOVE.B      (A1),D2                 *D2 holds data
                        ANDI.B      #%00001110,D2
                        LSR.B       #1,D2
                        
                        CMP.B       #%000,D2                
                        


                        MOVE.W      (A1),D3
                        ANDI.W      #%0000000000111000,D3   *we only care about the three bits
                        LSR.B       #3,D3

                        MOVE.B      (A1)+,D7
                        MOVE.B      (A1)+,D4                *register
                        ANDI.B      #%00000111,D4           *We only care about the last beat
                        
                        

                        CLR         D7

ADDQ_VALIDITY                                               * Lets check the data first

                        CMP.B       #%000,D2                *THE DATA BITS IN ADDQ ARE ONLY 3 BITS
                        BEQ         IT_IS_EIGHT             *THE IMMEDIATE VALUE 000 REPRESENTS EITHT 
                        CMP.B       #1,D2                   *CHECK THE SIZE, THE SIZE SHOUDLD BE
                        BLT         ADDQ_DECODE_ERR         *BETWEEN 1 AND 8, ITS ERROR OTHERWISE
                        CMP.B       #8,D2
                        BGT         ADDQ_DECODE_ERR
                        BRA         ADDQ_DATA_VALID

IT_IS_EIGHT                 
                        ADDQ.B      #8,D2                  *ADD EIGHT IN THE DATA REGISTER
                        BRA         ADDQ_DATA_VALID
                        

ADDQ_DATA_VALID                                             *THE DATA IS GOOD LETS CHECK THE SIZE
                        
                        CMP.B       #%00,D0
                        BEQ         ADDQ_SIZE_VALID         
                        CMP.B       #%01,D0
                        BEQ         ADDQ_SIZE_VALID
                        CMP.B       #%10,D0
                        BEQ         ADDQ_SIZE_VALID
                        BRA         ADDQ_DECODE_ERR         * if the bits are 11, its invalid
                                  

ADDQ_SIZE_VALID                                             *THE SIZE IS GOOD LETS CHECK THE MODE
             
                        CMP.B       #%000,D3
                        BEQ         ADDQ_MODE_VALID
                        CMP.B       #%001,D3
                        BEQ         CHECKQ_SIZE
                        CMP.B       #%010,D3
                        BEQ         ADDQ_MODE_VALID
                        CMP.B       #%011,D3
                        BEQ         ADDQ_MODE_VALID
                        CMP.B       #%100,D3
                        BEQ         ADDQ_MODE_VALID
                        CMP.B       #%111,D3
                        BEQ         CHECKQ_REGISTER         *Check for register
                        BNE         ADDQ_MODE_VALID
                        
                        
CHECKQ_SIZE             
                        CMP.B       #%00,D0                 *IF THE SIZE IS BYTE, THE DESTINATION CANT BE AR
                        BEQ         ADDQ_DECODE_ERR
                        BRA         ADDQ_MODE_VALID       
                        
CHECKQ_REGISTER                                             *At this point the mode is 111, 
                                                            *need to check if it is immediate
                        CMP.B       #%000,D4
                        BEQ         ADDQ_MODE_VALID
                        CMP.B       #%001,D4
                        BEQ         ADDQ_MODE_VALID
                        BRA         ADDQ_DECODE_ERR           *If reach here, there is a problem
                        
                        
ADDQ_MODE_VALID                                              
                        BRA         ADDQ_PRINT                         
                        

                        
                        
ADDQ_PRINT              LEA         ADDQSTRING,A0
                        JSR         PRINT_SR
                        BRA         PRINT_ADDQ_SIZE

PRINT_ADDQ_SIZE                                                 *PRINT SIZE
                        CMP.B       #%00,D0
                        BEQ         SIZE_ADDQ_B     
                        CMP.B       #%01,D0
                        BEQ         SIZE_ADDQ_W
                        CMP.B       #%10,D0
                        BEQ         SIZE_ADDQ_L         
                       
SIZE_ADDQ_B   
                        LEA         BYTESTRING,A0               *size is byte
                        JSR         PRINT_SR
                        JSR         SHIFTCURSOR
                        BRA         PRINT_Q_VALUE               *BRANCH TO IMMEDIATE PRINT
                        
  
SIZE_ADDQ_W  
                        LEA         WORDSTRING,A0               *size is WORD
                        JSR         PRINT_SR
                        JSR         SHIFTCURSOR
                        BRA         PRINT_Q_VALUE               *BRANCH TO IMMEDIATE PRINT
                        
SIZE_ADDQ_L  

                        LEA         LONGSTRING,A0               *size is LONG
                        JSR         PRINT_SR
                        JSR         SHIFTCURSOR
                        BRA         PRINT_Q_VALUE               *BRANCH TO IMMEDIATE PRINT
                        

PRINT_Q_VALUE                                                   *THIS PRINTS THE Quick VALUE between (1 and 8, inclusively)
                        
                        LEA         POUNDSTRING,A0
                        JSR         PRINT_SR
                        CLR.L       D7
                        MOVE        D2,D7
                        JSR         PRINT_HEX
                        BRA         ADDQ_DEST_PRT
                        

ADDQ_DEST_PRT                                                   *now prints the destination
                        CMP.B       #%000,D3                    
                        BEQ         ADDQ_000                    *destination is data register
                        CMP.B       #%001,D3
                        BEQ         ADDQ_001                    *destination is address register direct
                        CMP.B       #%010,D3
                        BEQ         ADDQ_010                    *destination is address register indirect
                        CMP.B       #%011,D3
                        BEQ         ADDQ_011                    *destination is address register post increment
                        CMP.B       #%100,D3
                        BEQ         ADDQ_100                    *destination is adrress register pre -decrement
                        CMP.B       #%111,D3
                        BEQ         ADDQ_111                    *destination is absolute value
                        
                        
                        
ADDQ_000                                                        *Destination is data register
                        LEA         COMMASTRING,A0
                        JSR         PRINT_SR
                        LEA         DSTRING,A0
                        JSR         PRINT_SR
                        MOVE.L      D4,D7
                        JSR         PRINT_HEX
                        BRA         ADDQ_DECODE_DONE
                        
ADDQ_001                                                        *Destination is address register indirect
                        LEA         COMMASTRING,A0
                        JSR         PRINT_SR
                        LEA         ASTRING,A0
                        JSR         PRINT_SR
                        MOVE.L      D4,D7
                        JSR         PRINT_HEX
                        BRA         ADDQ_DECODE_DONE
                        
               
ADDQ_010                                                        *Destination is address register indirect
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
                        BRA         ADDQ_DECODE_DONE
                        
                        
ADDQ_011                                                         *Address register indirect postincrement
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
                        BRA         ADDQ_DECODE_DONE
                        
ADDQ_100                                                        *Destination pre_decrement
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
                        BRA         ADDQ_DECODE_DONE

ADDQ_111                                                        *Destination absolute value
                        LEA         COMMASTRING,A0
                        JSR         PRINT_SR
                        CMP.B       #%000,D4
                        BEQ         ADDQ_111000
                        CMP.B       #%001,D4
                        BEQ         ADDQ_111001
                        
ADDQ_111000            
                        
                        LEA         DOLLARSTRING,A0             *IS WORD
                        JSR         PRINT_SR
                        CLR         D7
                        MOVE.W      (A1),D7
                        JSR         PRINT_HEX
                        BRA         ADDQ_DECODE_DONE
                        

ADDQ_111001            
                                                                *Is long address
                        LEA         DOLLARSTRING,A0
                        JSR         PRINT_SR
                        CLR.L       D7
                        MOVE.L      (A1),D7
                        JSR         PRINT_HEX
                        BRA         ADDQ_DECODE_DONE
                 
                        
                                         

ADDQ_DECODE_ERR         JSR         PRINTLINE_SR               *Something went wrong
                        RTS
                        
                        
ADDQ_DECODE_DONE        LEA         LINEEND,A0
                        JSR         PRINT_SR
                        RTS     
                        
                        
   





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
