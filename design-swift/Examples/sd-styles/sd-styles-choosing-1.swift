// Generated from src/dsa/design/content/lessons/sd-styles/sd-styles-choosing.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// Each option is scored 1 (poor) to 5 (strong) on, in order:
// offline, testability, team autonomy, simplicity, time to ship
let options: [(name: String, scores: [Int])] = [
    ("Layered app, one target", [4, 3, 2, 5, 5]),
    ("Modular monolith (feature packages)", [4, 4, 4, 3, 3]),
    ("Micro-apps on an event bus", [3, 3, 5, 1, 2]),
]

func rank(weights: [Int]) {
    let totals = options.map { option in
        (option.name, zip(weights, option.scores).map { $0 * $1 }.reduce(0, +))
    }
    for (name, total) in totals.sorted(by: { $0.1 > $1.1 || ($0.1 == $1.1 && $0.0 < $1.0) }) {
        print("  \(total)  \(name)")
    }
}

// Five engineers, one product: shipping fast and keeping it simple matter most
print("A team of 5:")
rank(weights: [5, 4, 1, 4, 5])

// Forty engineers in six squads: autonomy and testability now outweigh simplicity
print("A team of 40:")
rank(weights: [5, 5, 5, 2, 2])
