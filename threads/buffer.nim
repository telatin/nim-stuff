import docopt
import os, parseutils, strutils


proc parse(line: string, domainCode, pageTitle: var string, countViews, totalSize: var int) =
  var i = 0
  domainCode.setLen(0)
  i.inc parseUntil(line, domainCode, {' '}, i) 
  i.inc
  pageTitle.setLen(0)
  i.inc parseUntil(line, pageTitle, {' '}, i) 
  i.inc
  countViews = 0
  i.inc parseInt(line, countViews, i)
  i.inc
  totalSize = 0
  i.inc parseInt(line, totalSize, i)


proc readPageCounts(filename: string, chunkSize = 1000) =
  var buffer = newString(chunkSize)
  var file = open(filename)
  var oldBufferLen = 0

  while not endOfFile(file):
    let reqSize = chunksize - oldBufferLen
    let readSize = file.readChars(buffer, oldBufferLen, reqSize) + oldBufferLen
    var chunkLen = readSize
    echo "== reqSize: ", reqSize
    echo "== readSize: ", readSize
    
    while chunkLen >= 0 and buffer[chunkLen - 1] notin NewLines: 
      chunkLen.dec

    oldBufferLen = readSize - chunkLen
    buffer[0 .. (oldBufferLen - 1)] = buffer[(readSize - oldBufferLen) .. ^1]
    echo ">",buffer


proc main()  =
  var args = commandLineParams()

  if len(args) < 1:
    echo "Missing first parameter (Wikipedia counts file)"
    quit(1)

  echo "Will try parsing: <", args[0], ">"
  readPageCounts(args[0])
 
when isMainModule:
  main()
