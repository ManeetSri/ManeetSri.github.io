// Generated from src/dsa/content/lessons/mock-practice/mock-timed-sets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

enum Difficulty: Int {
    case easy = 1, medium = 2, hard = 3        // the raw value is the weight
}

// Splits the time between the problems by weight, keeping a buffer at the end
func plan(_ problems: [(title: String, level: Difficulty)], minutes: Int, buffer: Int) -> [String] {
    let totalWeight = problems.reduce(0) { $0 + $1.level.rawValue }
    var clock = 0
    var lines: [String] = []
    for problem in problems {
        let share = (minutes - buffer) * problem.level.rawValue / totalWeight
        lines.append("\(clock)–\(clock + share) min: \(problem.title) (\(problem.level))")
        clock += share
    }
    lines.append("\(clock)–\(minutes) min: buffer, then stop")
    return lines
}

let set: [(title: String, level: Difficulty)] = [
    ("Balanced brackets", .easy),
    ("Longest unique run", .medium),
    ("Count and measure the islands", .medium),
]
print(plan(set, minutes: 60, buffer: 5).joined(separator: "\n"))
