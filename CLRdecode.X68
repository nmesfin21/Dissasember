* decode a possible CLR instruction. 
* Depending on which subroutine is jumped to, we know different things about valid EAs
* CLR can operate on data with Byte, Word, or Long lengths.

* effective address constructed from:
* 3 mode bits, which may contain any combination EXCEPT 001 or 111
* 3 register bits, which 

* D0 contains the remaining bits to decode, left over from the tree
* D2 is set to the size code; 0:B, 1,W, 2:L
* D3 is the mode
* D4 is the register number


CLRB_SR         MOVE.L  #$0,D2                  * set size code: Byte
                BRA     VALIDATECLR

CLRW_SR         MOVE.L  #$1,D2                  * set size code: Word
                BRA     VALIDATECLR

CLRL_SR         MOVE.L  #$2,D2                  * set size code: Long
                BRA     VALIDATECLR

VALIDATECLR     SUB.B   #1,D1                   * if there are no bits left, there is no way to be valid.
                BEQ     CLR_INVALID

                LEA     LINESTARTLOC,A1         * load up the first 4 bytes
                MOVE.W  (A1),D0

                CLR.L   D3                      * put copies of the remaining bits into D3 and D4 for mode and register respectively
                CLR.L   D4
                MOVE.W  D0,D3                   * mode copy
                LSR.L   #3,D3                   * shift into the right nibble and toss out reg bits
                ANDI.B  #%00000111,D3           * toss out earlier bits
                MOVE.W  D0,D4                   * reg copy
                ANDI.B  #%00000111,D4           * toss out earlier bits

                * check if mode is either 001 or 111
                CMP.B   #%0001,D3                * 001 is an invalid mode
                BEQ     CLR_INVALID
                CMP.B   #%111,D3               * 111 is special indirect addressing mode
                BEQ     CLR_ADDR_Ind
                                                * it's not 001 or 111, so we can assume it's one of the valid types.
                CMP.B   #%000,D0
                BEQ     CLR_Dn
                CMP.B   #%010,D0
                BEQ     CLR_An
                CMP.B   #%011,D0
                BEQ     CLR_An_PostInc
                CMP.B   #%100,D0
                BEQ     CLR_An_PreDec





CLR_Dn

CLR_An

CLR_An_PostInc

CLR_An_PreDec



CLR_ADDR_Ind    * cannot have size code 0 for byte


CLR_INVALID     BRA     PRINTLINE_SR

CLR_SR_DONE   RTS