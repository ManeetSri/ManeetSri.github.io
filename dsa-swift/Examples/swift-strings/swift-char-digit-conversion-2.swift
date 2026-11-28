// Generated from src/dsa/content/lessons/swift-strings/swift-char-digit-conversion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func digitSum(_ text: String) -> Int {
    var total = 0
    for ch in text {
        if let digit = ch.wholeNumberValue {
            total += digit
        }
    }
    return total
}

print(digitSum("a1b2c3"))
print(digitSum("2024"))
