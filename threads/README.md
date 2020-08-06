# Threads

Parser multithreads from _Nim in action_ by _Dominik Picheta_.

* `get_data.sh` will download the required input file from Wikipedia (pageCounts)
* `threads.nim` requires as first argument the _pageCounts_ input file and optionally the number of threads.

**NOTE**: Some bits of syntax seemed incompatible with Nim 1.2.4:
````
buffer[0 .. <oldBufferLen] = buffer[readSize - oldBufferLen .. ^1]
#   this----^
```
