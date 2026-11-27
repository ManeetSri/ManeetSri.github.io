// Generated from src/dsa/content/lessons/swift-strings/swift-unicode.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let precomposed = "caf\u{E9}"
let decomposed = "cafe\u{301}"

print(precomposed, decomposed)
print(precomposed == decomposed)
print(precomposed.count, decomposed.count)
print(precomposed.unicodeScalars.count, decomposed.unicodeScalars.count)
print(precomposed.utf8.count, decomposed.utf8.count)
