// Generated from src/dsa/content/lessons/mock-practice/mock-random-mastered.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Problem {
    let title: String
    let difficulty: String
    let lessons: [String]
}

let problems = [
    Problem(title: "Two sum with indexes", difficulty: "easy", lessons: ["hash-frequency-two-sum"]),
    Problem(title: "Longest unique run", difficulty: "medium", lessons: ["sw-longest-no-repeat"]),
    Problem(title: "Count and measure the islands", difficulty: "medium", lessons: ["gt-islands"]),
    Problem(title: "Signal spread time", difficulty: "medium", lessons: ["sp-dijkstra", "sp-problems"]),
    Problem(title: "Smallest covering window", difficulty: "hard", lessons: ["sw-min-window"]),
]
let finishedLessons: Set<String> = ["hash-frequency-two-sum", "sw-longest-no-repeat", "gt-islands", "sw-min-window"]
let solved: Set<String> = ["Longest unique run"]

func choices(difficulty: String) -> [String] {
    // 1. Only problems that practise at least one lesson you've finished
    let learned = problems.filter { $0.lessons.contains(where: finishedLessons.contains) }
    // 2. The difficulty filter
    let pool = learned.filter { difficulty == "any" || $0.difficulty == difficulty }
    // 3. Prefer problems you haven't solved, if there are any
    let fresh = pool.filter { !solved.contains($0.title) }
    return (fresh.isEmpty ? pool : fresh).map(\.title)
}

print(choices(difficulty: "any"))
print(choices(difficulty: "medium"))
print(choices(difficulty: "hard"))
