import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ProjectCriticalPathTests {
    /// A tiny deterministic generator, so the large project is the same every run.
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

    @Test("Small projects", arguments: [
        ([3, 2, 4], [[0, 1], [0, 2]], 7, [0, 2]),
        ([5], [], 5, [0]),
        ([2, 3, 1], [[0, 1], [1, 2]], 6, [0, 1, 2]),                          // a chain: all critical
        ([4, 2, 7, 1], [], 7, [2]),                                            // independent tasks
        ([3, 6, 3, 2], [[0, 1], [0, 2], [1, 3], [2, 3]], 11, [0, 1, 3]),       // a diamond
        ([3, 4, 4, 2], [[0, 1], [0, 2], [1, 3], [2, 3]], 9, [0, 1, 2, 3]),     // two equal branches
        ([1, 5, 2, 2, 1], [[0, 2], [1, 3], [2, 3], [3, 4]], 8, [1, 3, 4]),
        ([2, 2, 9], [[0, 1]], 9, [2]),                                         // the chain has slack
    ])
    func small(durations: [Int], dependencies: [[Int]], finishTime: Int, critical: [Int]) {
        let plan = ProjectCriticalPath.plan(durations: durations, dependencies: dependencies)
        #expect(plan.finishTime == finishTime)
        #expect(plan.criticalTasks == critical)
    }

    @Test("Tasks numbered against the order they run in")
    func backwardsLabels() {
        // 4 → 3 → 0, and 4 → 2 → 1 → 0, with 1 slow enough to matter
        let plan = ProjectCriticalPath.plan(durations: [1, 6, 1, 2, 2], dependencies: [[4, 3], [3, 0], [4, 2], [2, 1], [1, 0]])
        #expect(plan.finishTime == 10)
        #expect(plan.criticalTasks == [0, 1, 2, 4])
    }

    @Test("Ties for the longest finish are all critical")
    func ties() {
        let plan = ProjectCriticalPath.plan(durations: [4, 1, 3, 4], dependencies: [[1, 2]])
        #expect(plan.finishTime == 4)
        #expect(plan.criticalTasks == [0, 1, 2, 3])
    }

    @Test("100,000 tasks around a spine of 300")
    func large() {
        // A spine of 300 tasks of 10 days each, one after another: 3,000 days. Each of the other
        // tasks takes 1 day and hangs between spine task s and spine task s + 5, so it always has
        // slack; the rest have no dependencies at all. Labels are shuffled.
        var steps = Steps(seed: 5)
        let count = 100_000
        var labels = Array(0..<count)
        for index in stride(from: count - 1, to: 0, by: -1) {
            labels.swapAt(index, steps.next(below: index + 1))
        }
        let spine = Array(labels[0..<300])
        var durations = Array(repeating: 1, count: count)
        var dependencies: [[Int]] = []
        for (index, task) in spine.enumerated() {
            durations[task] = 10
            if index > 0 {
                dependencies.append([spine[index - 1], task])
            }
        }
        for task in labels[300..<90_000] {
            let s = steps.next(below: 295)
            dependencies.append([spine[s], task])
            dependencies.append([task, spine[s + 5]])
        }
        let plan = ProjectCriticalPath.plan(durations: durations, dependencies: dependencies)
        #expect(plan.finishTime == 3_000)
        #expect(plan.criticalTasks == spine.sorted())
    }
}
