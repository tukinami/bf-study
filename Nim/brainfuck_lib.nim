# Author: 月波 清火 (tukinami seika)
# License: MIT

import std/unicode as unicode

const
  MEMORY_LEN: int = 255

type
  Memory* = ref object
    body*: seq[uint8] = newSeq[uint8](MEMORY_LEN)
    index*: int = 0
  Paren* = tuple[i_open: int, i_close: int]
  Parentheses* = seq[Paren]
  Source* = ref object
    body*: seq[unicode.Rune]
    parentheses*: Parentheses = @[]
    index*: int = 0
  Output* = ref object
    body*: string = ""
  EvalResult* = enum
    rContinue, rFailed, rSuccess

proc search_parentheses*(parentheses: Parentheses, f: proc(p: Paren, i: int): bool, index: int): Paren =
  for elem in parentheses:
    if f(elem, index):
      return elem
    else: discard

  return (-1, -1)

proc has_open_index(p: Paren, i: int): bool =
  p.i_open == i

proc has_close_index(p: Paren, i: int): bool =
  p.i_close == i

proc search_paren_index_when_open*(parentheses: Parentheses, index: int): int =
  search_parentheses(parentheses, has_open_index, index).i_close

proc search_paren_index_when_close*(parentheses: Parentheses, index: int): int =
  search_parentheses(parentheses, has_close_index, index).i_open

proc step*(memory: Memory, source: Source, output: Output): EvalResult =
  assert(source.body.len > source.index)
  assert(memory.body.len > memory.index)

  case source.body[source.index]
  of '+'.Rune:
    memory.body[memory.index] += 1
  of '-'.Rune:
    memory.body[memory.index] -= 1
  of '>'.Rune:
    memory.index += 1
  of '<'.Rune:
    memory.index -= 1
  of '['.Rune:
    if memory.body[memory.index] == 0:
      let temp_i = search_paren_index_when_open(source.parentheses, source.index)
      if temp_i < 0:
        return rFailed
      else:
        source.index = temp_i
    else: discard
  of ']'.Rune:
    if memory.body[memory.index] != 0:
      let temp_i = search_paren_index_when_close(source.parentheses, source.index)
      if temp_i < 0:
        return rFailed
      else:
        source.index = temp_i
    else: discard
  of '.'.Rune:
    let value = memory.body[memory.index]
    output.body &= char(value)
  else: discard

  source.index += 1
  if source.index < source.body.len:
    return rContinue
  else:
    return rSuccess

proc whole*(memory: Memory, source: Source, output: Output): EvalResult =
  var res = rContinue

  while true:
    res = step(memory, source, output)
    if res == rContinue:
      continue
    else:
      break
  return res

proc build_parentheses*(source: seq[unicode.Rune]): Parentheses =
  var
    stack_open: seq[int] = @[]
    res: Parentheses = @[]

  for i, e in source:
    case e
    of '['.Rune:
      stack_open.add(i)
    of ']'.Rune:
      if stack_open.len > 0:
        let
          id_open = pop(stack_open)
        res.add((i_open: id_open, i_close: i))
      else:
        return @[]
    else:
      discard

  if stack_open.len > 0:
    return @[]
  else:
    return res
