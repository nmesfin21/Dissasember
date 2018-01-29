*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

CR                      EQU         $0D                     *carriage return
LF                      EQU         $0A                     *line feed

START                   ORG         $1000
WELCOMELBL              LEA         WECLOMEMSG,A1           *Load welcome message
                        MOVE.B      #14,D0                  *Set trap task to 14 (display message in A1)
                        TRAP        #15                     *Execute task to display message
                        JSR         WAIT4ENTER_SR           *Call WAIT4ENTER sub routine

                                                            *Clear screen
                        MOVE.W      #$00FF,D1
                        MOVE.B      #11,D0
                        TRAP        #15

PROMPT4MEM              LEA         MEMLOCMSG,A1            *Prompt user for memory location
                        MOVE.B      #14,D0                  *Set trap task to 14 (display message in A1)
                        TRAP        #15                     *Execute task to display message

WAIT4MEM                LEA         USERINPUT,A1
                        MOVE.B      #2,D0                   *Gets string input from user
                        TRAP        #15                     *String stored at A1 (null terminated), length stored in D1.W
                        CMP.W       #0,D1                   *Is length valid
                        BLE         INVALIDMEM              *Not long enough...
                        CMP.W       #6,D1
                        BGT         INVALIDMEM              *Too long...
                        JSR         INPUTTOHEX_SR           *Convert to hex
                        CMP.B       #1,D5
                        BEQ         INVALIDMEM              *Error in reading
                        CMP.L       #$FFF000,D4
                        BGT         INVALIDMEM
                        BRA         VALIDMEM                *Read just fine! :D

INVALIDMEM              LEA         MEMLOCERROR,A1          *invalid memory input
                        MOVE.B      #14,D0
                        TRAP        #15
                        BRA         WAIT4MEM

VALIDMEM                MOVE.L      D4,(STARTMEM)
                        MOVE.L      D4,(CURRENTMEM)
                        BRA         PROMPT4FILENUM

