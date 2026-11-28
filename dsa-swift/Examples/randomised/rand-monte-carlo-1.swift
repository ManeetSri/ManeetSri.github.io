// Generated from src/dsa/content/lessons/randomised/rand-monte-carlo.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Foundation

// Estimating π: throw random points at a square and count those inside the quarter circle
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {          // SplitMix64
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
    /// A Double in 0..<1 from the top 53 bits
    mutating func unit() -> Double {
        Double(next() >> 11) / 9_007_199_254_740_992.0
    }
}

var generator = SeededGenerator(seed: 2026)
var inside = 0
var thrown = 0
for target in [1_000, 10_000, 100_000, 1_000_000] {
    while thrown < target {
        let x = generator.unit(), y = generator.unit()
        if x * x + y * y < 1 { inside += 1 }
        thrown += 1
    }
    let estimate = 4 * Double(inside) / Double(thrown)
    print(String(format: "%9d points: π ≈ %.4f, error %.4f", thrown, estimate, abs(estimate - Double.pi)))
}
