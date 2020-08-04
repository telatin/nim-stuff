import klib
import tables, strutils, sequtils
from os import fileExists
import docopt
import ./seqfu_utils
import terminaltables

type
  FastxStats*   = tuple[count, sum, min, max, n25, n50, n75, n90: int, auN, avg: float]

proc getFastxStats*(filename: string): FastxStats {.discardable.} =
  var
    f = xopen[GzFile](filename)
    r: FastxRecord
    total = 0
    nseq  = 0 
    ctgSizes = initOrderedTable[int, int]()

    accum = 0
    auN    : float
    i      = 0
#    nArray = initTable[int, int]()
#    iArray = initTable[int, int]()
  defer: f.close()
  
  while f.readFastx(r):
    var ctgLen = len(r.seq)


    if not (ctgLen in ctgSizes):
      ctgSizes[ctgLen] = 1
    else:
      ctgSizes[ctgLen]+=1
    total += ctgLen
    nseq  += 1

  result.sum = total

  var
    ctgSizesKeys  = toSeq(keys(ctgSizes))

  sort(ctgSizesKeys, proc(a, b: int): int =
      if a < b: return -1
      else: return 1
  )
  result.max = ctgSizesKeys[^1]
  result.min = ctgSizesKeys[0]
  result.auN = 0.0
  # calculate thresholds
  #for index in nIndexes:
  #  let quote = float(total) * float((100 - index) / 100)

  for ctgLen in ctgSizesKeys:

    let
      count = ctgSizes[ctgLen] 
      ctgLengths = (ctgLen * count)
   
    i += 1
    accum += ctgLengths
    auN += float( ctgLen * ctgLen / total);

    if (result.n25 == 0)  and (float(accum) >=  float( total)  * float((100 - 25) / 100) )  :
      result.n25 = ctgLen
    if (result.n50 == 0)  and (float(accum) >=  float( total)  * float((100 - 50) / 100) )  :
      result.n50 = ctgLen
    if (result.n75 == 0)  and (float(accum) >=  float( total)  * float((100 - 75) / 100) )  :
      result.n75 = ctgLen
    if (result.n90 == 0)  and (float(accum) >=  float( total)  * float((100 - 90) / 100) )  :
      result.n90 = ctgLen
  #[
    for index in nIndexes:
      if index in nArray:
        # was already calculated... skip
        continue
      let
        quote = float(total) * float((100 - index) / 100)
      if float(accum) >= quote:
        nArray[index] = ctgLen
        iArray[index] = i
  ]#

  result.auN = auN
  result.count = nseq

  result.avg   =float( total / nseq )
 





  
proc fastx_stats(argv: var seq[string]): int =
  let args = docopt("""
Usage: stats [options] [<inputfile> ...]

Options:
  -a, --abs-path         Print absolute paths
  -b, --basename         Print only filenames
  -n, --nice             Print nice terminal table
  --csv                  Separate with commas (default: tabs)
  -v, --verbose          Verbose output
  -h, --help             Show this help

  """, version=version(), argv=argv)

  verbose = args["--verbose"]

 
  let
    basename = args["--basename"]
    nice     = args["--nice"]

  var 
    files : seq[string]
    sep = "\t"
  

  if args["--csv"]:
    sep = ","
    
  if args["<inputfile>"].len() == 0:
    stderr.writeLine("Waiting for STDIN... [Ctrl-C to quit, type with --help for info].")
    files.add("-")
  else:
    for file in args["<inputfile>"]:
      files.add(file)
    
  
  let outputTable = newUnicodeTable()
  if nice:
    outputTable.separateRows = false
    outputTable.setHeaders(@["File", "#Seq", "Total bp","Avg", "N50", "N75", "N90", "Min", "Max"])
  else:
    echo "File", sep, "#Seq", sep, "Total bp","Avg", sep, "N50", sep, "N75", sep, "N90", sep, "Min", sep, "Max"

  for filename in files:
    var 
      stats = getFastxStats(filename)

    var rendername = if basename: $basename(filename)
      else: filename

    if nice:
      outputTable.addRow(@[$rendername, $stats.count, $stats.sum, stats.avg.formatFloat(ffDecimal, 1), $stats.n50,$stats.n75,$stats.n90,$stats.min, $stats.max])
    else:
      echo $rendername, sep, $stats.count, sep, $stats.sum, sep, stats.avg.formatFloat(ffDecimal, 1), sep, $stats.n50, sep, $stats.n75, sep, $stats.n90, $stats.min, sep, $stats.max
  if nice:
    outputTable.printTable()
  
 
