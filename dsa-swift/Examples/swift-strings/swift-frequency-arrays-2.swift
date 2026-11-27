// Generated from src/dsa/content/lessons/swift-strings/swift-frequency-arrays.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let word = "banana"
var counts = [Int](repeating: 0, count: 26)
for ch in word {
    counts[Int(ch.asciiValue! - 97)] += 1
}

for slot in 0..<26 where counts[slot] > 0 {
    let letter = Character(UnicodeScalar(UInt8(97 + slot)))
    print(letter, counts[slot])
}
