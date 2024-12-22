# Author: 月波 清火 (tukinami seika)
# License: MIT

import std/unittest
import std/unicode as unicode
import ./brainfuck_lib.nim as bf

suite "search_parentheses":
  test "success when find value: open":
    proc testfunc(p: Paren, i: int): bool =
      p.i_open == i
    let
      testcase: Parentheses = @[(1, 2), (0, 3)]
      res = bf.search_parentheses(testcase, testfunc, 0)
      ex: Paren = (0, 3)
    check(res == ex)

  test "success when find value: close":
    proc testfunc(p: Paren, i: int): bool =
      p.i_close == i
    let
      testcase: Parentheses = @[(1, 2), (0, 3)]
      res = bf.search_parentheses(testcase, testfunc, 2)
      ex: Paren = (1, 2)
    check(res == ex)

  test "failed when no value: open":
    proc testfunc(p: Paren, i: int): bool =
      p.i_open == i
    let
      testcase: Parentheses = @[(1, 2), (0, 3)]
      res = bf.search_parentheses(testcase, testfunc, 4)
      ex: Paren = (-1, -1)
    check(res == ex)

  test "failed when no value: close":
    proc testfunc(p: Paren, i: int): bool =
      p.i_close == i
    let
      testcase: Parentheses = @[(1, 2), (0, 3)]
      res = bf.search_parentheses(testcase, testfunc, 4)
      ex: Paren = (-1, -1)
    check(res == ex)

suite "search_paren_index_when_open":
  test "success when find value":
    let
      testcase: Parentheses = @[(1, 2), (0, 3)]
      res = bf.search_paren_index_when_open(testcase, 0)
      ex = 3
    check(res == ex)

  test "failed when no value":
    let
      testcase: Parentheses = @[(1, 2), (0, 3)]
      res = bf.search_paren_index_when_open(testcase, 4)
      ex = -1
    check(res == ex)

suite "search_paren_index_when_close":
  test "success when find value":
    let
      testcase: Parentheses = @[(1, 2), (0, 3)]
      res = bf.search_paren_index_when_close(testcase, 3)
      ex = 0
    check(res == ex)

  test "failed when no value":
    let
      testcase: Parentheses = @[(1, 2), (0, 3)]
      res = bf.search_paren_index_when_close(testcase, 4)
      ex = -1
    check(res == ex)

