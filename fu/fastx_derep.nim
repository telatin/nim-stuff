import klib
import re
import tables, strutils
from os import fileExists
import docopt
import ./seqfu_utils





proc fastx_derep(argv: var seq[string]): int =
    let args = docopt("""
Usage: derep [options] [<inputfile> ...]


Options:
  -k, --keep-name              Do not rename sequence, but use the first sequence name
  -i, --ignore-size            Do not count 'size=INT;' annotations (they will be stripped in any case)
  -v, --verbose                Print verbose messages
  -m, --min-size=MIN_SIZE      Print clusters with size equal or bigger than INT sequences [default: 0]
  -p, --prefix=PREFIX          Sequence name prefix [default: seq]
  -s, --separator=SEPARATOR    Sequence name separator [default: .]
  -w, --line-width=LINE_WIDTH  FASTA line width (0: unlimited) [default: 0]
  -l, --min-length=MIN_LENGTH  Discard sequences shorter than MIN_LEN [default: 0]
  -x, --max-length=MAX_LENGTH  Discard sequences longer than MAX_LEN [default: 0]
  --add-len                    Add length to sequence
  -c, --size-as-comment        Print cluster size as comment, not in sequence name
  -h, --help                   Show this help

  
  """, version=version(), argv=argv)

  

    let 
      sizePattern = re";?size=(\d+);?"
      sizeCapture = re".*;?size=(\d+);?.*"
      addLength = args["--add-len"]

    var size_separator = if args["--size-as-comment"] : " " 
               else: ";"
    var 
      seqFreqs = initCountTable[string]()
      seqNames = initTable[string, string]()
      files    : seq[string]

   
    
    if args["<inputfile>"].len() == 0:
      stderr.writeLine("Waiting for STDIN... [Ctrl-C to quit, type with --help for info].")
      files.add("-")
    else:
      for file in args["<inputfile>"]:
        files.add(file)


    
    for filename in files:      
      if filename != "-" and not existsFile(filename):
        echo "FATAL ERROR: File ", filename, " not found."
        quit(1)


      var f = xopen[GzFile](filename)
      defer: f.close()
      var r: FastxRecord
      echoVerbose("Reading " & filename, args["--verbose"])

      # Prse FASTX
      var match: array[1, string]
      var c = 0



      while f.readFastx(r):
        c+=1

        if $args["--min-length"] != "0" and len(r.seq) < parseInt($args["--min-length"]):
          continue
        if $args["--max-length"] != "0" and len(r.seq) > parseInt($args["--max-length"]):
          continue
        
        if args["--keep-name"]:
          var seqname = r.name
          if seqFreqs[r.seq] == 0:
            seqNames[r.seq] = seqname.replace(sizePattern, "")
        if not args["--ignore-size"]:
          if match(r.name, sizeCapture, match):
            seqFreqs.inc(r.seq, parseInt(match[0]))
          elif match(r.comment, sizeCapture, match):
            seqFreqs.inc(r.seq, parseInt(match[0]))
          else:
            seqFreqs.inc(r.seq)
        else:
          seqFreqs.inc(r.seq)
      echoVerbose("\tParsed " & $(c) & " sequences", args["--verbose"])
    var n = 0
    seqFreqs.sort()

    for repSeq, clusterSize in seqFreqs:
      n += 1
      # Generate name
      var name: string
      if args["--keep-name"]:
        name = seqNames[repSeq]
      else:
        name = $args["--prefix"] & $args["--separator"] & $(n)

      if clusterSize < parseInt($args["--min-size"]):
        let  missing = seqFreqs.len - (n - 1)
        stderr.writeLine("Skipped ", missing, " clusters having less than " , args["--min-size"] ," sequences.")
        quit(0)
      name.add(size_separator & "size=" & $(clusterSize) )

      if addLength:
        name.add(";len=" & $len(repSeq))
      echo ">", name,  "\n", format_dna(repSeq, parseInt($args["--line-width"]));
 
