import klib
import argparse
import tables, strutils
from os import fileExists

# Unique sequences

var p = newParser("fxderep"):
  help("Dereplicate FASTA (and FASTQ) files")
  flag("-r", "--rename", help="Rename sequence")
  option("-p", "--prefix", help = "Sequence prefix", default = "seq")
  option("-s", "--separator", help = "Sequence separator", default = ".")
  arg("inputfile", help="FASTX file (gzip supported)")


proc main() =

  try:
    var seqFreqs = initCountTable[string]()
    var opts = p.parse(commandLineParams()) 

    if not existsFile(opts.inputfile):
      echo "FATAL ERROR: File ", opts.inputfile, " not found."
      quit(1)
    
    var f = xopen[GzFile](opts.inputfile)
    defer: f.close()
    var r: FastxRecord
    var n = 0
    # Prse FASTX
    while f.readFastx(r):
      #n += 1
      #echo ">", opts.prefix, opts.separator, n
      #echo r.seq
      seqFreqs.inc(r.seq)
    
    seqFreqs.sort()
    for key, val in seqFreqs:
      n += 1
      echo ">", opts.prefix, opts.separator, n, ";size=", val, "\n", key;
  except:
    echo p.help
    echo get_current_exception_msg()
  

main()
