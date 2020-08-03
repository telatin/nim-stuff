import os
import sequtils
import strutils
import tables
import algorithm
import docopt

# Suite Version
import ./version

# Subprograms
include ./fastq_interleave
include ./fastq_deinterleave
include ./fastx_derep
include ./fastx_count

var progs = {
       "ilv": fastq_interleave,
       "interleave": fastq_interleave,
       "dei": fastq_deinterleave,
       "deinterleave": fastq_deinterleave,  
       "derep": fastx_derep,
       "der": fastx_derep,
       "cnt": fastx_count,
       "count": fastx_count, 
}.toTable

proc main() =

  var helps = {"interleave [ilv]":  "interleave FASTQ pair ends",
               "deinterleave [dei]": "deinterleave FASTQ",
               "derep [der]": "dereplicate FASTA/FASTQ files",
               "count [cnt]": "count FASTA/FASTQ reads, pair-end aware" 
               }.toTable


  var args = commandLineParams()
  if len(args) < 1 or not progs.contains(args[0]):
    var hkeys = toSeq(keys(helps))
    sort(hkeys, proc(a, b: string): int =
      if a < b: return -1
      else: return 1
      )
    echo format("SeqFU programs.\nversion: $#\n", version())

    for k in hkeys:
      echo format("	• $1: $2", k & repeat(" ", 20 - len(k)), helps[k])
      #echo format("	• \e[01;33m$1\e[00m: $2", k & repeat(" ", 20 - len(k)), helps[k])
    echo "\nAdd --help after each command to print usage"
  else:
    var p = args[0]; args.delete(0)
    quit(progs[p](args))

when isMainModule:
  main()
