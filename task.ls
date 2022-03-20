fs = require "fs"
{
  find-indices, pairs-to-obj, first, map, lines, filter, reject
} = require "prelude-ls"

readLines = fs.openSync >> fs.readFileSync(_, "utf8") >> lines
split-on-eq = (.split /\=\=?/)

txt =
  readLines("script.txt")
  |> reject (.startsWith "\#")
  |> reject (== "")

commit-versions =
  txt |> filter ("@" in) |> map (.split "@") >> first >> (.trim!)

versions = txt |> map split-on-eq |> reject first >> ("@" in) |> pairs-to-obj

toml = readLines("script.toml") |> reject (== "") |> reject (.startsWith "\#")
[_, n, m, e] = toml |> find-indices (/^\[.*\]/ ==)

rm_versions = map split-on-eq >> first >> (.trim!)

toml-deps = toml[n+1 to m-1] |> rm_versions
toml-dev-deps = toml[m+1 to e-1] |> rm_versions

dev-deps =
  toml-dev-deps
  |> filter (versions.)
  |> map (-> [it, versions[it]] )
  |> pairs-to-obj

deps =
  toml-deps
  |> filter (versions.)
  |> map (-> [it, versions[it]] )
  |> pairs-to-obj

for k, v of (deps <<< dev-deps)
  console.log "#k==#v"
console.log "\n"
for k, v of (deps <<< dev-deps)
  console.log "#k==#v"

## console.log versions
## console.log toml-dev-deps
## console.log toml-deps
## http://www.preludels.com/#find-indices
## https://livescript.net/#literals
## https://nodejs.org/api/fs.html#fsreadfilesyncpath-options
