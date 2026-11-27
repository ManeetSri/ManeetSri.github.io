// Generated from src/dsa/content/lessons/topo-sort/topo-course-schedule.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Each pair is [before, after]: before must be completed first
func studyOrder(_ courseCount: Int, _ prerequisites: [[Int]]) -> [Int]? {
    var unlocks = Array(repeating: [Int](), count: courseCount)
    var waitingOn = Array(repeating: 0, count: courseCount)       // in-degrees
    for pair in prerequisites {
        unlocks[pair[0]].append(pair[1])
        waitingOn[pair[1]] += 1
    }
    var order = (0..<courseCount).filter { waitingOn[$0] == 0 }
    var head = 0
    while head < order.count {
        let course = order[head]
        head += 1
        for next in unlocks[course] {
            waitingOn[next] -= 1
            if waitingOn[next] == 0 {
                order.append(next)
            }
        }
    }
    return order.count == courseCount ? order : nil
}

func canFinish(_ courseCount: Int, _ prerequisites: [[Int]]) -> Bool {
    studyOrder(courseCount, prerequisites) != nil
}

let plans: [(courses: Int, pairs: [[Int]])] = [
    (4, [[0, 1], [0, 2], [1, 3], [2, 3]]),
    (3, [[0, 1], [1, 2], [2, 1]]),
    (3, []),
    (2, [[1, 1]]),
]
for plan in plans {
    print(canFinish(plan.courses, plan.pairs), studyOrder(plan.courses, plan.pairs) ?? [])
}
