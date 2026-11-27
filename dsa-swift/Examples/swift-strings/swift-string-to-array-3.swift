// Generated from src/dsa/content/lessons/swift-strings/swift-string-to-array.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let chars = Array("abcdefg")
var windows: [String] = []
for start in 0...(chars.count - 3) {
    windows.append(String(chars[start..<start + 3]))
}
print(windows)
