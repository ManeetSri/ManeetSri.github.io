// Generated from src/dsa/content/lessons/swift-strings/swift-string-to-array.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func reversed(_ text: String) -> String {
    var chars = Array(text)
    var left = 0
    var right = chars.count - 1
    while left < right {
        chars.swapAt(left, right)
        left += 1
        right -= 1
    }
    return String(chars)
}

print(reversed("stressed"))
print(reversed("a"))
print(reversed("").isEmpty)
