// Generated from src/dsa/design/content/lessons/sd-quality/sd-quality-decisions.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

struct Option {
    let name: String
    let scores: [Double]   // speed, migrations, testability, familiarity, no dependency
}

let options = [
    Option(name: "SwiftData", scores: [3, 3, 4, 4, 5]),
    Option(name: "Core Data", scores: [4, 4, 3, 3, 5]),
    Option(name: "GRDB", scores: [5, 5, 5, 2, 1]),
    Option(name: "JSON files", scores: [1, 2, 4, 5, 5]),
]
let weights: [Double] = [3, 3, 2, 1, 1]

func score(_ option: Option, _ weights: [Double]) -> Double {
    zip(option.scores, weights).reduce(0) { $0 + $1.0 * $1.1 } / weights.reduce(0, +)
}

func winner(_ weights: [Double]) -> String {
    options.max { score($0, weights) < score($1, weights) }!.name
}

for option in options {
    print(option.name, String(format: "%.2f", score(option, weights)))
}
print("Winner:", winner(weights))

for weight in [1.0, 2, 3, 4, 5] {
    var nudged = weights
    nudged[4] = weight
    print("No-dependency weight \(Int(weight)): \(winner(nudged))")
}
