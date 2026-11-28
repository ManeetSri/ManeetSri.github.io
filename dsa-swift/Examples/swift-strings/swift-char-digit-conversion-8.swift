// Generated from src/dsa/content/lessons/swift-strings/swift-char-digit-conversion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func nextLetter(_ ch: Character) -> Character {
    let position = Int(ch.asciiValue! - 97)
    let next = (position + 1) % 26
    return Character(UnicodeScalar(UInt8(97 + next)))
}

print(nextLetter("a"), nextLetter("y"), nextLetter("z"))
