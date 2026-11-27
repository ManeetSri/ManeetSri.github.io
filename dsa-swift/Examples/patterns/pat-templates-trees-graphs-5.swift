// Generated from src/dsa/content/lessons/patterns/pat-templates-trees-graphs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Kahn's algorithm in waves: an order that respects every "before → after" edge, and how many rounds it takes
func waves(_ count: Int, _ edges: [(before: Int, after: Int)]) -> [[Int]]? {
    var outgoing = Array(repeating: [Int](), count: count)
    var inDegree = Array(repeating: 0, count: count)     // unfinished prerequisites of each node
    for edge in edges {
        outgoing[edge.before].append(edge.after)
        inDegree[edge.after] += 1
    }
    var ready = (0..<count).filter { inDegree[$0] == 0 }
    var result: [[Int]] = []
    var done = 0
    while !ready.isEmpty {
        result.append(ready)
        done += ready.count
        var next: [Int] = []
        for node in ready {
            for after in outgoing[node] {
                inDegree[after] -= 1
                if inDegree[after] == 0 { next.append(after) }   // its last prerequisite just finished
            }
        }
        ready = next
    }
    return done == count ? result : nil           // anything left over is stuck in a cycle
}

// Courses 0...5: 0 and 1 have no prerequisites, 2 needs 0, 3 needs 0 and 1, 4 needs 2 and 3, 5 needs 3
let plan = waves(6, [(0, 2), (0, 3), (1, 3), (2, 4), (3, 4), (3, 5)])!
print(plan, "takes", plan.count, "semesters")
print(waves(3, [(0, 1), (1, 2), (2, 1)]) == nil)
