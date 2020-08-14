import zip/zipfiles
import streams
var
  f= "file.zip"
  z: ZipArchive

if not z.open(f):
  echo "Opening zip failed: ", f
  quit(1)

echo "ZIP :", z

for i in z.walkFiles:
  echo "file: ", i
  var 
    fileStringStream = newStringStream()
    line: string
  #z.extractFile(i, "/tmp/test_extraction_of_" & i)
  z.extractFile(i, fileStringStream)
  echo "? ", fileStringStream.type
  while fileStringStream.readLine(line):
    echo "> ",line

