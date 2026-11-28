// Generated from src/dsa/content/lessons/swift-strings/swift-building-strings.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

print(String(repeating: "=", count: 12))
print(String(repeating: "ab", count: 3))

let done = 7
let total = 10
let bar = "[" + String(repeating: "#", count: done) + String(repeating: ".", count: total - done) + "]"
print(bar)
