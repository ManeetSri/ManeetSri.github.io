// Generated from src/dsa/content/lessons/swift-strings/swift-char-digit-conversion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

print(Character(UnicodeScalar(97)))

let code: UInt8 = 99
print(Character(UnicodeScalar(code)))

let position = 2
print(Character(UnicodeScalar(UInt8(97 + position))))