FILEDNE                 LEA         FILENOTFOUND,A1         *File not found :(
                        MOVE.B      #14,D0
                        TRAP        #15
                        BRA         PROMPT4FILENUM

PROMPT4FILENUM          LEA         FILENUMMSG,A1           *Asks for file number
                        MOVE.B      #14,D0
                        TRAP        #15

WAIT4NUM                LEA         USERINPUT,A1
                        MOVE.B      #2,D0                   *Gets string input from user
                        TRAP        #15                     *String stored at A1 (null terminated), length stored in D1.W
                        CMP.W       #0,D1                   *Is length valid
                        BLE         INVALIDNUM              *Not long enough...
                        CMP.W       #6,D1
                        BGT         INVALIDNUM              *Too long...
                                                            *Is it all numbers?
                        MOVE.L      A1,A2                   *Copy this so we can use A1 to increment
CHECKNEXTNUM            CMP.B       #0,(A1)
                        BEQ         DONECHECKINGNUM         *Hit end of string
                        CMP.B       #$30,(A1)
                        BLT         INVALIDNUM              *Not at least 30 ascii
                        CMP.B       #$39,(A1)+
                        BGT         INVALIDNUM              *Larger than 39
                        BRA         CHECKNEXTNUM

INVALIDNUM              LEA         FILENUMERROR,A1         *invalid memory input
                        MOVE.B      #14,D0
                        TRAP        #15
                        BRA         WAIT4NUM

DONECHECKINGNUM                                             *At this point we know that the string pointed to by A2 is our correct file input number
                        LEA         FILENAMENUMB,A1
NEXTCHAR                CMP.B       #0,(A2)
                        BEQ         NOCHARLEFT
                        MOVE.B      (A2)+,(A1)+
                        BRA         NEXTCHAR

NOCHARLEFT              MOVE.B      #$2E,(A1)+              * .
                        MOVE.B      #$54,(A1)+              * T
                        MOVE.B      #$58,(A1)+              * X
                        MOVE.B      #$54,(A1)+              * T
                        MOVE.B      #$0,(A1)+               * \0    *At this point, the string pointed to by FILENAME is now TEST<X>.TXT

READFILE                MOVE.L      #$0,D1                  *We get here after enter is pressed!

                        MOVE        #50,D0                  *Close open files
                        TRAP        #15

                        MOVEA.L     #$5000,A3               *This is where we'll move our data in the end
                        MOVE.B      #$0,(BUFFER)            *Clear buffer
                        MOVE.B      #$0,(EOFHIT)            *Haven't hit the end of the file yet

                        LEA         FILENAME,A1             *Load filename into A1
                        MOVE.B      #51,D0                  *Opens file
                        TRAP        #15
                        CMP.L       #$FFFFFFFF,D1
                        BEQ         FILEDNE
                        MOVE.L      D1,(FILEID)
                        CLR.B       (LINECOUNT)             *Sets number of lines printed to 0
                        CLR.B       (LINELENGTH)            *Clears line length to start with

READLINE                JSR         CLEARLINE_SR            *Clears the line to get it ready for readings
                        MOVE.L      (FILEID),D1
                        MOVE.B      #$0,D4                  *0 in D4 will represent storing to the first half of the byte
                        LEA         LINESTARTLOC,A4         *A4 will represent the address to store to

                        CMP.B       #0,(LINELENGTH)
                        BEQ         SKIPMEMINC              *If last line length is 0, skip memory incrementing (no data)
                        MOVE.B      (LINELENGTH),D6
                        DIVU.W      #8,D6
                        ADD.L       D6,(CURRENTMEM)
SKIPMEMINC
                        MOVE.B      #$0,D5                  *D5 will contain our current length in bits (which goes up in increments of 4 bits)

READBYTE                MOVE        #53,D0
                        LEA         BUFFER,A1               *Read to buffer
                        MOVE.L      #1,D2                   *Read 1 byte
                        TRAP        #15

                        CMP.W       #0,D0                   *See if read is succesful
                        BNE         SETEOF                  *If not, say we're done reading

                                                            *(BUFFER) currently represents the ascii form of the data, we need to convert to plain hex...
                        CMP.B       #$0A,(BUFFER)           *If is line feed
                        BEQ         DONELINE                *Then line is done
                        CMP.B       #$41,(BUFFER)           *Range for letters is 41 to 46
                        BGE         ISLETTER
                        CMP.B       #$30,(BUFFER)           *Range for numbers is 30 to 39
                        BGE         ISNUMBER
                        BRA         READBYTE                *Not in either range, ignore for any strange symbols

ISLETTER                CMP.B       #$46,(BUFFER)           *Check if is within range
                        BGT         READBYTE
                        MOVE.B      (BUFFER),D7
                        ADDI.B      #$A9,D7                 *Subtract 37
                        ANDI.B      #%00001111,D7           *We only care about our one hex value

                        BRA         STOREDATA
ISNUMBER                CMP.B       #$39,(BUFFER)           *Check if is within range
                        BGT         READBYTE
                        MOVE.B      (BUFFER),D7
                        ADDI.B      #$B0,D7                 *Subtract 30
                        ANDI.B      #%00001111,D7           *We only care about our one hex value
                        BRA         STOREDATA

SETEOF                  MOVE.B      #$1,(EOFHIT)            *Used when end of file is hit
                        BRA         DONELINE

STOREDATA                                                   *Store data to line, woohoo
                        CMP.B       #$0,D4
                        BNE         NOSHIFT
                        ASL         #4,D7                   *Shift over to the left
                        MOVE.B      #1,D4                   *Next write to other half of byte
                        BRA         DONESHIFTING
NOSHIFT                 MOVE.B      #0,D4                   *Next write to fist half of byte

DONESHIFTING            OR.B        D7,(A4)                 *Put data into correct half of byte
                        ADDI        #$4,D5                  *Add 4 to our bit count
                        CMP.B       #0,D4                   *If writing to first half of byte next, go to next byte
                        BNE         SKIPBYTEINC
                        LEA         (1,A4),A4               *Increment to next byte

SKIPBYTEINC             BRA         READBYTE                *Read next byte

DONELINE                MOVE.B      D5,(LINELENGTH)         *Length of our line in bits should be in D5, store that for later use
                        JSR         PROCESSLINE_SR


                        CMP.B       #$1,(EOFHIT)            *If we hit end of file, stop
                        BEQ         DONEREADING
                        BRA         READLINE                *Otherwise, read next line


DONEREADING                                                 *Currently we get here when we hit end of file, could be other ways to get here
                        
                        BRA         ENDPRGRM                *Skip to end, define various subroutines under here

WAIT4ENTER_SR           MOVEM.L     D0-D7/A0-A6,-(SP)
                        LEA         ENTERCNT,A1             *Enter to continue message
                        MOVE.B      #14,D0                  *Set trap task to 14 (Display message in A1)
                        TRAP        #15                     *Execute task to display message
                        LEA         USERINPUT,A1
                        MOVE        #2,D0                   *Returns string from keyboard
                        TRAP        #15                     *Enter pressed oh boy!
                                                            *Then clear screen
                        MOVE.W      #$FF00,D1
                        MOVE.B      #11,D0
                        TRAP        #15
                        MOVEM.L     (SP)+,D0-D7/A0-A6
                        RTS                                 *Return to wherever we came from

PROCESSLINE_SR                                              *At this point we have the line in memory at LINESTARTLOC with a length in bits at LINELENGTH
                        LEA         LINESTARTLOC,A0
                        LEA         LINELENGTH,A1
                        CMP.B       #30,(LINECOUNT)         *LINE LENGTH SPECIFIED HERE
                        BNE         PROCESSLINE_CONT
                        CLR.B       (LINECOUNT)
                        JSR         WAIT4ENTER_SR
PROCESSLINE_CONT        ADDI.B      #1,(LINECOUNT)
                        JSR         PRINTCURRADDR           * Every line of output should start with the current address
                        MOVE.L      (A0),D0                 * put the opcode bits in D0
                        MOVE.B      (A1),D1                 * put the length of the opcode bits in D1
                        ADDQ        #1,D1                   * dumb hack, TODO remove -- increase bits by 1

                                                            * The tree consists of many copies of the same structure, implementing a binary tree walk.
                                                            *
                                                            * {0} SUB.B #1,D1         * subtract from length
                                                            * BEQ   PRINTLINE_SR  * if length is 0, fail
                                                            * LSL.L #1,D0         * leftshift the opcode bits
                                                            * BCC   {1}           * branch to zero-child node
                                                            * BCS   {2}           * branch to ones-child node
                                                            * BRA   TREEDONE      * this should never be hit
                                                            * 
                                                            * Autogenerated code, changes may be wiped out by regeneration
                        INCLUDE     "tree_search.X68"
                                                            * when we add decoders, just give them the correct label, and delete them from this list.

TREEDONE                RTS                                 * return from tree to get next line

                                                            * Decoder files go here
ADDADECODE_SR           INCLUDE     "ADDAdecode.X68"
ADDDECODE_SR            INCLUDE     "ADDdecode.X68"
ADDIDECODE_SR           INCLUDE     "ADDI_DECODE.X68"
ADDQ_SR                 INCLUDE     "ADDQdecode.X68"
AND_SR                  INCLUDE     "ANDdecode.X68"
CLR_SR                  INCLUDE     "CLRdecode.X68"
CMP_SR                  INCLUDE     "CMPdecode.X68"
DIVUW_SR                INCLUDE     "DIVUWdecode.x68"
JSR_SR                  INCLUDE     "JSRdecode.X68"
LEA_SR                  INCLUDE     "LEAdecode.X68"
MOVEDECODE_SR           INCLUDE     "MOVEdecode.X68"
                        INCLUDE     "MOVEMdecode.X68"
MULSW_SR                INCLUDE     "MULSWdecode.X68"
OR_SR                   INCLUDE     "ORdecode.X68"
SHIFTSTUFF_SR           INCLUDE     "SHIFTdecode.X68"
SUB_SR                  INCLUDE     "SUBdecode.X68"
BRANCHSTUFF_SR          INCLUDE     "BRANCHdecode.X68"

MOVEQ_SR                INCLUDE     "MOVEQdecode.X68"
FAIL                    BRA         PRINTLINE_SR            * in case any of the above were hit, handle it

PRINTCURRADDR           MOVEM.L     D0-D7/A0-A6,-(SP)
                        MOVE.B      #15,D0                  * Print the current memory location (hits D0, D1, D7)
                        CLR.L       D7
                        CLR.L       D2
                        MOVE.L      (CURRENTMEM),D7
                        LEA         CURRENTMEM,A0               
                        CLR.L       D1                      * D1 will be the number of zeroes we need to print
                        CMP.L       #$00000000,D7               * If cur address is 0, set number of zeroes to 8
                        BNE         PRINTCURRADDRCALCZERO
                        MOVE.B      #8,D1
                        BRA         PRINTCURADDRNEXTZERO
                       
                        
PRINTCURRADDRCALCZERO   MOVE.B      (A0)+,D2
                        MOVE.B      D2,D3
                        LSR.B       #4,D3
                        CMP.B       #$0,D3
                        BNE         PRINTCURADDRNEXTZERO
                        ADDI.B      #1,D1
                        MOVE.B      D2,D3
                        ANDI.B      #%00001111,D3
                        CMP.B       #$0,D3
                        BNE         PRINTCURADDRNEXTZERO
                        ADDI.B      #1,D1
                        CMP.B       #8,D1
                        BEQ         PRINTCURADDRNEXTZERO
                        BRA         PRINTCURRADDRCALCZERO
                        
PRINTCURADDRNEXTZERO    LEA         ZEROSTRING,A0
                        JSR         PRINT_SR           
                        SUBI.B      #1,D1
                        CMP.B       #0,D1
                        BNE         PRINTCURADDRNEXTZERO
                         
                        CLR.L       D1
                        MOVE.L      D7,D1
                        MOVE.B      #16,D2
                        TRAP        #15                     *Print the actual address
                        LEA         ADRSPACING,A0           *Print a fixed amount of space after the address
                        JSR         PRINT_SR
                        MOVEM.L     (SP)+,D0-D7/A0-A6
                        RTS

PRINTLINE_SR                                                *This will just go hex by hex printing to screen, example of how to handle the hex line data
                        LEA         MEMERROR,A0             *Print "DATA"
                        JSR         PRINT_SR
                        JSR         SHIFTCURSOR
                        MOVE.B      #$0,D4                  *If D4 is not set, get the first half of the byte
                        LEA         LINESTARTLOC,A4
                        MOVE.B      (LINELENGTH),D5
                        MOVE.B      #0,D7                   *D7 will be current offset in bits

PRINT_SR_LOOP1          CMP.B       #$0,D4
                        BEQ         PRINT_SR_LOOP2
                        BNE         PRINT_SR_LOOP3

PRINT_SR_LOOP2                                              *Print first half of byte
                        MOVE.B      (A4),D6                 *Move what we're currently pointing at to D6
                        ANDI.B      #%11110000,D6           *We care about first 4 bits
                        ROR.B       #4,D6                   *Rotate 4 bits to the right
                        MOVE.B      #1,D4                   *Next read other half of byte
                        ADDI        #4,D7
                        BRA         PRINT_SR_LOOP4
PRINT_SR_LOOP3                                              *Print second half of byte and increment
                        MOVE.B      (A4),D6                 *Move what we're currently pointing at to D6
                        ANDI.B      #%00001111,D6           *We care about last 4 bits
                        MOVE.B      #0,D4                   *Next read other half of byte
                        LEA         (1,A4),A4               *Increment to next byte
                        ADDI        #4,D7
                        BRA         PRINT_SR_LOOP4

PRINT_SR_LOOP4                                              *D6 should now have what we want to display in hex, now convert it to ascii oh boy
                        CMP.B       #9,D6
                        BLE         PRINT_SR_NUMB           *It's a number
                        BRA         PRINT_SR_LETT           *It's a letter

PRINT_SR_NUMB           ADDI.B      #$30,D6
                        BRA         PRINT_SR_BACK           *Display and check if we should loop again

PRINT_SR_LETT           ADDI.B      #$37,D6                 *Display and check if we should loop again
                        BRA         PRINT_SR_BACK

PRINT_SR_BACK           MOVE.B      D6,D1                   *Set up display
                        MOVE.B      #6,D0                   *We're going to display our ascii value
                        TRAP        #15                     *Display it
                        CMP.B       D5,D7
                        BGE         PRINT_SR_ESCAPE         *We're past our max bits
                        BRA         PRINT_SR_LOOP1          *Go display next value

PRINT_SR_ESCAPE         JSR         DISPLAYEND_SR           *Go to next line
                        RTS

DISPLAYEND_SR           LEA         LINEEND,A1
                        MOVE.B      #14,D0                  *Displays carriage return and line feed
                        TRAP        #15
                        RTS

SHIFTCURSOR             MOVEM.L     D0-D7/A0-A6,-(SP)
                        CLR.L       D0
                        MOVE.B      #11,D0                  *Get cursor position
                        MOVE.W      #$00FF,D1
                        TRAP        #15
                        ANDI.W      #$00FF,D1               *Clear upper half
                        ORI.W       #$1E00,D1               *Set upper half to our column
                        TRAP        #15
                        MOVEM.L     (SP)+,D0-D7/A0-A6
                        RTS

CLEARLINE_SR            LEA         LINESTARTLOC,A4         *clear out our line, reset it all
                        CLR.L       (A4)+
                        CLR.L       (A4)+
                        CLR.L       (A4)+
                        CLR.L       (A4)+
                        CLR.L       (A4)+
                        CLR.L       (A4)+
                        CLR.L       (A4)+
                        CLR.L       (A4)+
                        RTS

INPUTTOHEX_SR                                               *This is used for interpreting the starting memory location input. Our text is pointed to by A1
                                                            *The final hex value will be stored in D4. D5.B will be 1 if there was an error in input
                        CLR.L       D4                      *We'll store our converted hex value in D4, because why not
                        CLR.L       D5                      *We'll use D5 as a flag to see if we should write to first half or second half
ITH_SR_LOOP1            MOVE.B      (A1)+,D3                *Move next byte into D3
                        CMP.B       #0,D3
                        BEQ         ITH_SR_EXIT             *If we hit the end of the string, exit
                        CMP.B       #$41,D3                 *Range for letters is 41 to 46
                        BGE         ITH_SR_LETTER
                        CMP.B       #$30,D3                 *Range for numbers is 30 to 39
                        BGE         ITH_SR_NUMB
                        BRA         ITH_SR_ERROR

ITH_SR_LETTER                                               *The current byte is a letter
                        CMP.B       #$46,D3
                        BGT         ITH_SR_ERROR            *Out of letter range
                        ADDI.B      #$A9,D3                 *Subtract 37
                        ANDI.B      #%00001111,D3           *Only care about bottom half

                        BRA         ITH_SR_PUT
ITH_SR_NUMB                                                 *The current byte is a number
                        CMP.B       #$39,D3
                        BGT         ITH_SR_ERROR            *Out of number range
                        ADDI.B      #$B0,D3                 *Subtract 30
                        ANDI.B      #%00001111,D3           *We only care about our one hex value
                        BRA         ITH_SR_PUT
ITH_SR_PUT                                                  *At this point our valid hex character is in D3
                        LSL.L       #4,D4                   *Make room for new hex value
                        OR.B        D3,D4                   *Insert our new hex value

                        BRA         ITH_SR_LOOP1

ITH_SR_ERROR                                                *We get here if one of the symbols isn't valid
                        MOVE.B      #1,D5                   *Set error flag
                        BRA         ITH_SR_DONE

ITH_SR_EXIT             MOVE.B      #0,D5                   *Make sure error flag isn't set
                        BRA         ITH_SR_DONE

ITH_SR_DONE             RTS

RTS_SR                                                  * Print out the RTS -- there's no decoding to do IFF there are no leftover bits.
                        SUB.B   #1,D1                   * check length of remaining bits
                        BNE     PRINTLINE_SR            * if length is not 0, then this is not RTS
                        LEA     RTSSTRING,A0            * print "RTS"
                        JSR     PRINT_SR
                        LEA     LINEEND,A0
                        JSR     PRINT_SR
                        RTS

NOP_SR                                                  * Print out the NOP -- there's no decoding to do IFF there are no leftover bits.
                        SUB.B   #1,D1                   * check length of remaining bits
                        BNE     PRINTLINE_SR            * if length is not 0, then this is not NOP
                        LEA     NOPSTRING,A0            * print "NOP"
                        JSR     PRINT_SR
                        LEA     LINEEND,A0
                        JSR     PRINT_SR
                        RTS

PRINT_SR                                                    * Point A0 to thing to print
                        MOVEM.L     D0-D7/A0-A6,-(SP)
                        MOVE.B      #14,D0
                        MOVEA.L     A0,A1
                        TRAP        #15

                        MOVEM.L     (SP)+,D0-D7/A0-A6
                        RTS

PRINT_HEX                                                   * Put hex to print in D7.L
                        MOVEM.L     D0-D7/A0-A6,-(SP)
                        MOVE.B      #15,D0
                        MOVE.L      D7,D1
                        MOVE.B      #16,D2
                        TRAP        #15
                        MOVEM.L     (SP)+,D0-D7/A0-A6
                        RTS

ENDPRGRM                MOVE        #50,D0                  * Close open files
                        TRAP        #15

                        ORG         $5000
                        INCLUDE     "strings.X68"           * Tidying all the strings into one file

FILENAMENUMB            DS.B        11                      *Up to 6 bytes of ascii numbers in the middle, followed by ".TXT"

LINECOUNT               DS.B        1
FILEID                  DS.L        1
BUFFER                  DS.B        1                       *Used to store the ascii value of the code when reading
EOFHIT                  DS.B        1                       *Used to tell if we've hit the end of the file. 0 if not, 1 if hit
LINELENGTH              DS.B        1                       *We'll store the length in bits here.
STARTMEM                DS.L        1                       *The input starting memory location (up to two bytes)
CURRENTMEM              DS.L        1                       *The current "virtual" memory location

                        ORG         $10000
LINESTARTLOC            DS.B        32                      *This is where we store the actual information of the line in hex
USERINPUT               DS.B        80                      *This is where user input will be stored. Max user input is 80 bytes
                        END         START





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
