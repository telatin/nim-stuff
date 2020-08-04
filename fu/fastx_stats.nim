import klib
import re
import tables, strutils
from os import fileExists
import docopt
import ./seqfu_utils

proc fastx_stats(argv: var seq[string]): int =
    let args = docopt("""
Usage: stats [options] [<inputfile> ...]

Options:
  -a, --abs-path         Print absolute paths
  -b, --basename         Print only filenames
  -v, --verbose          Verbose output
  -h, --help             Show this help

  """, version=version(), argv=argv)

    verbose = args["--verbose"]



 
