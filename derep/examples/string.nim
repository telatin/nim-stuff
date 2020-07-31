import re


let string1 : string = ">my_Seq;size="
let string2 : string = ">Other_Seq;size=123"
let string3 : string = "Nothing to do"
let sizeRe = re".*;size=(\d+);?.*"

var seqs = @[string1, string2, string3]

for s in seqs:
    echo "Parsing: [", s, "]"
    var match: array[1, string]

    if match(s, sizeRe, match):
        echo "\tOK: ", match[0]
    else:
        echo "\t--"