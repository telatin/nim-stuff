import terminal
import strutils 

erasescreen()
echo terminalWidth(), " x ", terminalHeight()

# Sometimes knowing the terminal width in chars can be handy
echo "|<" , repeat("-", terminalWidth() - 4) , ">|"

setForegroundColor(fgRed)
echo "  Roses are red "

setForegroundColor(fgBlue)
echo "    Marbles are blue"
stdout.resetAttributes()

#[
Style = enum
  styleBright = 1,              ## bright text
  styleDim,                   ## dim text
  styleItalic,                ## italic (or reverse on terminals not supporting)
  styleUnderscore,            ## underscored text
  styleBlink,                 ## blinking/bold text
  styleBlinkRapid,            ## rapid blinking/bold text (not widely supported)
  styleReverse,               ## reverse
  styleHidden,                ## hidden text
  styleStrikethrough          ## strikethrough
]#
writeStyled("  If you need colors\n",{styleDim})


writeStyled("    I'll be with you\n",{styleBright})

stdout.resetAttributes()
echo "|<" , repeat("-", terminalWidth() - 4) , ">|"