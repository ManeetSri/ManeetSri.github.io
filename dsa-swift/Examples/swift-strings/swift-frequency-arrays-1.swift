// Generated from src/dsa/content/lessons/swift-strings/swift-frequency-arrays.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let word = "banana"
var counts = [Int](repeating: 0, count: 26)

for ch in word {
    let slot = Int(ch.asciiValue! - 97)
    counts[slot] += 1
}

print(counts[0], counts[1], counts[13], counts[25])
