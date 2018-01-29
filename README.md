# Dissasember
CSS422_Disassembler
Group project for CSS 422 at UW Bothell, fall 2017.
This dissassembler will scan across a designated range in Easy68k's simulated memory, and decodes opcodes and effective addresses.
Control flow as imagined by Ben:
Get user input for starting and ending memory addresses
Validate address range (sequential order is correct, size is long enough)
Clear the screen in preparation for printing pages

(?) slide address forward until finding a valid opcode start?

Start decoding loop at beginning address

Decoding loop
  Determine if word starting at current address is a valid opcode
  If not
     write XXXXXXXX DATA YYYY, where XXXXXXXX is the memory address of the word and YYYY is the hex value of the word

  If yes
    Grab the section of memory corresponding to address and data
      Give the starting memory address of the EA to the EA decoder
      EA decoder returns here, begin reading effective address data from known memory location until hitting a terminator
      Write correct address, data, hex version, and effective address to the screen
  If the current address is not equal to the end address
    Increment address by 1 byte (or word?) and loop.
  Else end

EA Decoder
  read accross the region corresponding to effective address(es)
  if operands are valid
    put operands into memory with termination
  if not
    put terminator into known address
  return to loop
