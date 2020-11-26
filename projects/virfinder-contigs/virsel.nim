import parsecsv
import docopt
import nimbioseq
import os, strutils, tables

let doc = """
fu-virsel: Seqfu Virfinder Selector

A program that will take as input a FASTA file with contigs and the 
CSV file produced by virfinder on the same contigs and will
print the contigs where p-value <= MAX and score >= MINSCORE

Usage:
  fu-virsel [options] -c contigs.fasta -v virfinder.csv 
  fu-virsel --help
  fu-virsel --version

Options:
  -c, --contigs FASTA     Input FASTA file with contigs
  -v, --virfinder CSV     Virfinder output file in CSV format
  -p, --max-pvalue FLOAT  Maximum p-value in VirFinder prediction [default: 0.05]
  -s, --min-score FLOAT   Minimum score in VirFinder prediction [default: 0.7]
  -l, --min-ctg-len INT   Minimum contig length [default: 100]
  --annotate              Add virfinder score and pvalue to the printed contigs
  --verbose               Print more informations to STDERR
  --version               Prints version
  --help                  Prints this help page
"""

type
  virfinderRecord = tuple[name: string, score, pvalue: float, length: int]

proc main(args: seq[string]) =
  let args = docopt(doc, version = "fu-virsel 0.7.0")

  # Print required parameters to STDERR
  if args["--contigs"] and args["--virfinder"]:
    #TODO: Check file exists
    stderr.writeLine "Assembly file:      ", $args["--contigs"]
    stderr.writeLine "Virfinder output:   ", $args["--virfinder"]
    stderr.writeLine "Maximum p-value:    ", $args["--max-pvalue"]
    stderr.writeLine "Minimum score:      ", $args["--min-score"]
    stderr.writeLine "Minimum contig len: ", $args["--min-ctg-len"]
    stderr.writeLine ""

  # Check parameters:
  try:
    discard parseFloat($args["--min-score"])
    discard parseFloat($args["--max-pvalue"])
    discard parseInt($args["--min-ctg-len"])
  except Exception as e:
    stderr.writeLine "PARAMETERS ERROR: ", e.msg
    quit(1)

  # Load CSV
  var
    csvFile: CsvParser
    vfTable = initTable[string, virfinderRecord]()
  try:
    csvFile.open( $args["--virfinder"] )
    csvFile.readHeaderRow()
  except Exception as e:
    stderr.writeLine "FATAL ERROR: Unable to load input CSV file <", $args["--virfinder"], ">:\n  ", e.msg
    quit(1)

  #  Parse CSV file line by line (actually, record by record)
  while csvFile.readRow():
    var
      vf: virfinderRecord

    # Populate a record with the required columns from the Virsorter output
    try:
      vf = (name: csvFile.rowEntry("name"),
            score: parseFloat(csvFile.rowEntry("score")), 
            pvalue: parseFloat(csvFile.rowEntry("pvalue")), 
            length: parseInt(csvFile.rowEntry("length")))
    except Exception as e:
      stderr.writeLine("Unable to parse CSV: columns 'length', 'pvalue', and 'score' are required.\n", e.msg)
      quit(2)

    # Use as key of the table the first part of the contig name (splitting on space and tabs)
    vfTable[csvFile.rowEntry("name").split(' ')[0].split('\t')[0]] = vf

  if args["--verbose"]:
    stderr.writeLine "Parsed CSV: ", len(vfTable), " records"

  # Parse FASTA
  try:
    for s in readSeqs($args["--contigs"]):
      # Record: (id: "k141_2358", description: "flag=1 multi=7.0000 len=465", quality: "", sequence: "AGTCT...")
      if s.id in vfTable:
        try:
          if vfTable[s.id].length  >=   parseInt($args["--min-ctg-len"]) and
            vfTable[s.id].score   >= parseFloat($args["--min-score"]) and
            vfTable[s.id].pvalue  <= parseFloat($args["--max-pvalue"]):
            let annotation = if args["--annotate"]: " score=" & $vfTable[s.id].score & ";pvalue=" & $vfTable[s.id].pvalue
                             else: ""
            echo '>', s.id, annotation
            echo s.sequence
          else:
            if args["--verbose"]:
              stderr.writeLine("Discarding ", s.id, ": ", vfTable[s.id])
        except Exception as e:
          stderr.writeLine "ERROR: Parsing ", vfTable[s.id],": ", e.msg
      else:
        stderr.writeLine s.id, " not found in VirSorter output. Skipping."
  except Exception as e:
    stderr.writeLine "FATAL ERROR: Malformed FASTA file:\n  ", e.msg
    quit(1)

when isMainModule:
  main(commandLineParams())
