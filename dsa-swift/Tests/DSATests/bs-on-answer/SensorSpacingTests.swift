import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SensorSpacingTests {
    /// A tiny deterministic generator, so the random-looking tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// Distinct values from the generator.
    private func distinctPoints(_ count: Int, below limit: Int, steps: inout Steps) -> [Int] {
        var seen = Set<Int>()
        var points: [Int] = []
        while points.count < count {
            let point = steps.next(below: limit)
            if seen.insert(point).inserted { points.append(point) }
        }
        return points
    }

    /// Tries every choice of `sensors` points: fine for a handful of points.
    private func bruteForce(_ points: [Int], _ sensors: Int) -> Int {
        let sorted = points.sorted()
        var best = 0
        func choose(from index: Int, chosen: [Int]) {
            if chosen.count == sensors {
                let gaps = zip(chosen.dropFirst(), chosen).map { $0 - $1 }
                best = max(best, gaps.min()!)
                return
            }
            guard index < sorted.count else { return }
            choose(from: index + 1, chosen: chosen + [sorted[index]])
            choose(from: index + 1, chosen: chosen)
        }
        choose(from: 0, chosen: [])
        return best
    }

    /// True if `count` sensors fit with every pair at least `gap` apart.
    private func fits(_ sorted: [Int], _ count: Int, gap: Int) -> Bool {
        var placed = 1
        var last = sorted[0]
        for point in sorted.dropFirst() where point - last >= gap {
            placed += 1
            last = point
        }
        return placed >= count
    }

    @Test("Finds the widest minimum gap in the examples", arguments: [
        ([10, 1, 5, 22, 13], 3, 9),
        ([10, 1, 5, 22, 13], 2, 21),
        ([10, 1, 5, 22, 13], 5, 3),
        ([4, 2, 8, 6], 3, 2),
        ([3, 14, 1, 9, 6, 17], 3, 8),
        ([0, 1_000_000_000], 2, 1_000_000_000),
    ])
    func examples(points: [Int], sensors: Int, expected: Int) {
        #expect(SensorSpacing.widestMinimumGap(points: points, sensors: sensors) == expected)
    }

    @Test("Works on points in any order")
    func unsorted() {
        #expect(SensorSpacing.widestMinimumGap(points: [22, 13, 10, 5, 1], sensors: 3) == 9)
        #expect(SensorSpacing.widestMinimumGap(points: [9, 0, 3, 6], sensors: 4) == 3)
    }

    @Test("Neighbouring points give a gap of 1")
    func neighbours() {
        #expect(SensorSpacing.widestMinimumGap(points: [5, 6, 7, 8], sensors: 4) == 1)
        #expect(SensorSpacing.widestMinimumGap(points: [5, 6, 7, 8], sensors: 3) == 1)
        #expect(SensorSpacing.widestMinimumGap(points: [5, 6, 7, 8], sensors: 2) == 3)
    }

    @Test("Matches trying every placement on many small inputs")
    func matchesBruteForce() {
        var steps = Steps(seed: 11)
        var firstMismatch: String? = nil
        for _ in 0..<300 {
            var points = distinctPoints(steps.next(below: 7) + 2, below: 40, steps: &steps)
            if steps.next(below: 2) == 0 { points.reverse() }
            let sensors = steps.next(below: points.count - 1) + 2
            if SensorSpacing.widestMinimumGap(points: points, sensors: sensors) != bruteForce(points, sensors) {
                firstMismatch = firstMismatch ?? "\(points) with \(sensors) sensors"
            }
        }
        #expect(firstMismatch == nil, "the first input where the answer differs from the brute force")
    }

    @Test("Handles 100,000 points up to a billion")
    func large() {
        var steps = Steps(seed: 99)
        let points = distinctPoints(100_000, below: 1_000_000_001, steps: &steps)
        let sorted = points.sorted()
        for sensors in [2, 3, 1_000, 50_000, 100_000] {
            let gap = SensorSpacing.widestMinimumGap(points: points, sensors: sensors)
            #expect(gap >= 1)
            guard gap >= 1 else { continue }
            #expect(fits(sorted, sensors, gap: gap), "a gap of \(gap) should fit \(sensors) sensors")
            #expect(!fits(sorted, sensors, gap: gap + 1), "a gap of \(gap + 1) shouldn't fit \(sensors) sensors")
        }
    }
}
