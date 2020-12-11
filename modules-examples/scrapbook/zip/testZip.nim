import zip/zipfiles
import strutils
import streams

var
  f= "rep-seqs.qza"
  z: ZipArchive



proc readFileFromZip(zipFile, FileName: string): string =
  var 
    z: ZipArchive
    stream: PZipFileStream
    line: string
  try:
    discard z.open(f)
    stream = z.getStream(FileName)
    while stream.readLine(line):
      result &= line & "\n"
  except Exception as e:
    stderr.writeLine("ERROR: Unable to open ", zipFile, "\n", e.msg)
    discard

proc getID(zipFile: string): string =
  var z: ZipArchive
  if not z.open(f):
    return ""
  else:
    for file in z.walkFiles:
      let parts = file.split('/')
      let verFile = readFileFromZip(zipFile, parts[0] & "/VERSION")
      if verFile[0 .. 4] == "QIIME":
        return parts[0]
      else:
        return ""


if not z.open(f):
  echo "Opening zip failed: ", f
  quit(1)

echo getID(f)