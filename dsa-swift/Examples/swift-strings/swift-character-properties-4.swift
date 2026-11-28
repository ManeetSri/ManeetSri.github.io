// Generated from src/dsa/content/lessons/swift-strings/swift-character-properties.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let letter: Character = "Q"
let lower = letter.lowercased()
print(lower, type(of: lower))

let lowerChar = Character(letter.lowercased())
print(lowerChar, type(of: lowerChar))
