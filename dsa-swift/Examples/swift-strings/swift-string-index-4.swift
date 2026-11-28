// Generated from src/dsa/content/lessons/swift-strings/swift-string-index.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let word = "swift"
let second = word.index(after: word.startIndex)
let last = word.index(before: word.endIndex)

print(word[second..<last])
print(word[...second])
print(word[last...])
