// Reference solution: Fewest semesters to graduate. Kahn's algorithm, one layer at a time: the
// courses with no prerequisites form semester 1; taking them all frees the courses whose last
// prerequisite they were, which form semester 2; and so on. Taking every free course at once is
// never worse, so the number of layers is the minimum. It equals the number of courses on the
// longest prerequisite chain. If a cycle leaves courses stuck, the answer is -1.
// O(n + p) time and space, with no recursion.

public enum FewestSemesters {
    public static func minimum(courseCount: Int, prerequisites: [[Int]]) -> Int {
        var unlocks = Array(repeating: [Int](), count: courseCount)
        var waitingOn = Array(repeating: 0, count: courseCount)
        for pair in prerequisites {
            unlocks[pair[0]].append(pair[1])
            waitingOn[pair[1]] += 1
        }
        var semester = (0..<courseCount).filter { waitingOn[$0] == 0 }
        var semesters = 0
        var taken = 0
        while !semester.isEmpty {
            semesters += 1
            taken += semester.count
            var next: [Int] = []
            for course in semester {
                for after in unlocks[course] {
                    waitingOn[after] -= 1
                    if waitingOn[after] == 0 {
                        next.append(after)
                    }
                }
            }
            semester = next
        }
        return taken == courseCount ? semesters : -1
    }
}
