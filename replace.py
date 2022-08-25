#! /usr/bin/env python
# __a__

import sys

if len(sys.argv) < 4:
    exit("Need at least three command-line arguments!")


input_file = sys.argv[1]
output_file = sys.argv[2]

text = ""
with open(input_file, 'r') as f:
    text = f.read()

    for arg in sys.argv[3:]:
        arg_split = arg.split('=')

        if len(arg_split) != 2:
            exit("Wrong format for command-line arguments!")

        text = text.replace(arg_split[0], arg_split[1])
    
with open(output_file, "w") as f:
    f.write(text)