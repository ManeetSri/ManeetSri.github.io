// Generated from src/dsa/content/lessons/swift-strings/swift-split-trim.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let sentence = "  the quick   brown fox "
let words = sentence.split(separator: " ")
print(words)
print(words.count)
