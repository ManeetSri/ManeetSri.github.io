// Generated from src/dsa/content/lessons/topo-sort/topo-parallel-courses.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func semesterPlan(_ courseCount: Int, _ prerequisites: [[Int]]) -> [[Int]]? {
    var unlocks = Array(repeating: [Int](), count: courseCount)
    var waitingOn = Array(repeating: 0, count: courseCount)
    for pair in prerequisites {                      // [before, after]
        unlocks[pair[0]].append(pair[1])
        waitingOn[pair[1]] += 1
    }
    var current = (0..<courseCount).filter { waitingOn[$0] == 0 }
    var plan: [[Int]] = []
    var taken = 0
    while !current.isEmpty {
        plan.append(current)                         // take everything that's ready, together
        taken += current.count
        var next: [Int] = []
        for course in current {
            for after in unlocks[course] {
                waitingOn[after] -= 1
                if waitingOn[after] == 0 {
                    next.append(after)               // ready next semester, not this one
                }
            }
        }
        current = next
    }
    return taken == courseCount ? plan : nil         // nil: a cycle blocks some courses
}

let names = ["Swift", "Maths", "Collections", "Recursion", "Trees", "Graphs", "Capstone"]
let prerequisites = [[0, 2], [0, 3], [1, 3], [2, 4], [3, 4], [4, 5], [1, 5], [5, 6], [2, 6]]
let plan = semesterPlan(names.count, prerequisites)!
for (index, semester) in plan.enumerated() {
    print("semester \(index + 1):", semester.map { names[$0] }.joined(separator: ", "))
}
print(semesterPlan(3, [[0, 1], [1, 2], [2, 1]]) == nil)
