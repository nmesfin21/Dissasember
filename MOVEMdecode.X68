* decode a possible MOVEM instruction.
* Depending on which subroutine is jumped to, we know different things about valid EAs
* MOVEM has size Word and Long, so the corresponding subroutine jumps exist here.
*
* effective address constructed from:
* 3-bit mode, 3 bit register
* possible modes:
*   if the mode is 0, register to memory, then the mode cannot be postincrememt (011)
*   if the mode is 1, memory to register, then the mode cannot be predecrement (100)
*   the mode cannot be 000 or 001
* D0: remaining raw instruction bits to decode
* D1: number of bits left
* D2: size codes,       0:W     1:L
* D3: direction,        0:RtM   1:MtR
* D4: mode,             010: 2, addr indirect
*                       011: 3,  "     "     - with post-increment
*                       100: 4,  "     "     - with pre-decrement --> bitmask is reversed
*
* D5: register number,  000-111
* D6: register bitmask, interpreted either of two ways based on mode
*
*
* example decoding
*    MOVEM.L     D0-D7/A0-A6,-(SP)
*    4    8    E    7      F    F    F    E
*   0100 1000 1110 0111 | 1111 1111 1111 1110
*   0100 1000 11 | 100 | 111 | 1111 1111 1111 1110
*    op/dir/sze    mde   reg    bitmask in predec mode
*   mode:   predecrement
*   reg:    7 (A7 is the SP)
*   D0-D7/A0-A6
*    MOVEM.L     (SP)+,D0-D7/A0-A6
*    4    C    D    F      7    F    F    F
*   0100 1100 1101 1111 | 0111 1111 1111 1111
*   0100 1100 11 | 011 | 111 | 0111 1111 1111 1111
*    op/dir/sze    mde   reg    bitmask in postinc mode
*

* move word from register to memory
MOVEMWTM_SR             MOVE.L      #$0,D2              * set size code: word
                        MOVE.L      #$0,D3              * det direction: reg to mem
                        BRA         VALIDATEMOVEM

MOVEMLTM_SR                                             * move long from register to memory
                        MOVE.L      #$1,D2              * set size code: long
                        MOVE.L      #$0,D3              * det direction: reg to mem
                        BRA         VALIDATEMOVEM

MOVEMWTR_SR                                             * move word from memory to register
                        MOVE.L      #$0,D2              * set size code: word
                        MOVE.L      #$1,D3              * det direction: reg to mem
                        BRA         VALIDATEMOVEM

MOVEMLTR_SR                                             * move long from memory to register
                        MOVE.L      #$1,D2              * set size code: long
                        MOVE.L      #1,D3               * det direction: reg to mem
                        BRA         VALIDATEMOVEM

VALIDATEMOVEM           CMP.W       #23,D1              * there must be exactly 22 (+1 for the tree) bits remaining
                        BNE         MOVEM_INVALID       * if not, it's invalid

SPLITMOVEM              CLR.L       D3                  * for direction
                        CLR.L       D4                  * for mode
                        CLR.L       D5                  * for reg number
                        CLR.L       D6                  * reg bitmask
                        CLR.L       D7                  * for printing using PRINT_HEX

                        MOVE.L      D0,D4               * extract the mode to D4
                        LSR.L       #2,D4               * right justify 26 bits (16 for reg bitmask, 10 for tree)
                        LSR.L       #8,D4               * "
                        LSR.L       #8,D4               * "
                        LSR.L       #8,D4               * "
                        MOVE.L      D4,D5               * extract the register number to D5
                        ANDI.L      #$00000003,D5       * AND D5 with 00000003 for reg num (remove mode)
                        LSR.L       #3,D4               * right justify D4 an additional 3 bits (29 total)
                                                        * extract the register bitmask to D6
                        MOVE.L      D0,D6               * copy bits to D6
                        LSR.L       #8,D6               * right justify 10 bits
                        LSR.L       #2,D6               * "
                        ANDI.L      #$0000FFFF,D6       * AND with 0000FFFF for register bitmask

