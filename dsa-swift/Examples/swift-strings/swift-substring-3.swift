// Generated from src/dsa/content/lessons/swift-strings/swift-substring.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let words = "Swift strings are clever".split(separator: " ")
let word = words[1]

print(word.uppercased())
print(word.count)
print(word.hasPrefix("str"))
print(word == "strings")
print(Array(word.prefix(3)))
