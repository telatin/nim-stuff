import random
import os, parseutils, strutils, threadpool

type
  Stats = ref object
    domainCode: string
    pageTitle: string
    countViews: int
    totalSize: int

proc newStats(): Stats =
  Stats(domainCode: "", pageTitle: "", countViews: 0, totalSize: 0)



proc `$`(stats: Stats): string =
  "(domainCode: $#, pageTitle: $#, countViews: $#, totalSize: $#)" % [
    stats.domainCode, stats.pageTitle, $stats.countViews, $stats.totalSize 
  ]

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


proc parseChunk(chunk: string): Stats = 
  let randomNum = rand(10000)
  result = newStats()
  var domainCode = ""
  var pageTitle = ""
  var countViews = 0
  var totalSize = 0
  echo randomNum, " > ", chunk[0 .. 20]
  for line in splitLines(chunk):
    parse(line, domainCode, pageTitle, countViews, totalSize) 
    if domainCode == "en" and pageTitle != "Main_Page" and countViews > result.countViews:
      result = Stats(domainCode: domainCode, pageTitle: pageTitle, countViews: countViews, totalSize: totalSize)

#he readPageCounts procedure now includes a chunkSize parameter with a default value of 1_000_000. The underscores help readability and are ignored by Nim.
proc readPageCounts(filename: string, chunkSize = 1_000_000) = 
  # The open procedure is now used to open a file. It returns a File object that’s stored in the file variable
  var file = open(filename)
  # Defines a new responses sequence to hold the FlowVar 
  # objects that will be returned by spawn
  var responses = newSeq[FlowVar[Stats]]()
  # Defines a new buffer string of length equal to chunkSize. 
  # Fragments will be stored here
  var buffer = newString(chunkSize)
  # Defines a variable to store the length of the last buffer that wasn’t parsed
  var oldBufferLen = 0 

  # Loops until the full file is read
  while not endOfFile(file):
    # Calculates the number of characters that need to be read
    let reqSize = chunksize - oldBufferLen
    let readSize = file.readChars(buffer, oldBufferLen, reqSize) + oldBufferLen 
    var chunkLen = readSize
    while chunkLen >= 0 and buffer[chunkLen - 1] notin NewLines: 
      chunkLen.dec
    #Creates a new thread to execute the parseChunk procedure and passes a slice of the buffer that contains a fragment that can be parsed. 
    # Adds the FlowVar[string] returned by spawn to the list of responses.
    responses.add(spawn parseChunk(buffer[0 .. chunkLen-1])) 
    oldBufferLen = readSize - chunkLen 
    #Assigns the part of the fragment that wasn’t parsed to the beginning of buffer
    buffer[0 .. oldBufferLen-1] = buffer[readSize - oldBufferLen .. ^1]
  var mostPopular = newStats()
  for resp in responses: # Iterates through each response
    #Blocks the main thread until the response can be read and then saves the response value in the statistics variable
    let statistic = ^resp
    
    #Checks if the most popular page in a particular fragment is more popular than the one saved in the mostPopular variable. If it is, overwrites the mostPopular variable with it
    if statistic.countViews > mostPopular.countViews:
      mostPopular = statistic

  echo("Most popular is: ", $mostPopular) 
  file.close()

#[
proc readPageCountsSingle(filename: string) =
  for line in filename.lines:
    var domainCode = ""
    var pageTitle = ""
    var countViews = 0
    var totalSize = 0
    parse(line, domainCode, pageTitle, countViews, totalSize)
    echo("Title: ", pageTitle, " counts:", countViews)
]#

proc main()  =
  var args = commandLineParams()

  if len(args) < 1:
    echo "Missing first parameter (Wikipedia counts file)"
    quit(1)

  if len(args) >= 2:
    echo "Threads: ", args[1]
    setMaxPoolSize(parseInt(args[1]))
  echo "Will try parsing: <", args[0], ">"
  readPageCounts(args[0])
 
when isMainModule:
  main()
