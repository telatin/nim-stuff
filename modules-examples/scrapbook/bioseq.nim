import nimbioseq, os, strutils

proc checkFastq(input: string, total = false, printseq = false) =
    if input != "":
      var c = 0
      for s in readSeqs(input):
        c += 1
        if s.sequence.len != s.quality.len:
          stderr.writeLine("Problem with " & s.id)
        if printseq:
          try:
            echo s.id
            echo s.to_fastq()
          except:
            stderr.writeLine("Arguments error: ", getCurrentExceptionMsg())
            quit(0)
      if total:
        echo "total: ", c

when isMainModule:
    import cligen;dispatch(checkFastq)
