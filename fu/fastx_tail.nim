import klib
import re
import tables, strutils
from os import fileExists
import docopt
import ./seqfu_utils

proc fastx_tail(argv: var seq[string]): int =
    let args = docopt("""
Usage: view [options] [<inputfile> ...]

NOT YET IMPLEMENTED 

Options:
  -n, --num INT          Print the first INT sequences
  -v, --verbose          Verbose output
  -h, --help             Show this help

  """, version=version(), argv=argv)

    verbose = args["--verbose"]



 
