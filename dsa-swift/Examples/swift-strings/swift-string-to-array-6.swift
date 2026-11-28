// Generated from src/dsa/content/lessons/swift-strings/swift-string-to-array.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let word = "héllo"
print(Array(word).count, Array(word.utf8).count)
print(String(Array(word).reversed()))
print(String(decoding: Array(word.utf8).reversed(), as: UTF8.self))
