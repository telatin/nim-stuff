import os
import sequtils
import strutils
import tables
import algorithm
import docopt
import kexpr

# Suite Version
import ./version

# Subprograms
include ./fastq_interleave
include ./fastq_deinterleave
include ./fastx_derep


var progs = {
       "ilv": fastq_interleave,
       "interleave": fastq_interleave,
       "dei": fastq_deinterleave,
       "deinterleave": fastq_deinterleave,  
       "derep": fastx_derep,

 
 }.toTable

proc main() =

  var helps = {"interleave [ilv]":  "interleave FASTQ pair ends",
               "deinterleave [dei]": "deinterleave FASTQ",
               "derep": "dereplicate FASTA/FASTQ files",
               }.toTable


  var args = commandLineParams()
  if len(args) < 1 or not progs.contains(args[0]):
    var hkeys = toSeq(keys(helps))
    sort(hkeys, proc(a, b: string): int =
      if a < b: return -1
      else: return 1
      )
    echo format("\nSeqFU programs.\nversion: $#\n", version())

    for k in hkeys:
      echo format("	• $1: $2", k & repeat(" ", 20 - len(k)), helps[k])
    echo ""
  else:
    var p = args[0]; args.delete(0)
    quit(progs[p](args))

when isMainModule:
  main()
