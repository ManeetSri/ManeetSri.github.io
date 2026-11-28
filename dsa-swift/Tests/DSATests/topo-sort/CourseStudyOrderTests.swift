import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CourseStudyOrderTests {
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

    /// Many orders can be right, so the tests check the order's properties instead of comparing it
    /// with one answer: every course exactly once, and each `before` placed ahead of its `after`.
    private func isValid(_ order: [Int], courseCount: Int, prerequisites: [[Int]]) -> Bool {
        guard order.count == courseCount else { return false }
        var position = Array(repeating: -1, count: courseCount)
        for (index, course) in order.enumerated() {
            guard course >= 0, course < courseCount, position[course] == -1 else { return false }
            position[course] = index
        }
        return prerequisites.allSatisfy { position[$0[0]] < position[$0[1]] }
    }

    /// A DAG of `layers × width` courses with shuffled labels: every course after the first layer
    /// needs one course from the layer before (its parent), plus one more from any earlier layer.
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

    @Test("Plans that can be ordered", arguments: [
        (2, [[1, 0]]),
        (4, [[3, 2], [2, 1], [1, 0]]),                                // only one order works
        (4, [[3, 1], [3, 2], [1, 0], [2, 0]]),                        // a diamond
        (6, [[5, 2], [5, 0], [4, 0], [4, 1], [2, 3], [3, 1]]),
        (5, [[4, 3], [4, 3], [3, 0]]),                                // a repeated pair, and free courses
        (3, []),
        (1, []),
    ])
    func orderable(courseCount: Int, prerequisites: [[Int]]) {
        let order = CourseStudyOrder.order(courseCount: courseCount, prerequisites: prerequisites)
        #expect(isValid(order, courseCount: courseCount, prerequisites: prerequisites), "got \(order)")
    }

    @Test("The only valid order")
    func unique() {
        #expect(CourseStudyOrder.order(courseCount: 4, prerequisites: [[3, 2], [2, 1], [1, 0]]) == [3, 2, 1, 0])
        #expect(CourseStudyOrder.order(courseCount: 3, prerequisites: [[2, 0], [0, 1], [2, 1]]) == [2, 0, 1])
    }

    @Test("Plans with a cycle give []", arguments: [
        (2, [[0, 1], [1, 0]]),
        (1, [[0, 0]]),                                                // a course that requires itself
        (5, [[0, 1], [1, 2], [2, 3], [3, 1], [0, 4]]),
        (6, [[0, 1], [2, 3], [3, 4], [4, 2], [5, 0]]),                // the cycle is away from the rest
    ])
    func cycles(courseCount: Int, prerequisites: [[Int]]) {
        #expect(CourseStudyOrder.order(courseCount: courseCount, prerequisites: prerequisites) == [])
    }

    @Test("No courses at all")
    func none() {
        #expect(CourseStudyOrder.order(courseCount: 0, prerequisites: []) == [])
    }

    @Test("A chain of 900 courses, numbered backwards")
    func chain() {
        let pairs = (1..<900).map { [$0, $0 - 1] }
        let order = CourseStudyOrder.order(courseCount: 900, prerequisites: pairs)
        #expect(order == Array((0..<900).reversed()))
        let looped = pairs + [[0, 899]]
        #expect(CourseStudyOrder.order(courseCount: 900, prerequisites: looped) == [])
    }

    @Test("100,000 courses in 400 layers")
    func large() {
        let (pairs, label, parent) = layeredCourses(layers: 400, width: 250, seed: 11)
        let order = CourseStudyOrder.order(courseCount: 100_000, prerequisites: pairs)
        #expect(isValid(order, courseCount: 100_000, prerequisites: pairs))
        // Close a cycle 400 courses long: the order must now be empty
        let last = label[399][0]
        var first = last
        while let up = parent[first] {
            first = up
        }
        #expect(CourseStudyOrder.order(courseCount: 100_000, prerequisites: pairs + [[last, first]]) == [])
    }
}
