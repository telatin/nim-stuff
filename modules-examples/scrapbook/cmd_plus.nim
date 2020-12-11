import osproc
import strutils

let (output, status) = execCmdEx("whoami")

echo " *** Output: ", output, " *** Status: ", status

for line in output.split("\n"):
  echo ":" ,line


let (outputE, statusE) = execCmdEx("ls notfound")

echo " *** Output: ", outputE, " *** Status: ", statusE

for line in outputE.split("\n"):
  echo ":" ,line
