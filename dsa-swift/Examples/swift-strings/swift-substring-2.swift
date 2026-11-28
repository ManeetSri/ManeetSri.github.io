// Generated from src/dsa/content/lessons/swift-strings/swift-substring.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let sentence = "Swift strings are clever"
let middle = sentence.dropFirst(6).prefix(7)

print(middle)
print(middle.startIndex == sentence.index(sentence.startIndex, offsetBy: 6))
print(sentence[middle.startIndex])
