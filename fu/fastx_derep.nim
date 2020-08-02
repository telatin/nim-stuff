import klib
import re
import argparse
import tables, strutils
from os import fileExists
import docopt
import ./version
 
#[
  # v.0.6
    - bug fixes
    - size selection
    
  # v.0.5
    - search for size=INT annotation also in comments IF not found in name

  # v.0.4
    - added multifile support
    - added dna format function (-w)
    - compiler optimizations enabled

  # v.0.3
    - added "-c" to print size as comment rather than in sequence name
    - added "-m" to print sequences if their cluster size is >= INT
    - 0.3.1: printing number of skipped sequences
    - 0.3.2: added exception message

  # v.0.2
    - Added "-k" to keep sequence names (first found as cluster name)
    - Added "-i" to ignore counts (default behaviour is to use it)
  # v.0.1
    - Initial release with regex for ";size=\d+

]#

proc verbose(msg: string, print: bool) =
  if print:
    stderr.writeLine(" * ", msg)


proc format_dna(seq: string, format_width: int): string =
  if format_width == 0:
    return seq
  for i in countup(0,seq.len - 1,format_width):
    #let endPos = if (seq.len - i < format_width): seq.len - 1
    #            else: i + format_width - 1
    if (seq.len - i <= format_width):
      result &= seq[i..seq.len - 1]
    else:
      result &= seq[i..i + format_width - 1] & "\n"

#[
var p = newParser(prog):
  help("Dereplicate FASTA (and FASTQ) files, print dereplicated sorted by cluster size with ';size=NNN' decoration.")
  flag("-k", "--keep-name", help="Do not rename sequence, but use the first sequence name")
  flag("-i", "--ignore-size", help="Do not count 'size=INT;' annotations (they will be stripped in any case)")
  flag("-v", "--verbose", help="Print verbose messages")
  option("-m", "--min-size", help="Print clusters with size equal or bigger than INT sequences", default="0")
  option("-p", "--prefix", help = "Sequence name prefix", default = "seq")
  option("-s", "--separator", help = "Sequence name separator", default = ".")
  option("-w", "--line-width", help = "FASTA line width (0: unlimited)", default = "0")
  option("-l", "--min-length", help = "Discard sequences shorter than MIN_LEN", default = "0")
  option("-x", "--max-length", help = "Discard sequences longer than MAX_LEN", default = "0")

  flag("-c", "--size-as-comment", help="Print cluster size as comment, not in sequence name")
  arg("inputfile",  nargs = -1)
]# 

proc fastx_derep(argv: var seq[string]): int =
    let args = docopt("""
derep: dereplicate FASTQ files

  Usage: derep [options] [file1 ...]

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
  
  """, version=version(), argv=argv)


    let sizePattern = re";?size=(\d+);?";
    let sizeCapture = re".*;?size=(\d+);?.*"

    var size_separator = if opts.size_as_comment : " " 
               else: ";"
    var seqFreqs = initCountTable[string]()
    var seqNames = initTable[string, string]()
    
    verbose("Starting derep v." & version, opts.verbose)
    
    if opts.inputfile.len() == 0:
      echo "Missing arguments."
      if not opts.help:
        echo "Type --help for more info."
      quit(0)
    
    for filename in opts.inputfile:      
      if not existsFile(filename):
        echo "FATAL ERROR: File ", filename, " not found."
        quit(1)

      var f = xopen[GzFile](filename)
      defer: f.close()
      var r: FastxRecord
      verbose("Reading " & filename, opts.verbose)

      # Prse FASTX
      var match: array[1, string]
      var c = 0

      while f.readFastx(r):
        c+=1

        if opts.min_length != "0" and len(r.seq) < parseInt(opts.min_length):
          continue
        if opts.max_length != "0" and len(r.seq) > parseInt(opts.max_length):
          continue
        
        if opts.keep_name:
          var seqname = r.name
          if seqFreqs[r.seq] == 0:
            seqNames[r.seq] = seqname.replace(sizePattern, "")
        if not opts.ignore_size:
          if match(r.name, sizeCapture, match):
            seqFreqs.inc(r.seq, parseInt(match[0]))
          elif match(r.comment, sizeCapture, match):
            seqFreqs.inc(r.seq, parseInt(match[0]))
          else:
            seqFreqs.inc(r.seq)
        else:
          seqFreqs.inc(r.seq)
      verbose("\tParsed " & $(c) & " sequences", opts.verbose)
    var n = 0
    seqFreqs.sort()

    for repSeq, clusterSize in seqFreqs:
      n += 1
      # Generate name
      var name: string
      if opts.keep_name:
        name = seqNames[repSeq]
      else:
        name = opts.prefix & opts.separator & $(n)

      if clusterSize < parseInt(opts.min_size):
        let  missing = seqFreqs.len - (n - 1)
        stderr.writeLine("Skipped ", missing, " clusters having less than " , opts.min_size ," sequences.")
        quit(0)
      name.add(size_separator & "size=" & $(clusterSize) )
      echo ">", name,  "\n", format_dna(repSeq, parseInt(opts.line_width));
 
  

when isMainModule:
  main(commandLineParams())
