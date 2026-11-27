// Generated from src/dsa/content/lessons/strings-basic/str-naive-matching.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let text = "abracadabra"
print(text.contains("cad"))
print(text.ranges(of: "abra").map { text.distance(from: text.startIndex, to: $0.lowerBound) })
print("aaaa".ranges(of: "aa").count)
