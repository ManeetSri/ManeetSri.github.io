// Generated from src/dsa/content/lessons/swift-strings/swift-building-strings.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var chars: [Character] = []
for ch in "hello" {
    chars.append(ch)
    chars.append("-")
}
chars.removeLast()
print(String(chars))
