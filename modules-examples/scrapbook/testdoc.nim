import docopt
import os
import json
let opts = docopt("""
ilv: interleave FASTQ files

  Usage: derep [options] <fasta-files> ...

  -f --for-tag <tag-1>       string identifying forward files [default: auto]
  -r --rev-tag <tag-2>       string identifying forward files [default: auto]
  -o --output <outputfile>   save file to <out-file> instead of STDOUT
  -c --check                 enable careful mode (check sequence names and numbers)
  -v --verbose               print verbose output

  -s --strip-comments        skip comments
  -p --prefix "string"       rename sequences (append a progressive number)

guessing second file:
  by default <forward-pair> is scanned for _R1. and substitute with _R2.
  if this fails, the patterns _1. and _2. are tested.

example:

    ilv -1 file_R1.fq > interleaved.fq
  
  """, argv=commandLineParams())

echo "Raw: ", opts

let optjson = %* opts

echo "Json: ", optjson.pretty()