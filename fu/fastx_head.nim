import klib
import strformat
import tables, strutils
from os import fileExists
import docopt
import ./seqfu_utils

proc fastx_head(argv: var seq[string]): int =
    let args = docopt("""
Usage: head987io [options] [<inputfile> ...]

Options:
  -n, --num NUM          Print the first NUM sequences [default: 10]
  -k, --skip SKIP        Print one sequence every SKIP [default: 0]
  -p, --prefix STRING    Rename sequences with prefix + incremental number
  -s, --strip-comments   Remove comments
  --fasta                Force FASTA output
  --fastq                Force FASTQ output
  -q, --fastq-qual INT   FASTQ default quality [default: 33]
  -v, --verbose          Verbose output
  -h, --help             Show this help

  """, version=version(), argv=argv)

    verbose = args["--verbose"]
    stripComments = args["--strip-comments"]
    forceFasta = args["--fasta"]
    forceFastq = args["--fastq"]
    defaultQual = parseInt($args["--fastq-qual"])
    var
      num, skip : int
      prefix : string
      files : seq[string]   
    try:

      num =  parseInt($args["--num"])
      skip =  parseInt($args["--skip"])
    except:
      stderr.writeLine("Error: Wrong parameters!")
      quit(1)

    if args["--prefix"]:
      prefix = $args["--prefix"]

    if args["<inputfile>"].len() == 0:
      stderr.writeLine("Waiting for STDIN... [Ctrl-C to quit, type with --help for info].")
      files.add("-")
    else:
      for file in args["<inputfile>"]:
        files.add(file)
    
    
    for filename in files:
      echoVerbose(filename, verbose)
      var 
        f = xopen[GzFile](filename)
        y = 0
        r: FastxRecord
        
      defer: f.close()
      var 
        c  = 0
        printed = 0
               
      while f.readFastx(r):
        c += 1

        if skip > 0:
          y = c mod skip

        if printed == num:
          break

        if y == 0:
          printed += 1
          if len(prefix) > 0:
            r.name = $prefix & $printed
          printSeq(r, nil)
      
      if printed < num:
        stderr.writeLine("WARNING\nPrinted less sequences (", printed, "/", num, ") than requested for ", filename, ". Try reducing --skip.")
        