V_MOVEM_MODE            CMP.B       #2,D4               * skip to V_MOVEM_MODE_V if mode is valid (2,3, or 4 in D4)
                        BEQ         V_MOVEM_MODE_V      * "
                        CMP.B       #3,D4               * "
                        BEQ         V_MOVEM_MODE_V      * "
                        CMP.B       #4,D4               * "
                        BEQ         V_MOVEM_MODE_V      * "
                        BRA         MOVEM_INVALID       * otherwise treat this as an invalid instruction
V_MOVEM_MODE_V          NOP                             * if we have reached here, the instruction looks valid
                                                        * print the instruction
                        LEA         MOVEMSTRING,A0
                        JSR         PRINT_SR
                        JSR         SHIFTCURSOR         * standardized indentation level
                        MOVE.L      D5,D7
                        CMP.B       #2,D4               * detemine whether to print Addr Indirect or Addr with post-increment
                        BEQ         MOVEM_ADDR
                        CMP.B       #3,D4
                        BEQ         MOVEM_POSTINC
                        BRA         MOVEM_REGS          * skip print-addr
MOVEM_ADDR              JSR         PRINT_ADDR
                        BRA         MOVEM_REGS          * skip over post-inc
MOVEM_POSTINC           JSR         PRINT_POSTINC       * does not need a followup because MOVEM_REGS follows anyway
                        LEA         SPACESTRING,A0
                        JSR         PRINT_SR

MOVEM_REGS              CMP.B       #4,D4               * pre-decrement mode has a reversed bitmask
                        BEQ         MOVEM_REGS_REVERSE

MOVEM_REGS_INORDER                                      * Post-inc and normal mode bitmask order:
                                                        *   15   14   13   12   11   10    9    8    7    6    5    4    3    2    1    0
                                                        * | A7 | A6 | A5 | A4 | A3 | A2 | A1 | A0 | D7 | D6 | D5 | D4 | D3 | D2 | D1 | D0 |

                        CLR.L       D7                  * start reading bits from position 0
D_up_test_loop          BTST        D7,D6               * check if particular bit is set
                        BEQ         D_up_test_fail      * if not, skip printing this value
                        JSR         Print_Dnum          * if yes, print D#
D_up_test_fail          ADDI.B      #1,D7               * increment bit position
                        CMP.B       #8,D7               * have we hit position 8 (where A starts)
                        BEQ         D_up_test_done      * if yes, we are done
                        BRA         D_up_test_loop      * if not, loop
D_up_test_done          

                        JSR         MOVEM_DIVIDER       * print out " / " between D and A register segments


                        LSR.L       #8,D6               * shift to access the A registers in pos 0-8

                        CLR.B       D7                  * reset bit position to 0
A_up_test_loop          BTST        D7,D6               * check if particular bit is set
                        BEQ         A_up_test_fail      * if not, skip printing this value
                        JSR         Print_Anum          * print A#
A_up_test_fail          ADDI.B      #1,D7               * increment bit position
                        CMP.B       #8,D7               * have we hit bit 8? (outside A register bitmask)
                        BEQ         A_up_test_done      * if yes, we are done
                        BRA         A_up_test_loop      * if not, loop
A_up_test_done          CLR.B       D7                  * wipe D7
                        BRA         MOVEM_REGS_DONE


MOVEM_REGS_REVERSE                                      * Pre-decrement mode bitmask order (backwards):
                                                        *   15   14   13   12   11   10    9    8    7    6    5    4    3    2    1    0
                                                        * | D0 | D1 | D2 | D3 | D4 | D5 | D6 | D7 | A0 | A1 | A2 | A3 | A4 | A5 | A6 | A7 | 
                        MOVEM.L     D0-D5,-(SP)         * push stack for safety
                        MOVE.B      #15,D0              * D0 temporarily holds the bit position, counting down from 15
                        CLR.L       D7                  * D7 holds the value of the bit, counting from 0 to 7
                        
