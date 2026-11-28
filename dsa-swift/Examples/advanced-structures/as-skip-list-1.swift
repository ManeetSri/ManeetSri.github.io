// Generated from src/dsa/content/lessons/advanced-structures/as-skip-list.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A seeded generator (SplitMix64): random-looking numbers, but the same ones every run
struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

// Flip a coin until it comes up tails: the number of flips is the node's height
func randomHeight(using generator: inout SeededGenerator, maxHeight: Int = 32) -> Int {
    var height = 1
    while height < maxHeight && generator.next() & 1 == 1 {   // heads: one more level
        height += 1
    }
    return height
}

var generator = SeededGenerator(state: 99)
print((0..<16).map { _ in randomHeight(using: &generator) })

// How many of 100,000 nodes reach each level?
var reaching = Array(repeating: 0, count: 33)
for _ in 0..<100_000 {
    let height = randomHeight(using: &generator)
    for level in 1...height {
        reaching[level] += 1
    }
}
for level in 1...6 {
    print("level \(level): \(reaching[level]) nodes (expected about \(100_000 >> (level - 1)))")
}
print("tallest:", reaching.lastIndex { $0 > 0 }!)
