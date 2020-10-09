

proc wc(inputfile: string) =
  var
    c = 0

  try:
    let f = open(inputfile)
    defer: f.close()
    for line in lines(f):
      c += 1
    echo c
  except:
    stderr.writeLine("File not found: ", inputfile)

when isMainModule: import cligen;dispatch(wc)
