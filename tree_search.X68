b                       SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b0                  *
                        BCS         b1                  *

b010010001              SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         MOVEMWTM_SR         *
                        BCS         MOVEMLTM_SR         *

b010011001              SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         MOVEMWTR_SR         *
                        BCS         MOVEMLTR_SR         *

b010                    SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b0100               *
                        BCS         ADDQ_SR             *

b011                    SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         BRANCHSTUFF_SR      *
                        BCS         MOVEQ_SR            *

b111                    SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         SHIFTSTUFF_SR       *
                        BCS         PRINTLINE_SR        *

b110                    SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         AND_SR              *
                        BCS         ADDDECODE_SR        *

b010011100111000        SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         NOP_SR              *

b010010111              SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         LEA_SR              *

b01000101               SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         b010001011          *

b0100110                SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b01001100           *
                        BCS         b01001101           *

b0100111                SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b01001110           *
                        BCS         b01001111           *

b01000111               SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         b010001111          *

b00                     SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b000                *
                        BCS         b001                *

b01                     SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b010                *
                        BCS         b011                *

b0100000                SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         b01000001           *

b0100001                SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b01000010           *
                        BCS         b01000011           *

b01000001               SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         b010000011          *

b010011100111           SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b0100111001110      *
                        BCS         PRINTLINE_SR        *

b01001110011101         SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b010011100111010    *
                        BCS         PRINTLINE_SR        *

b01001110011100         SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b010011100111000    *
                        BCS         PRINTLINE_SR        *

b01001101               SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         b010011011          *

b01001                  SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b010010             *
                        BCS         b010011             *

b1                      SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b10                 *
                        BCS         b11                 *

b0                      SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b00                 *
                        BCS         b01                 *

b01001000               SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         b010010001          *

b01001001               SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         b010010011          *

b010000101              SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         CLRL_SR             *
                        BCS         PRINTLINE_SR        *

b010000100              SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         CLRB_SR             *
                        BCS         CLRW_SR             *

b0000                   SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b00000              *
                        BCS         PRINTLINE_SR        *

b010010011              SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         LEA_SR              *

b010010                 SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b0100100            *
                        BCS         b0100101            *

b010011                 SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b0100110            *
                        BCS         b0100111            *

b010011011              SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         LEA_SR              *

b010001011              SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         LEA_SR              *

b0100                   SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b01000              *
                        BCS         b01001              *

b010001111              SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         LEA_SR              *

b01000                  SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b010000             *
                        BCS         b010001             *

b001                    SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         MOVEDECODE_SR       *
                        BCS         MOVEDECODE_SR       *

b000                    SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b0000               *
                        BCS         MOVEDECODE_SR       *

b01001110011            SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         b010011100111       *

b010011111              SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         LEA_SR              *

b010011100111010        SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         RTS_SR              *

b100                    SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         OR_SR               *
                        BCS         SUB_SR              *

b101                    SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         CMP_SR              *

b0100101                SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         b01001011           *

b0100100                SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b01001000           *
                        BCS         b01001001           *

b01000010               SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b010000100          *
                        BCS         b010000101          *

b01000011               SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         b010000111          *

b11                     SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b110                *
                        BCS         b111                *

b10                     SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b100                *
                        BCS         b101                *

b0100011                SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         b01000111           *

b0100010                SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         b01000101           *

b01001011               SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         b010010111          *

b0000011                SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         ADDIDECODE_SR       *
                        BCS         PRINTLINE_SR        *

b000001                 SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         b0000011            *

b01001110               SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b010011100          *
                        BCS         b010011101          *

b01001111               SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         b010011111          *

b0100111001             SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         b01001110011        *

b010000011              SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         LEA_SR              *

b01001100               SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         b010011001          *

b00000                  SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         b000001             *

b010001                 SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b0100010            *
                        BCS         b0100011            *

b010000                 SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b0100000            *
                        BCS         b0100001            *

b010011101              SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         JSR_SR              *
                        BCS         PRINTLINE_SR        *

b0100111001110          SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         b01001110011100     *
                        BCS         b01001110011101     *

b010000111              SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         LEA_SR              *

b010011100              SUB.B       #1,D1               *
                        BEQ         PRINTLINE_SR        *
                        LSL.L       #1,D0               *
                        BCC         PRINTLINE_SR        *
                        BCS         b0100111001         *

