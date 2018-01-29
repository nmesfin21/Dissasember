#! /usr/bin/env python

import sys

USAGE = """
Usage:
    python format.py <filename>
"""

"""
    Reads in a (valid, hopefully) Easy68K assembly file, and write out a version with standardized
    spacing.

    Read file line by line, using whitespace delimiting to identify the segments.
    Determine if each segment is: label, opcode, operand, comment. All are optional!
    Create four arrays that, in order, contain the respective part found on each line.
    Write the segments out again, right-padding each section with spaces so they are all as long
    as the longest.
    The code should remain parsable by Easy68k, but also look much nicer to the poor humans who
    have to read it.

    In theory the arrays could be packaged as a nicer data type, but this was fast to write.

    segments per case
    0 |  empty line
    1 |  label
    |   ""     opcode
    |   ""     ""        ""        comment
    2 |  label   opcode
    |   ""     opcode    ""        comment
    |   ""     opcode   operands
    3 |  label   opcode   operands
    |  label   opcode    ""        comment
    |  label   opcode   operands   comment
"""

def fileprocessor(filename):
    """
    docstring goes here
    """
    # one array per column, with value to track maximum length
    labels = []
    maxlabellength = 8
    opcodes = []
    maxopcodelength = 8
    operands = []
    maxoperandlength = 8
    comments = []
    # input file loop
    with open(filename, "r") as file:
        for line in file:
            # these will be added to each array respectively
            label = ""
            opcode = ""
            operand = ""
            operand_exempt_measurement = False # special case handling for strings

            # split comments off at the first " * " character
            splitline = line.split("*", 1)
            if len(splitline) == 2:
                assembly = splitline[0]
                comment = "*"+splitline[1]
            else:
                assembly = splitline[0]
                comment = ""

            # split on " ' " to locate strings, treat them like operands... with a special flag
            segments = assembly.split("'", 1)
            if len(segments) == 2:
                assembly = segments[0]
                operand = "'"+segments[1].rstrip()
                operand_exempt_measurement = True
            # split on whitespace to identify sections of assembly
            segments = assembly.split()
            # one segment was extracted, label or opcode or comment
            if len(segments) == 1:
                # if the first character is whitespace, it's an opcode
                if (line[0] == " ") or (line[0] == "\t"):
                    opcode = segments[0]
                # it's a label by itself
                else:
                    label = segments[0]

            # if there're two parts, it's label-opcode or opcode-operand or opcode-comment
            elif len(segments) == 2:
                # if the first character is whitespace then there's no label
                if (line[0] == " ") | (line[0] == "\t"):
                    opcode = segments[0]
                    # if second starts with an asterisk it's a comment, otherwise operand
                    if segments[1][0] == "*":
                        comment = segments[1]
                    else:
                        operand = segments[1]
                else:
                    label = segments[0]
                    opcode = segments[1]
            elif len(segments) == 3:
                label = segments[0]
                opcode = segments[1]
                # if third starts with an asterisk it's a comment
                if segments[2][0] == "*":
                    comment = segments[2]
                else:
                    operand = segments[2]
            elif len(segments) == 4:
                label = segments[0]
                opcode = segments[1]
                operand = segments[2]
                comment = segments[3]
            # update the lengh value if these are longest
            if len(label) > maxlabellength:
                maxlabellength = len(label) + 4- len(label)%4
            if len(opcode) > maxopcodelength:
                maxopcodelength = len(opcode) + 4 -len(opcode)%4
            if len(operand) > maxoperandlength and not operand_exempt_measurement:
                maxoperandlength = len(operand) + 4 - len(operand)%4
            # whatever we found, put them in place
            labels.append(label)
            opcodes.append(opcode)
            operands.append(operand)
            comments.append(comment)
    print("found " + str(len(labels)) + " lines with max spacings of:")
    print("| label:"+str(maxlabellength)+" | opcode:"+str(maxopcodelength)+" | operand:"+str(maxoperandlength)+" | comments:whocares")
    #filename = filename.split(".") # split the filname and the extension apart
    if len(filename) < 2: # if there was no extension, add one.
        filename.append(".X68")
    #with open(filename[0]+"_formatted."+filename[1], "w") as f2:
    with open(filename, "w") as f2:
        seen_opcodes = False #until we've hit an opcode, leave comments left-justified
        for index, value in enumerate(labels):
            label = value               + " "*(maxlabellength  - len(labels[index])+4)
            opcode = opcodes[index]     + " "*(maxopcodelength - len(opcodes[index])+4)
            operand = operands[index]   + " "*(maxoperandlength - len(operands[index])+4)
            comment = comments[index]
            if not opcode.strip() == "": # once we've hit an opcode, we stop modifiying comments
                seen_opcodes = True
            if not seen_opcodes:
                f2.write(comment.rstrip()+"\n")
            else:
                f2.write((label + opcode + operand + comment).rstrip() + "\n")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Incorrect arguments.")
        print(USAGE)
        exit()
    fileprocessor(sys.argv[1])