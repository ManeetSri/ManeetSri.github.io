// Generated from src/dsa/content/lessons/efficient-sorts/sort-swift-sort.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Runner: Comparable {
    let name: String
    let seconds: Int

    // Fastest first; equal times in alphabetical order
    static func < (lhs: Runner, rhs: Runner) -> Bool {
        (lhs.seconds, lhs.name) < (rhs.seconds, rhs.name)
    }
}

var results = [
    Runner(name: "Mo", seconds: 1_581),
    Runner(name: "Ada", seconds: 1_602),
    Runner(name: "Kip", seconds: 1_581),
    Runner(name: "Zoe", seconds: 1_544),
]
results.sort()
for runner in results {
    print(runner.name, runner.seconds)
}
print(results.min()!.name, results.max()!.name)
print(Runner(name: "Mo", seconds: 1_581) < Runner(name: "Kip", seconds: 1_581))
