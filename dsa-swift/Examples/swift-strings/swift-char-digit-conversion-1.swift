// Generated from src/dsa/content/lessons/swift-strings/swift-char-digit-conversion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let seven: Character = "7"

print(seven.wholeNumberValue ?? -1)
print(Int(String(seven)) ?? -1)
print(Int(seven.asciiValue! - 48))

let letter: Character = "x"
print(letter.wholeNumberValue ?? -1)
