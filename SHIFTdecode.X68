*LSDR stands for Register logical shift in the direction of D, D is either L or R 
*Decode LSR, LSL instruction
*D0 will be size
*D1 will Rotation, Count/Register
*D2 will be direction
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

                                                    *check if it it is a regiter shift or memory shift
                    MOVE.W  (A1),D0
                    LSR.W   #6,D0
                    ANDI.B  #%00000011,D0


                    MOVE.B  (A1),D1                 *Rotation Data register/ count
                    ANDI.B  #%00001110,D1           *We only need the three bits
                    LSR.B   #1,D1
                    


                    MOVE.B  (A1),D2                 *Direction, determines if the logical shift is to right or left
                    ANDI.B  #%00000001,D2           *0 is right shift and 1 is left shift
                                                    *we only need the last bit


                    MOVE.W  (A1),D3
                    ANDI.W  #%0000000000100000,D3   *we only care about the 1 bits
                    LSR.B   #5,D3                   *determines if the bit rotation is register or immediate
                                                    *if 0, the rotation is immediate data,else register
                    MOVE.W  (A1),D6
                    LSR.W   #3,D6
                    ANDI.B  #%00000011,D6           * this determines if it is ASd, LSd or ROd

                    MOVE.B  (A1)+,D7
                    MOVE.B  (A1)+,D4                *register
                    ANDI.B  #%00000111,D4           *We only care about the last beat (D0 - D7)
                    
                  

                    CLR     D7
                    
DETERMINE_SHIFT                                     *here we will determine what kind of shift it is
                                                    *it is either memory shift or register shift
                    CMP.B   #%11,D0
                    BEQ     MEMORY_SHIFT            *Its memory shift
                    BRA     REGISTER_SHIFT          *Its register shift
                    
REGISTER_SHIFT                                      *At this point,we know the shift is register shift
                                                    *let's check the register shift, it is either LSd, ASd or ROd
                    CMP.B   #%00,D6
                    BEQ     ASREG_DECODE            *It's arthimetic register shift
                    CMP.B   #%01,D6
                    BEQ     LSREG_DECODE            *It is logical register shift
                    CMP.B   #%11,D6
                    BEQ     ROREG_DECODE            *It is register rotate
                    CLR     D6
                    BRA     SHIFT_DECODE_ERR
                    

MEMORY_SHIFT                                        *At this point we know it is a memory shift
                                                    *let check whether it is ASd, LSd or ROd
                    CLR     D3
                    LEA     (A0),A1
                    MOVE.W  (A1)+,D3
                    ANDI.W  #%0000000000111000,D3   *we only care about the 3 bits
                    LSR.B   #3,D3  
                    BRA     VALIDATE_MEMS_MODE       *branch to check the mode

VALIDATE_MEMS_MODE                                   *Lets check the mode
                    CMP.B   #%010,D3
                    BEQ     MEMS_MODE_VALID         * It is (An)
                    CMP.B   #%011,D3
                    BEQ     MEMS_MODE_VALID         * It is (An)+
                    CMP.B   #%100,D3
                    BEQ     MEMS_MODE_VALID         * It is -(An)
                    CMP.B   #%111,D3
                    BEQ     CHECK_MEMS_REG          * check if it is (xxx).w or (xxx).L
                    BRA     SHIFT_DECODE_ERR        *ERROR
                    
CHECK_MEMS_REG                                      * Lets check the register, if it is not 000 or 001, it error
                    CMP.B   #%000,D4
                    BEQ     MEMS_MODE_VALID         * the absolute value is (xxx).w
                    CMP.B   #%001,D4
                    BEQ     MEMS_MODE_VALID         * the absolute value is (xxx).l
                    BRA     SHIFT_DECODE_ERR        *ERROR 

MEMS_MODE_VALID                                     * If we got here the everything is fine, lets check what
                                                    * the instruction is                                 
                    CMP.B   #%000,D1
                    BEQ     ASMEM_DECODE            *It's arthimetic memory shift
                    CMP.B   #%001,D1
                    BEQ     LSMEM_DECODE            *It's logical memory shift
                    CMP.B   #%011,D1    
                    BEQ     ROMEM_DECODE            *It's memory rotation
                    BRA     SHIFT_DECODE_ERR        *error
                    
ASMEM_DECODE        INCLUDE "ASDMdecode.X68"        *reads the file ASDMdecode.x68

LSMEM_DECODE        INCLUDE "LSDMdecode.X68"        *reads the file LSDMdec0de.x68

ROMEM_DECODE        INCLUDE "RODMdecode.X68"        *reads the file RODMdecode.x68

LSREG_DECODE        INCLUDE "LSDRdecode.X68"        *reads the file LSRMdecode.x68

ASREG_DECODE        INCLUDE "ASDRdecode.X68"        *reads the file ASDRdecode.x68

ROREG_DECODE        INCLUDE "RODRdecode.X68"        *reads the file RODRdecode.x68

SHIFT_DECODE_ERR    JSR     PRINTLINE_SR
                    RTS
SHIFT_DECODE_DONE                                     * we done
                    LEA     LINEEND,A0
                    JSR     PRINT_SR
                    RTS   







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
