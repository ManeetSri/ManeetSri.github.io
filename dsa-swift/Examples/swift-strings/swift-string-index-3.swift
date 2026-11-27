// Generated from src/dsa/content/lessons/swift-strings/swift-string-index.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let word = "swift"
if let far = word.index(word.startIndex, offsetBy: 10, limitedBy: word.endIndex) {
    print(word[far])
} else {
    print("too far")
}
