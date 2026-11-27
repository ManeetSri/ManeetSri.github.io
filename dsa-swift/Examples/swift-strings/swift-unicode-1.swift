// Generated from src/dsa/content/lessons/swift-strings/swift-unicode.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

for text in ["A", "é", "€", "😀"] {
    print(text, text.unicodeScalars.count, text.utf8.count)
}
