// Generated from src/dsa/content/lessons/dp-advanced/dpa-probability.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Foundation

// Expected rolls of a fair die until every face has shown up at least once
// expected[k] = rolls still needed when k different faces have been seen
var expected = [Double](repeating: 0, count: 7)          // expected[6] = 0: done
for seen in stride(from: 5, through: 0, by: -1) {
    let repeatChance = Double(seen) / 6                   // an old face: stay at `seen`
    let newChance = 1 - repeatChance                      // a new face: move to seen + 1
    // expected[seen] = 1 + repeatChance · expected[seen] + newChance · expected[seen + 1], solved for expected[seen]
    expected[seen] = (1 + newChance * expected[seen + 1]) / (1 - repeatChance)
}
print(expected.map { String(format: "%.2f", $0) })
print("formula 6 · (1 + 1/2 + … + 1/6):", String(format: "%.2f", 6 * (1...6).reduce(0.0) { $0 + 1 / Double($1) }))
