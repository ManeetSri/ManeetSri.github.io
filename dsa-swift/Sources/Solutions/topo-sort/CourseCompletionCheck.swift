// Reference solution: Can every course be finished? Each pair [before, after] is an edge
// before → after, and every course can be finished exactly when this graph has no cycle. Kahn's
// algorithm answers that: repeatedly take a course nothing is waiting on any more and release the
// courses it unlocks. If a cycle exists, its courses never become free, so fewer than n come out.
// O(n + p) time and space for n courses and p pairs, and no recursion, so long chains are safe.

public enum CourseCompletionCheck {
    public static func canFinish(courseCount: Int, prerequisites: [[Int]]) -> Bool {
        var unlocks = Array(repeating: [Int](), count: courseCount)
        var waitingOn = Array(repeating: 0, count: courseCount)      // in-degrees
        for pair in prerequisites {
            unlocks[pair[0]].append(pair[1])
            waitingOn[pair[1]] += 1
        }
        var ready = (0..<courseCount).filter { waitingOn[$0] == 0 }
        var head = 0                                                 // ready doubles as a queue
        while head < ready.count {
            let course = ready[head]
            head += 1
            for next in unlocks[course] {
                waitingOn[next] -= 1
                if waitingOn[next] == 0 {
                    ready.append(next)
                }
            }
        }
        return ready.count == courseCount
    }
}
