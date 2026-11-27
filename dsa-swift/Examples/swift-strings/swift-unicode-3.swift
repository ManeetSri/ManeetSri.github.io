// Generated from src/dsa/content/lessons/swift-strings/swift-unicode.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let samples = ["👍", "👍🏽", "🇯🇵", "👨‍👩‍👧‍👦"]
for emoji in samples {
    print(emoji, emoji.count, emoji.unicodeScalars.count, emoji.utf8.count)
}
