WECLOMEMSG              DC.B        'Welcome!',CR,LF,0
MEMLOCMSG               DC.B        'Enter the starting memory location in hex between 0 and FFF000',CR,LF,'Memory Location: ',0
MEMLOCERROR             DC.B        'Memory location must be between 0 and FFF000',CR,LF,'Memory Location: ',0
FILENUMMSG              DC.B        'Enter the decimal file number. The file should be named FILE<X>.TXT',CR,LF,'File Number: ',0
FILENUMERROR            DC.B        'File number must be a decimal number between 0 and 999999.',CR,LF,'File Number: ',0
LINEEND                 DC.B        CR,LF,0
ENTERCNT                DC.B        'Press enter to continue...',CR,LF,0
FILENOTFOUND            DC.B        'File not found',CR,LF,0
MEMERROR                DC.B        'DATA    ',0
ADRSPACING              DC.B        '    ',0
CLRSTRING               DC.B        'CLR',0
MOVESTRING              DC.B        'MOVE',0
MOVEMSTRING             DC.B        'MOVEM',0
ADDSTRING               DC.B        'ADD',0
ADDASTRING              DC.B        'ADDA',0
ADDISTRING              DC.B        'ADDI',0
ADDQSTRING              DC.B        'ADDQ',0
SUBSTRING               DC.B        'SUB',0
ANDSTRING               DC.B        'AND',0
ORSTRING                DC.B        'OR',0
JSRSTRING               DC.B        'JSR',0
LEASTRING               DC.B        'LEA',0
DIVUWSTRING             DC.B        'DIVU',0
MULSWSTRING             DC.B        'MULS',0
CMPSTRING               DC.B        'CMP',0
LSLSTRING               DC.B        'LSL',0
LSRSTRING               DC.B        'LSR',0
ASRSTRING               DC.B        'ASR',0
ASLSTRING               DC.B        'ASL',0 
RORSTRING               DC.B        'ROR',0
ROLSTRING               DC.B        'ROL',0 
MOVEASTRING             DC.B        'MOVEA',0
NOPSTRING               DC.B        'NOP',0
RTSSTRING               DC.B        'RTS',0
BGTSTRING               DC.B        'BGT',0
BCCSTRING               DC.B        'BCC',0
BLESTRING               DC.B        'BLE',0
MOVEQSTRING             DC.B        'MOVEQ.L',0
BYTESTRING              DC.B        '.B',0
WORDSTRING              DC.B        '.W',0
LONGSTRING              DC.B        '.L',0
COMMASTRING             DC.B        ',',0
SPACESTRING             DC.B        ' ',0
TABSTRING               DC.B        9,0
ZEROSTRING              DC.B        '0',0
POUNDSTRING             DC.B        '#',0
DOLLARSTRING            DC.B        '$',0
FWDSLASHSTRING          DC.B        '/',0
ASTRING                 DC.B        'A',0
DSTRING                 DC.B        'D',0
LPARENSTRING            DC.B        '(',0
RPARENSTRING            DC.B        ')',0
PLUSSTRING              DC.B        '+',0
MINUSSTRING             DC.B        '-',0
FILENAME                DC.B        'TEST'



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
