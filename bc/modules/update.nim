import strformat
import tables, strutils
from os import fileExists
import docopt
import ../pkg_utils


proc mod_update(argv: var seq[string]): int =
    let args = docopt("""
Usage: head [options] [<inputfile> ...]

Options:
  -n, --num NUM          Print the first NUM sequences [default: 10]
  -k, --skip SKIP        Print one sequence every SKIP [default: 0]
  -p, --prefix STRING    Rename sequences with prefix + incremental number
  -s, --strip-comments   Remove comments
  -b, --basename         prepend basename to sequence name
  --fasta                Force FASTA output
  --fastq                Force FASTQ output
  --sep STRING       Sequence name fields separator [default: _]
  -q, --fastq-qual INT   FASTQ default quality [default: 33]
  -v, --verbose          Verbose output
  -h, --help             Show this help

  """, version=version(), argv=argv)

    verbose = args["--verbose"]
 
  