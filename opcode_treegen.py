"""
opcode_treegen.py takes a mapping from binary to opcode, and a snippet of assembly as arguments.
It then creates a copy of the snippet for every node in a binary tree corresponding to the
binary strings. The snippet we want to use performs a binary tree search by popping a bit,
then branching to one of:
    - the next node in the tree,
    - an appropriate decoder for the opcode,
    - the error handler.


Example assembly snippet:
{
    {0} SUB.B #1,D1             * reduce the length register by 1
        BNE   PRINTLINE_SR      * if we're out of bits, we're done
        LSL.L #1,D0             * left-shift the opcode bits
        BCC   {1}               * branch to 0-child of this node
        BRA   {2}               * branch to 1-child of this node
}

Example contents of names.JSON to map binary strings to opcode names:
    {
    "0000011000":"ADDIB",
    "0000011001":"ADDIL",
    "0000011010":"ADDL",
    "0001":"MOVEB",
    "0011":"MOVEW",
    ...
    }


"""

import json
import argparse

class TreeGen(object):
    """
    class docstring
    """

    def __init__(self, static_names, branch_string, failure='PRINTLINE_SR', prefix='b'):
        self.static_names = static_names
        self.max_length = max(map(len, static_names.keys()))

        self.nodes = {}
        self.generate_valid_names()
        self.failure = failure
        self.prefix = prefix
        self.branch_string = branch_string


    def generate_valid_names(self):
        """
        """
        self.valid_names = ['']
        for key in self.static_names.keys():
            while key:
                self.valid_names.append(key)
                key = key[:-1]


    def display_name(self, base):
        """
        """
        if base not in self.valid_names:
            return self.failure

        elif base in self.static_names:
            return self.static_names[base]

        return self.prefix + base


    def insert_branch(self, parent):
        """
        """
        zerochild = parent + '0'
        oneschild = parent + '1'
        nodestring = self.branch_string.format(self.display_name(parent),
                                               self.display_name(zerochild),
                                               self.display_name(oneschild))
        self.nodes[parent] = nodestring
        self.walk(oneschild)
        self.walk(zerochild)


    def walk(self, name):
        """
        """
        if len(name) > self.max_length:
            return

        if name in self.valid_names and not name in self.static_names:
            self.insert_branch(name)


def main():
    """
    """
    with open(ARGS.static_names_path, 'r') as snf:
        static_names = json.load(snf)

    with open(ARGS.branch_string_path, 'r') as bsp:
        branch_string = bsp.read()

    tree = TreeGen(static_names, branch_string)
    tree.walk('')

    with open(ARGS.output_path, 'w') as outputfile:
        for key, value in tree.nodes.items():
            outputfile.write(value + '\n')
        #for key, value in static_names.items():
        #    outputfile.write(value+"\n")


if __name__ == '__main__':
    PARSER = argparse.ArgumentParser()
    PARSER.add_argument('static_names_path', type=str)
    PARSER.add_argument('branch_string_path', type=str)
    PARSER.add_argument('output_path', type=str)

    ARGS = PARSER.parse_args()
    main()
