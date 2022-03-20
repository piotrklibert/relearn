import scala.io.Source

val l = Source.fromFile("script.txt").getLines().map(_.split("==")).map({
  case Array(x, y) => x -> y
  case Array(x) => x -> ""
}).toSeq

println(l(0))

// https://alvinalexander.com/scala/how-to-define-use-partial-functions-in-scala-syntax-examples/
// https://alvinalexander.com/scala/scala-match-case-expressions-syntax-examples/
// https://stackoverflow.com/questions/17965059/what-is-lifting-in-scala
