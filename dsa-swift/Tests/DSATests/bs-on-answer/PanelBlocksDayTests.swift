import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PanelBlocksDayTests {
    /// A tiny deterministic generator, so the random-looking tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// Blocks that can be formed on `day`, counted independently of the solution.
    private func blocksOn(_ day: Int, _ onlineDay: [Int], blockSize: Int) -> Int {
        var blocks = 0
        var run = 0
        for switchOn in onlineDay {
            run = switchOn <= day ? run + 1 : 0
            if run == blockSize {
                blocks += 1
                run = 0
            }
        }
        return blocks
    }

    /// Checks every switch-on day in increasing order.
    private func bruteForce(_ onlineDay: [Int], _ blocks: Int, _ blockSize: Int) -> Int {
        for day in Set(onlineDay).sorted() where blocksOn(day, onlineDay, blockSize: blockSize) >= blocks {
            return day
        }
        return -1
    }

    @Test("Finds the earliest day in the examples", arguments: [
        ([5, 1, 4, 6, 2, 3], 2, 2, 4),
        ([5, 1, 4, 6, 2, 3], 1, 6, 6),
        ([5, 1, 4, 6, 2, 3], 3, 2, 6),
        ([5, 1, 4, 6, 2, 3], 4, 2, -1),
        ([3, 9, 2, 8, 4, 1, 7], 2, 2, 8),
        ([7, 7, 7], 3, 1, 7),
    ])
    func examples(onlineDay: [Int], blocks: Int, blockSize: Int, expected: Int) {
        #expect(PanelBlocksDay.earliestDay(onlineDay: onlineDay, blocks: blocks, blockSize: blockSize) == expected)
    }

    @Test("Blocks of one panel need the right number of panels on")
    func singlePanels() {
        #expect(PanelBlocksDay.earliestDay(onlineDay: [9, 2, 7, 4], blocks: 1, blockSize: 1) == 2)
        #expect(PanelBlocksDay.earliestDay(onlineDay: [9, 2, 7, 4], blocks: 3, blockSize: 1) == 7)
        #expect(PanelBlocksDay.earliestDay(onlineDay: [9, 2, 7, 4], blocks: 4, blockSize: 1) == 9)
    }

    @Test("A panel can't be in two blocks, and blocks must be adjacent")
    func adjacency() {
        // Until day 9, the run of three online panels holds one block of 2, not two
        #expect(PanelBlocksDay.earliestDay(onlineDay: [1, 1, 1, 9, 9], blocks: 2, blockSize: 2) == 9)
        // Four panels are on by day 3, but no two of them are neighbours until day 8
        #expect(PanelBlocksDay.earliestDay(onlineDay: [1, 8, 2, 8, 3, 8, 3], blocks: 1, blockSize: 2) == 8)
    }

    @Test("Huge requests return -1 instead of overflowing")
    func hugeRequests() {
        let tenBillion = 10_000_000_000
        #expect(PanelBlocksDay.earliestDay(onlineDay: [1, 2, 3], blocks: tenBillion, blockSize: tenBillion) == -1)
        #expect(PanelBlocksDay.earliestDay(onlineDay: [1, 2, 3], blocks: 1, blockSize: tenBillion) == -1)
        #expect(PanelBlocksDay.earliestDay(onlineDay: [1, 2, 3], blocks: tenBillion, blockSize: 1) == -1)
        #expect(PanelBlocksDay.earliestDay(onlineDay: [1, 2, 3], blocks: 4_611_686_018_427_387_904, blockSize: 2) == -1)
    }

    @Test("Matches checking every day on many small inputs")
    func matchesBruteForce() {
        var steps = Steps(seed: 5)
        var firstMismatch: String? = nil
        for _ in 0..<400 {
            let onlineDay = (0..<(steps.next(below: 10) + 1)).map { _ in steps.next(below: 12) + 1 }
            let blocks = steps.next(below: 4) + 1
            let blockSize = steps.next(below: 4) + 1
            if PanelBlocksDay.earliestDay(onlineDay: onlineDay, blocks: blocks, blockSize: blockSize)
                != bruteForce(onlineDay, blocks, blockSize) {
                firstMismatch = firstMismatch ?? "\(onlineDay) with \(blocks) blocks of \(blockSize)"
            }
        }
        #expect(firstMismatch == nil, "the first input where the answer differs from the brute force")
    }

    @Test("Handles 100,000 panels switching on over a billion days")
    func large() {
        var steps = Steps(seed: 365)
        let onlineDay = (0..<100_000).map { _ in steps.next(below: 1_000_000_000) + 1 }
        for (blocks, blockSize) in [(1, 1), (10, 3), (1_000, 5), (20_000, 2), (1, 100_000)] {
            let day = PanelBlocksDay.earliestDay(onlineDay: onlineDay, blocks: blocks, blockSize: blockSize)
            #expect(day >= 1)
            guard day >= 1 else { continue }
            #expect(blocksOn(day, onlineDay, blockSize: blockSize) >= blocks, "day \(day) should be enough")
            #expect(blocksOn(day - 1, onlineDay, blockSize: blockSize) < blocks, "day \(day - 1) should be too early")
        }
        #expect(PanelBlocksDay.earliestDay(onlineDay: onlineDay, blocks: 50_001, blockSize: 2) == -1)
    }
}
