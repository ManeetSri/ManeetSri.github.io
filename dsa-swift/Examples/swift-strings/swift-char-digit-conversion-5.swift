// Generated from src/dsa/content/lessons/swift-strings/swift-char-digit-conversion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func parse(_ text: String) -> Int {
    var value = 0
    for ch in text {
        value = value * 10 + ch.wholeNumberValue!
    }
    return value
}

print(parse("4096"))
