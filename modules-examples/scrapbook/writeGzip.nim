import zip/gzipfiles
let text = "ciao ciao ciao ciao"
let w = newGzFileStream("files/gzipfiletest.data.gz", fmWrite)
let chunk_size = 32
var num_bytes = text.len
var idx = 0
while true:
  w.writeData(text[idx].unsafeAddr, min(num_bytes, chunk_size))
  if num_bytes < chunk_size:
    break
  dec(num_bytes, chunk_size)
  inc(idx, chunk_size)
w.close()
