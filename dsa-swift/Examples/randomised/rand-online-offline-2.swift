// Generated from src/dsa/content/lessons/randomised/rand-online-offline.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Foundation

// The secretary problem: candidates arrive in random order; hire on the spot or lose them forever.
// Strategy: watch the first r without hiring, then hire the first one better than all of those.
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
}

var generator = SeededGenerator(seed: 37)
let n = 100
let trials = 4_000
for r in [1, 10, 25, 37, 50, 75] {
    var hiredTheBest = 0
    for _ in 0..<trials {
        var scores = Array(0..<n)                         // n − 1 is the best candidate
        for i in stride(from: n - 1, through: 1, by: -1) { // Fisher–Yates
            scores.swapAt(i, Int(generator.next() % UInt64(i + 1)))
        }
        let benchmark = scores[0..<r].max()!
        if let hired = scores[r...].first(where: { $0 > benchmark }), hired == n - 1 {
            hiredTheBest += 1
        }
    }
    print(String(format: "watch %2d, then hire: best candidate %.3f of the time", r, Double(hiredTheBest) / Double(trials)))
}
print(String(format: "1/e = %.3f", 1 / exp(1.0)))
