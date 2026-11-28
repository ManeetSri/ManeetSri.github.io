// Generated from src/dsa/content/lessons/swift-strings/swift-string-index.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let text = "héllo👋"
var i = text.startIndex
while i < text.endIndex {
    print(text[i], terminator: " ")
    i = text.index(after: i)
}
print()
