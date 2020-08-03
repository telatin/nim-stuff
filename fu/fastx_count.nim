import klib
import re
import argparse
import tables, strutils
from os import fileExists
import docopt
import ./version





proc fastx_count(argv: var seq[string]): int =
    let args = docopt("""
Usage: count [options] [<inputfile> ...]

Options:
  -a, --abs-path         Print absolute paths
  -b, --basename         Print only filenames
  -u, --unpair           Print separate records for paired end files
  -v, --verbose          Verbose output
  -h, --help             Show this help

  
  """, version=version(), argv=argv)

    verbose = args["--verbose"]

    var 
      files    : seq[string]
      seqCount = initCountTable[string]()
      abspath  = args["--abs-path"]
      basename = args["--basename"]
      unpaired = args["--unpair"]
   
    
    if args["<inputfile>"].len() == 0:
      stderr.writeLine("Waiting for STDIN... [Ctrl-C to quit, type with --help for info].")
      files.add("-")
    else:
      for file in args["<inputfile>"]:
        files.add(file)


    

    for filename in files:      
      if filename != "-" and not existsFile(filename):
        stderr.writeLine("WARNING: File ", filename, " not found.")
        
      var f = xopen[GzFile](filename)
      defer: f.close()
      var 
        r: FastxRecord
        c = 0
      while f.readFastx(r):
        c+=1
        seqCount.inc(filename)

    for filename, count in seqCount:
      echo filename, "\t", count


 