// Generated from src/dsa/content/lessons/swift-strings/swift-string-index.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let word = "swift"
let fourth = word.index(word.startIndex, offsetBy: 3)
print(word[fourth])

let secondLast = word.index(word.endIndex, offsetBy: -2)
print(word[secondLast])
