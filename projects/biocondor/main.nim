import os
import sequtils
import strutils
import tables
import algorithm
import docopt

# Suite Version and common tools
import ./pkg_utils

# Subprograms
include ./modules/update
include ./modules/build_cache

var progs = {
       "update"       : mod_update,
       "build_cache"  : mod_build_cache,
}.toTable

proc main() =

  var
    helps = {  "update"            : "download new cache",
               "build_cache"       : "build cache from scratch (not recommended)",
               "search"            : "search for package by keywords",
               }.toTable


  var args = commandLineParams()
  if len(args) < 1 or not progs.contains(args[0]):
    # no first argument: print help
    var
      subprograms = toSeq(keys(helps))

    sort(subprograms, proc(a, b: string): int =
      if a < b: return -1
      else: return 1
      )
    echo format("BioCondor - Fast bioconda search tool\nversion: $#\n", version())

    for progName in subprograms:
      echo format("	• $1: $2", progName & repeat(" ", 20 - len(progName)), helps[progName])
    echo ""

      #echo format("	• \e[01;33m$1\e[00m: $2", k & repeat(" ", 20 - len(k)), helps[k])
    echo "\nAdd --help after each command to print usage"

  else:
    var p = args[0]; args.delete(0)
    quit(progs[p](args))

when isMainModule:
  main()
