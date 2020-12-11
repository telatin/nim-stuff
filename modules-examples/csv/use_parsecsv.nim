import parsecsv
from os import paramStr, paramCount
from streams import newFileStream

# Check that one parameter was provided
if paramCount() < 1:
  quit("Please specify 1 parameter: csvfile")

 
var
  csvFile: CsvParser
  i = 0

csvFile.open( paramStr(1) )
csvFile.readHeaderRow()

while csvFile.readRow():
  i += 1
  echo " +------------------------------------------[ ", i ," ]------ "
  for col in items(csvFile.headers):
    if len(col) > 1:
      echo  " | ", col, " -> ", csvFile.rowEntry(col)
csvFile.close()