import std/strutils

for l in readFile("script.txt").splitLines():
  echo l.split("==")

# https://nim-lang.org/docs/manual.html#macros-for-loop-macro
# https://nim-lang.org/docs/theindex.html
# https://nim-lang.org/docs/strutils.html#splitLines%2Cstring
# https://nim-lang.org/docs/io.html#readLines%2Cstring%2CNatural
