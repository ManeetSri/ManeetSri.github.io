// Generated from src/dsa/content/lessons/swift-strings/swift-unicode.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let word = "naïve 👋🏾"
print(word.count)
print(word.unicodeScalars.count)
print(word.utf16.count)
print(word.utf8.count)
