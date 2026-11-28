// Generated from src/dsa/content/lessons/topo-sort/topo-course-schedule.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func isValidOrder(_ order: [Int], _ courseCount: Int, _ prerequisites: [[Int]]) -> Bool {
    guard order.count == courseCount else { return false }
    var position = Array(repeating: -1, count: courseCount)
    for (index, course) in order.enumerated() {
        guard course >= 0, course < courseCount, position[course] == -1 else { return false }  // in range, once
        position[course] = index
    }
    return prerequisites.allSatisfy { position[$0[0]] < position[$0[1]] }
}

let pairs = [[0, 1], [0, 2], [1, 3], [2, 3]]
print(isValidOrder([0, 1, 2, 3], 4, pairs), isValidOrder([0, 2, 1, 3], 4, pairs))
print(isValidOrder([0, 1, 3, 2], 4, pairs), isValidOrder([0, 1, 1, 3], 4, pairs))
