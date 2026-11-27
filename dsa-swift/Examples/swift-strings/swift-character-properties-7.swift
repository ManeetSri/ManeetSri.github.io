// Generated from src/dsa/content/lessons/swift-strings/swift-character-properties.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let samples: [Character] = ["a", "b", "z", "A", "Z", "0", "9", "é"]
for ch in samples {
    if let code = ch.asciiValue {
        print(ch, code)
    } else {
        print(ch, "no ASCII value")
    }
}
