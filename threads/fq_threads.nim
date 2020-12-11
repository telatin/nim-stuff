
import os, strutils, threadpool

 

 

proc parseChunk(chunk: string): int = 
  result = 0
  for c in chunk:
    if c == '\n':
      result += 1

    

#he readPageCounts procedure now includes a chunkSize parameter with a default value of 1_000_000. The underscores help readability and are ignored by Nim.
proc readPageCounts(filename: string, chunkSize = 1_000_000) = 
  var file = open(filename)
  # Defines a new responses sequence to hold the FlowVar 
  # objects that will be returned by spawn
  var responses = newSeq[FlowVar[int]]()
  # Defines a new buffer string of length equal to chunkSize. 
  # Fragments will be stored here
  var buffer = newString(chunkSize)

  # Defines a variable to store the length of the last buffer that wasn’t parsed
 
 
  while not endOfFile(file):
    let readBufferSize = file.readChars(buffer, 0, chunkSize)
    responses.add(spawn parseChunk(buffer[0 .. readBufferSize-1])) 




  var totalSeqs = 0

  for threadResponse in responses: # Iterates through each response
    #Blocks the main thread until the response can be read and then saves the response value in the statistics variable
    let threadPartialCount = ^threadResponse
    totalSeqs += threadPartialCount
  
  var count = int(totalSeqs / 4)
  echo(filename, "\t", $count) 
 
  file.close()


proc main()  =
  var args = commandLineParams()

  if len(args) < 1:
    stderr.writeLine "Missing first parameter: FASTQ_Filename"
    quit(1)

  if len(args) >= 2:
    stderr.writeLine "Max threads: ", args[1]
    setMaxPoolSize(parseInt(args[1]))
  if fileExists(args[0]):
    readPageCounts(args[0])
  else:
    stderr.writeLine args[0], " not found."
    quit(1)

when isMainModule:
  main()
