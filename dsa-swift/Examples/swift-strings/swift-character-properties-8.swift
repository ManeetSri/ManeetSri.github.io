// Generated from src/dsa/content/lessons/swift-strings/swift-character-properties.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let letters: [Character] = ["a", "d", "z"]
for letter in letters {
    if let code = letter.asciiValue {
        print(letter, Int(code) - 97)
    }
}
