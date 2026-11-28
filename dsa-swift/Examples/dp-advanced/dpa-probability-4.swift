// Generated from src/dsa/content/lessons/dp-advanced/dpa-probability.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Foundation

// Expected number of distinct faces seen after k rolls of a fair die, two ways

// 1. DP over states: chance[d] = probability of having seen exactly d different faces so far
func distinctByDP(rolls: Int) -> Double {
    var chance = [Double](repeating: 0, count: 7)
    chance[0] = 1
    for _ in 0..<rolls {
        var next = [Double](repeating: 0, count: 7)
        for seen in 0...6 where chance[seen] > 0 {
            next[seen] += chance[seen] * Double(seen) / 6          // an old face
            if seen < 6 {
                next[seen + 1] += chance[seen] * Double(6 - seen) / 6   // a new face
            }
        }
        chance = next
    }
    return (0...6).reduce(0.0) { $0 + Double($1) * chance[$1] }
}

// 2. Linearity of expectation: add up, for each face, the probability that it shows up at least once
func distinctByLinearity(rolls: Int) -> Double {
    6 * (1 - pow(5.0 / 6, Double(rolls)))
}

for rolls in [1, 2, 6, 20] {
    print(rolls, String(format: "%.6f", distinctByDP(rolls: rolls)), String(format: "%.6f", distinctByLinearity(rolls: rolls)))
}
