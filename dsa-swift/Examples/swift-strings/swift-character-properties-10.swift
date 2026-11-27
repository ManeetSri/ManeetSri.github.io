// Generated from src/dsa/content/lessons/swift-strings/swift-character-properties.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let samples: [Character] = ["m", "M", "é"]
for ch in samples {
    print(ch, ("a"..."z").contains(ch), ch.isASCII && ch.isLetter)
}
