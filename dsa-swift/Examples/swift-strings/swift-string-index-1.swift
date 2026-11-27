// Generated from src/dsa/content/lessons/swift-strings/swift-string-index.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let word = "swift"

let first = word[word.startIndex]
print(first)

let second = word.index(after: word.startIndex)
print(word[second])

let last = word.index(before: word.endIndex)
print(word[last])
