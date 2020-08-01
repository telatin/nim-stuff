import klib
import argparse
import tables, strutils
from os import fileExists

# PARSE FILE
var p = newParser("fxderep"):
  help("Dereplicate FASTA (and FASTQ) files")
  flag("-r", "--rename", help="Rename sequence")
  option("-p", "--prefix", help = "Sequence prefix", default = "seq")
  option("-s", "--separator", help = "Sequence separator", default = ".")
  arg("inputfile", help="FASTX file (gzip supported)")
 
proc main() =

  try:
    var opts = p.parse(commandLineParams()) 

    if not existsFile(opts.inputfile):
      echo "FATAL ERROR: File ", opts.inputfile, " not found."
      quit(1)
    
    var f = xopen[GzFile](opts.inputfile)
    defer: f.close()
    var r: FastxRecord
    var n = 0

    while f.readFastx(r):
      n += 1
      echo "#", opts.prefix, opts.separator, n
      echo "name\t", r.name, " [", r.comment, "]"
      echo "seq\t", r.seq
      echo "qual\t", r.qual

  except:
    echo p.help
    echo get_current_exception_msg()
  

main()
