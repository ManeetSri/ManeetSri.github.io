import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct FewestSemestersTests {
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

    @Test("Small plans", arguments: [
        (3, [[0, 2], [1, 2]], 2),
        (4, [[0, 1], [1, 2], [2, 3]], 4),
        (4, [[3, 2], [3, 1], [2, 0], [1, 0]], 3),                     // a diamond
        (5, [[0, 1], [1, 2], [0, 3], [3, 4], [4, 2]], 4),             // the longer branch decides
        (6, [[5, 0], [0, 1], [2, 3]], 3),                             // separate groups run side by side
        (3, [[0, 1], [0, 1], [1, 2], [0, 2]], 3),                     // repeats and a shortcut
        (1, [], 1),
        (7, [], 1),
    ])
    func small(courseCount: Int, prerequisites: [[Int]], expected: Int) {
        #expect(FewestSemesters.minimum(courseCount: courseCount, prerequisites: prerequisites) == expected)
    }

    @Test("Impossible plans give -1", arguments: [
        (2, [[0, 1], [1, 0]]),
        (1, [[0, 0]]),
        (5, [[0, 1], [1, 2], [2, 3], [3, 1], [0, 4]]),
        (4, [[0, 1], [2, 3], [3, 2]]),                                // a cycle beside a fine group
    ])
    func impossible(courseCount: Int, prerequisites: [[Int]]) {
        #expect(FewestSemesters.minimum(courseCount: courseCount, prerequisites: prerequisites) == -1)
    }

    @Test("A chain of 999 courses, numbered backwards")
    func chain() {
        let pairs = (1..<999).map { [$0, $0 - 1] }
        #expect(FewestSemesters.minimum(courseCount: 999, prerequisites: pairs) == 999)
    }

    @Test("A long chain beside many short ones")
    func mixed() {
        // Courses 0…499 form one chain; 500…9,999 form chains of 2
        var pairs = (0..<499).map { [$0, $0 + 1] }
        for start in stride(from: 500, to: 10_000, by: 2) {
            pairs.append([start, start + 1])
        }
        #expect(FewestSemesters.minimum(courseCount: 10_000, prerequisites: pairs) == 500)
    }

    @Test("100,000 courses in 250 layers")
    func large() {
        // Every course in layer k needs one course from layer k - 1, so it can't be taken before
        // semester k + 1; the extra pairs come from any earlier layer, so they never delay it more
        let layers = 250
        let width = 400
        var steps = Steps(seed: 99)
        var labels = Array(0..<(layers * width))
        for index in stride(from: labels.count - 1, to: 0, by: -1) {
            labels.swapAt(index, steps.next(below: index + 1))
        }
        var pairs: [[Int]] = []
        for layer in 1..<layers {
            for slot in 0..<width {
                let course = labels[layer * width + slot]
                pairs.append([labels[(layer - 1) * width + steps.next(below: width)], course])
                let earlier = steps.next(below: layer)
                pairs.append([labels[earlier * width + steps.next(below: width)], course])
            }
        }
        #expect(FewestSemesters.minimum(courseCount: layers * width, prerequisites: pairs) == layers)
        // A pair from a last-layer course to itself makes it impossible
        let last = labels[layers * width - 1]
        #expect(FewestSemesters.minimum(courseCount: layers * width, prerequisites: pairs + [[last, last]]) == -1)
    }
}
