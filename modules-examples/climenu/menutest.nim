import cli_menu
import os

proc submenuA =
  echo "HELLO"

proc submenuB =
  echo "HELLO this is B"

import os
# getUserInput(title,prompt,error: string, check: proc(x: string):bool)
let input = getUserInput("Select a file to hide.","Filename","not a valid file",existsFile)
