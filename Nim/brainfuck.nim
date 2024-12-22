# Author: 月波 清火 (tukinami seika)
# License: MIT

import system
import os
import std/unicode as unicode
import ./brainfuck_lib.nim as bf

proc print_help() =
  echo """
usage:
brainfuck.exe <SOURCE>
"""

proc main(raw_source: string) =
  let
    body = unicode.toRunes(raw_source)
    parentheses = bf.build_parentheses(body)
  var
    memory: Memory = Memory()
    source: Source = Source(body: body, parentheses: parentheses)
    output: Output = Output()
  case bf.whole(memory, source, output)
  of rSuccess:
    echo "result: "
    echo output.body
  else:
    echo "Something wrong..."

if isMainModule:
  if paramCount() == 0:
    print_help()
    system.programResult = 0
  else:
    main($os.commandLineParams()[0])
    system.programResult = 0