D_dn_test_loop          BTST        D0,D6               * check if particular bit is set
                        BEQ         D_dn_test_fail      * if not, skip printing this value
                        JSR         Print_Dnum
D_dn_test_fail          SUBI.B      #1,D0               * move position to next bit 
                        ADDI.B      #1,D7               * increase bit number
                        CMP.B       #7,D0               * have we hit bit number 7?
                        BEQ         D_dn_test_done
                        BRA         D_dn_test_loop
D_dn_test_done          

                        JSR         MOVEM_DIVIDER       * print out " / " between D and A register segments

                        MOVE.L      #0,D7               * restore bit number count-up back to 0
                                                        * position in D0 is still 7, from the D register loop
A_dn_test_loop          BTST        D0,D6               * check if particular bit is set
                        BEQ         A_dn_test_fail      * if not, skip printing this value
                        JSR         Print_Anum
A_dn_test_fail          SUBI.B      #1,D0               * move position to next bit 
                        ADDI.B      #1,D7               * increase bit number
                        CMP.B       #8,D7               * have we hit bit number 7?
                        BEQ         A_dn_test_done      * if so, break the loop
                        BRA         A_dn_test_loop
A_dn_test_done          

                        MOVEM.L     (SP)+,D0-D5         * pop stack

MOVEM_REGS_DONE                                         * either of the two register parsers returned
                        CMP.B       #4,D4               * check if this is pre-decrement mode
                        BNE         MOVEM_DONE          * if not, we're done
                        LEA         SPACESTRING,A0      * if yes, print "-(A#)"
                        JSR         PRINT_SR            *
                        MOVE.L      D5,D7               * put register number into D7 for use in PRINT_PREDEC
MOVEM_PREDEC            JSR         PRINT_PREDEC        *

MOVEM_DONE              LEA         LINEEND,A0          * print final newline
                        JSR         PRINT_SR            * "
                        RTS                             * MOVEM decoder has successfully completed

MOVEM_INVALID           BRA         PRINTLINE_SR        * the line was not a valid MOVEM instruction


* ----- TODO MOVE THESE OUT TO GENERAL PRINT TOOLS
MOVEM_DIVIDER           LEA         FWDSLASHSTRING,A0   * print out " / " between D and A register segments
                        JSR         PRINT_SR            * "
                        LEA         SPACESTRING,A0      * "
                        JSR         PRINT_SR            * "
                        RTS

Print_Dnum              LEA         DSTRING,A0          * prints "D<D7> "
                        BRA         Print_num
Print_Anum              LEA         ASTRING,A0          * prints "D<D7> "
Print_num               JSR         PRINT_SR
                        JSR         PRINT_HEX
                        LEA         SPACESTRING,A0
                        JSR         PRINT_SR
                        RTS

PRINT_ADDR              LEA         LPARENSTRING,A0     * prints "(A<D7>)"
                        JSR         PRINT_SR
                        LEA         ASTRING,A0
                        JSR         PRINT_SR
                        JSR         PRINT_HEX
                        LEA         RPARENSTRING,A0
                        JSR         PRINT_SR
                        LEA         SPACESTRING,A0
                        JSR         PRINT_SR
                        RTS

PRINT_POSTINC           LEA         LPARENSTRING,A0     * prints "(A<D7>)+"
                        JSR         PRINT_SR
                        LEA         ASTRING,A0
                        JSR         PRINT_SR
                        JSR         PRINT_HEX
                        LEA         RPARENSTRING,A0
                        JSR         PRINT_SR
                        LEA         PLUSSTRING,A0
                        JSR         PRINT_SR
                        RTS

PRINT_PREDEC            LEA         MINUSSTRING,A0      * prints "-(A<D7>)"
                        JSR         PRINT_SR
                        LEA         LPARENSTRING,A0
                        JSR         PRINT_SR
                        LEA         ASTRING,A0
                        JSR         PRINT_SR
                        JSR         PRINT_HEX
                        LEA         RPARENSTRING,A0
                        JSR         PRINT_SR
                        RTS