suite "step":
  setup:
    var
      memory: Memory = Memory()
      output: Output = Output()

  test "[: with 0 jump":
    let
      testcase = unicode.toRunes("[[]]+")
      parentheses = bf.build_parentheses(testcase)
    var
      source: Source = Source(body: testcase, parentheses: parentheses)
    memory.body[memory.index] = 0
    check(bf.step(memory, source, output) == rContinue)
    check(source.index == 4)

  test "[: with 0 jump end":
    let
      testcase = unicode.toRunes("[[]]")
      parentheses = bf.build_parentheses(testcase)
    var
      source: Source = Source(body: testcase, parentheses: parentheses)
    memory.body[memory.index] = 0
    check(bf.step(memory, source, output) == rSuccess)
    check(source.index == 4)

  test "[: with 1 continue":
    let
      testcase = unicode.toRunes("[[]]+")
      parentheses = bf.build_parentheses(testcase)
    var
      source: Source = Source(body: testcase, parentheses: parentheses)
    memory.body[memory.index] = 1
    check(bf.step(memory, source, output) == rContinue)
    check(source.index == 1)

  test "[: with 0 invalid pair":
    let
      testcase = unicode.toRunes("[[")
      parentheses = bf.build_parentheses(testcase)
    var
      source: Source = Source(body: testcase, parentheses: parentheses)
    memory.body[memory.index] = 0
    check(bf.step(memory, source, output) == rFailed)

  test "]: with 1 jump":
    let
      testcase = unicode.toRunes("[[]]+")
      parentheses = bf.build_parentheses(testcase)
    var
      source: Source = Source(body: testcase, parentheses: parentheses)
    source.index = 3
    memory.body[memory.index] = 1
    check(bf.step(memory, source, output) == rContinue)
    check(source.index == 1)

  test "]: with 1 invalid pair":
    let
      testcase = unicode.toRunes("++]]+")
      parentheses = bf.build_parentheses(testcase)
    var
      source: Source = Source(body: testcase, parentheses: parentheses)
    source.index = 3
    memory.body[memory.index] = 1
    check(bf.step(memory, source, output) == rFailed)

  test "]: with 0 continue":
    let
      testcase = unicode.toRunes("[[]]+")
      parentheses = bf.build_parentheses(testcase)
    var
      source: Source = Source(body: testcase, parentheses: parentheses)
    source.index = 3
    memory.body[memory.index] = 0
    check(bf.step(memory, source, output) == rContinue)
    check(source.index == 4)

  test "]: with 0 continue end":
    let
      testcase = unicode.toRunes("[[]]")
      parentheses = bf.build_parentheses(testcase)
    var
      source: Source = Source(body: testcase, parentheses: parentheses)
    source.index = 3
    memory.body[memory.index] = 0
    check(bf.step(memory, source, output) == rSuccess)
    check(source.index == 4)

  test "+: checking value":
    let
      testcase = unicode.toRunes("+[[]]")
      parentheses = bf.build_parentheses(testcase)
    var
      source: Source = Source(body: testcase, parentheses: parentheses)
    check(bf.step(memory, source, output) == rContinue)
    check(memory.body[memory.index] == 1)
    check(memory.index == 0)
    check(source.index == 1)

  test "+: checking value":
    let
      testcase = unicode.toRunes("-[[]]")
      parentheses = bf.build_parentheses(testcase)
    var
      source: Source = Source(body: testcase, parentheses: parentheses)
    memory.body[memory.index] = 2
    check(bf.step(memory, source, output) == rContinue)
    check(memory.body[memory.index] == 1)
    check(memory.index == 0)
    check(source.index == 1)

  test ">: checking value":
    let
      testcase = unicode.toRunes(">[[]]")
      parentheses = bf.build_parentheses(testcase)
    var
      source: Source = Source(body: testcase, parentheses: parentheses)
    check(bf.step(memory, source, output) == rContinue)
    check(memory.index == 1)
    check(source.index == 1)

  test "<: checking value":
    let
      testcase = unicode.toRunes("<[[]]")
      parentheses = bf.build_parentheses(testcase)
    var
      source: Source = Source(body: testcase, parentheses: parentheses)
    memory.index = 2
    check(bf.step(memory, source, output) == rContinue)
    check(memory.index == 1)
    check(source.index == 1)

  test ".: checking value":
    let
      testcase = unicode.toRunes(".[[]]")
      parentheses = bf.build_parentheses(testcase)
    var
      source: Source = Source(body: testcase, parentheses: parentheses)
    memory.body[memory.index] = 65 # A
    check(bf.step(memory, source, output) == rContinue)
    check(output.body == "A")
    check(memory.index == 0)
    check(source.index == 1)

suite "whole":
  setup:
    var
      memory: Memory = Memory()
      output: Output = Output()

  test "+-><":
    let
      testcase = unicode.toRunes("+++++--->>><<")
      parentheses = bf.build_parentheses(testcase)
    var
      source: Source = Source(body: testcase, parentheses: parentheses)
    check(bf.whole(memory, source, output) == rSuccess)
    check(memory.body[0] == 2)
    check(memory.index == 1)
    check(source.index == testcase.len)
    check(output.body == "")

  test "[]":
    let
      testcase = unicode.toRunes("++++[>+++<-]")
      parentheses = bf.build_parentheses(testcase)
    var
      source: Source = Source(body: testcase, parentheses: parentheses)
    check(bf.whole(memory, source, output) == rSuccess)
    check(memory.body[0] == 0)
    check(memory.body[1] == 12)
    check(memory.index == 0)
    check(source.index == testcase.len)
    check(output.body == "")

  test "[].":
    let
      testcase = unicode.toRunes("+++++++[>++++++<-]>...")
      parentheses = bf.build_parentheses(testcase)
    var
      source: Source = Source(body: testcase, parentheses: parentheses)
    check(bf.whole(memory, source, output) == rSuccess)
    check(memory.body[0] == 0)
    check(memory.body[1] == 42)
    check(memory.index == 1)
    check(source.index == testcase.len)
    check(output.body == "***")

  test "[]: failed":
    let
      testcase = unicode.toRunes("[[")
      parentheses = bf.build_parentheses(testcase)
    var
      source: Source = Source(body: testcase, parentheses: parentheses)
    check(bf.whole(memory, source, output) == rFailed)

suite "build_parentheses":
  test "success when valid runes":
    let
      testcase = unicode.toRunes("[[]]")
      res = bf.build_parentheses(testcase)
      ex = @[(i_open: 1, i_close: 2),(i_open: 0, i_close: 3)]
    check(res == ex)

  test "failed when invalid runes: too many open":
    let
      testcase = unicode.toRunes("[[]")
      res = bf.build_parentheses(testcase)
      ex: Parentheses = @[]
    check(res == ex)

  test "failed when invalid runes: too many close":
    let
      testcase = unicode.toRunes("[]]")
      res = bf.build_parentheses(testcase)
      ex: Parentheses = @[]
    check(res == ex)
