import klib
import re
import argparse
import tables, strutils
from os import fileExists

const prog = "derep"
const version = "0.3"
#[
  
  # v.0.2
    - Added "-k" to keep sequence names (first found as cluster name)
    - Added "-i" to ignore counts (default behaviour is to use it)
  # v.0.1
    - Initial release with regex for ";size=\d+

]#


var p = newParser(prog):
  help("Dereplicate FASTA (and FASTQ) files, print dereplicated sorted by cluster size with ';size=NNN' decoration.")
  flag("-k", "--keep-name", help="Do not rename sequence, but use the first sequence name")
  flag("-i", "--ignore-size", help="Do not count 'size=INT;' annotations (they will be stripped in any case)")
  option("-p", "--prefix", help = "Sequence name prefix", default = "seq")
  option("-s", "--separator", help = "Sequence name separator", default = ".")
  arg("inputfile", help="FASTX file (gzip supported)")



proc main() =

  try:
    var opts = p.parse(commandLineParams()) 

    let sizePattern = re";?size=(\d+);?";
    let sizeCapture = re".*;size=(\d+);?.*"
    var seqFreqs = initCountTable[string]()
    var seqNames = initTable[string, string]()
    

    if opts.inputfile == "":
      echo "\nMissing arguments."
      quit(0)

    if not existsFile(opts.inputfile):
      echo "FATAL ERROR: File ", opts.inputfile, " not found."
      quit(1)

    #[
    if opts.ignore_size:
      stderr.writeLine(" - Ignoring size")

    if opts.keep_name:
      stderr.writeLine(" - Keeping first sequence name")
    ]#
    var f = xopen[GzFile](opts.inputfile)
    defer: f.close()
    var r: FastxRecord
    var n = 0

    # Prse FASTX
    var match: array[1, string]
    while f.readFastx(r):
      if opts.keep_name:
        var seqname = r.name
        if seqFreqs[r.seq] == 0:
          seqNames[r.seq] = seqname.replace(sizePattern, "")

      if not opts.ignore_size and match(r.name, sizeCapture, match):
        seqFreqs.inc(r.seq, parseInt(match[0]))
      else:
        seqFreqs.inc(r.seq)
    
    seqFreqs.sort()
    for key, val in seqFreqs:
      n += 1
      var name: string

      # Generate name
      if opts.keep_name:
        name = seqNames[key]
      else:
        name = opts.prefix & opts.separator & $(n)

      name.add(";size=" & $(val) )

      echo ">", name,  "\n", key;
  except:
    echo p.help
    quit(0)
  

main()
