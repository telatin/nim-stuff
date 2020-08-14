
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


proc parseChunk(batch: seq[string]): Stats = 

  result = newStats()
  var domainCode = ""
  var pageTitle = ""
  var countViews = 0
  var totalSize = 0

  for i in batch:
    parse(i, domainCode, pageTitle, countViews, totalSize) 
    if domainCode == "en" and pageTitle != "Main_Page" and countViews > result.countViews:
      result = Stats(domainCode: domainCode, pageTitle: pageTitle, countViews: countViews, totalSize: totalSize)

#he readPageCounts procedure now includes a chunkSize parameter with a default value of 1_000_000. The underscores help readability and are ignored by Nim.
proc readPageCounts(filename: string, lines = 1000) = 
  var file = open(filename)
  # Defines a new responses sequence to hold the FlowVar 
  # objects that will be returned by spawn
  var responses = newSeq[FlowVar[Stats]]()

  var c = 0
  var batch =  newSeq[string](lines)
  for line in file.lines():       
    if c < 1000:
      batch.add(line)
      c += 1
    else:
      responses.add(spawn parseChunk(batch)) 
      c = 0
      batch.setLen(0)
      batch.add(line)

        
  var mostPopular = newStats()
  for resp in responses: # Iterates through each response
    #Blocks the main thread until the response can be read and then saves the response value in the statistics variable
    let statistic = ^resp
    
    #Checks if the most popular page in a particular fragment is more popular than the one saved in the mostPopular variable. If it is, overwrites the mostPopular variable with it
    if statistic.countViews > mostPopular.countViews:
      mostPopular = statistic

  echo("Most popular is: ", $mostPopular) 
  file.close()


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
