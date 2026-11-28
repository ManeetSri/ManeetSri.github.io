import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CourseCompletionCheckTests {
    /// A tiny deterministic generator, so the large graphs are the same every run.
    private struct Steps {
        private var state: UInt64

        init(seed: UInt64) {
            state = seed
        }

        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// A DAG of `layers × width` courses with shuffled labels: every course after the first layer
    /// needs one course from the layer before (its parent), plus one more from any earlier layer.
    /// The longest chain is `layers` courses, so a recursive search never goes deeper than that.
    private func layeredCourses(layers: Int, width: Int, seed: UInt64) -> (pairs: [[Int]], label: [[Int]], parent: [Int: Int]) {
        var steps = Steps(seed: seed)
        var labels = Array(0..<(layers * width))
        for index in stride(from: labels.count - 1, to: 0, by: -1) {
            labels.swapAt(index, steps.next(below: index + 1))
        }
        let label = (0..<layers).map { layer in Array(labels[(layer * width)..<((layer + 1) * width)]) }
        var pairs: [[Int]] = []
        var parent: [Int: Int] = [:]
        for layer in 1..<layers {
            for slot in 0..<width {
                let course = label[layer][slot]
                parent[course] = label[layer - 1][steps.next(below: width)]
                pairs.append([parent[course]!, course])
                let earlier = steps.next(below: layer)
                pairs.append([label[earlier][steps.next(below: width)], course])
            }
        }
        return (pairs, label, parent)
    }

    @Test("Small plans", arguments: [
        (2, [[0, 1]], true),
        (2, [[0, 1], [1, 0]], false),
        (4, [[3, 2], [2, 1], [1, 0]], true),
        (4, [[0, 1], [1, 2], [2, 3], [3, 1]], false),                 // the cycle 1 → 2 → 3 → 1
        (5, [[4, 0], [4, 1], [0, 2], [1, 2], [2, 3]], true),          // a diamond, then a tail
        (6, [[0, 1], [2, 3], [3, 4], [4, 2], [5, 0]], false),         // a cycle away from course 0
        (3, [[0, 1], [0, 1], [1, 2], [0, 1]], true),                  // repeated pairs
    ])
    func small(courseCount: Int, prerequisites: [[Int]], expected: Bool) {
        #expect(CourseCompletionCheck.canFinish(courseCount: courseCount, prerequisites: prerequisites) == expected)
    }

    @Test("No prerequisites at all")
    func free() {
        #expect(CourseCompletionCheck.canFinish(courseCount: 0, prerequisites: []))
        #expect(CourseCompletionCheck.canFinish(courseCount: 1, prerequisites: []))
        #expect(CourseCompletionCheck.canFinish(courseCount: 50, prerequisites: []))
    }

    @Test("A course that requires itself")
    func selfLoop() {
        #expect(!CourseCompletionCheck.canFinish(courseCount: 1, prerequisites: [[0, 0]]))
        #expect(!CourseCompletionCheck.canFinish(courseCount: 3, prerequisites: [[0, 1], [2, 2]]))
    }

    @Test("Several separate groups of courses")
    func components() {
        let fine = [[0, 1], [1, 2], [3, 4], [6, 5], [7, 5], [5, 8]]
        #expect(CourseCompletionCheck.canFinish(courseCount: 10, prerequisites: fine))
        #expect(!CourseCompletionCheck.canFinish(courseCount: 10, prerequisites: fine + [[8, 7]]))
    }

    @Test("A ring of 900 courses, and the same ring broken")
    func ring() {
        let ring = (0..<900).map { [$0, ($0 + 1) % 900] }
        #expect(!CourseCompletionCheck.canFinish(courseCount: 900, prerequisites: ring))
        #expect(CourseCompletionCheck.canFinish(courseCount: 900, prerequisites: Array(ring.dropLast())))
    }

    @Test("100,000 courses in 400 layers")
    func large() {
        let (pairs, label, parent) = layeredCourses(layers: 400, width: 250, seed: 7)
        #expect(CourseCompletionCheck.canFinish(courseCount: 100_000, prerequisites: pairs))
        // Follow parents from a last-layer course back to the first layer, then require the last
        // course before that first one: a cycle 400 courses long
        let last = label[399][0]
        var first = last
        while let up = parent[first] {
            first = up
        }
        #expect(!CourseCompletionCheck.canFinish(courseCount: 100_000, prerequisites: pairs + [[last, first]]))
    }
}
