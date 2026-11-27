import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct TimberRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct TimberCuttingCostTests {
    /// Every order of the marks, with the beam actually cut piece by piece. O(m! · m²), so only for a few marks.
    private func bruteForce(length: Int, marks: [Int]) -> Int {
        func orders(_ items: [Int]) -> [[Int]] {
            guard items.count > 1 else { return [items] }
            return items.indices.flatMap { index -> [[Int]] in
                var rest = items
                let first = rest.remove(at: index)
                return orders(rest).map { [first] + $0 }
            }
        }
        var best = Int.max
        for order in orders(marks) {
            var pieces = [(from: 0, to: length)]
            var total = 0
            for mark in order {
                let index = pieces.firstIndex { $0.from < mark && mark < $0.to }!
                let piece = pieces[index]
                total += piece.to - piece.from
                pieces.replaceSubrange(index...index, with: [(piece.from, mark), (mark, piece.to)])
            }
            best = min(best, total)
        }
        return best
    }

    /// The first-cut recurrence, top-down with a memo, for many marks
    private func reference(length: Int, marks: [Int]) -> Int {
        let points = [0] + marks.sorted() + [length]
        var memo = Array(repeating: Array(repeating: -1, count: points.count), count: points.count)
        func best(_ left: Int, _ right: Int) -> Int {
            if right - left < 2 { return 0 }
            if memo[left][right] >= 0 { return memo[left][right] }
            var answer = Int.max
            for k in (left + 1)..<right {
                answer = min(answer, best(left, k) + best(k, right))
            }
            memo[left][right] = answer + points[right] - points[left]
            return memo[left][right]
        }
        return best(0, points.count - 1)
    }

    @Test("Examples and edge cases", arguments: [
        (10, [7, 2, 4], 20),
        (10, [4, 5, 6], 18),
        (9, [5, 1, 6, 3], 21),
        (8, [2, 5], 13),
        (100, [50], 100),
        (5, [], 0),
    ] as [(Int, [Int], Int)])
    func examples(length: Int, marks: [Int], expected: Int) {
        #expect(TimberCuttingCost.minimumCost(length: length, marks: marks) == expected)
    }

    @Test("Matches every cutting order on 300 small beams")
    func randomSmall() {
        var random = TimberRandom(seed: 59)
        for _ in 0..<300 {
            let length = Int.random(in: 2...30, using: &random)
            let count = Int.random(in: 0...min(6, length - 1), using: &random)
            let marks = Array(Array(1..<length).shuffled(using: &random).prefix(count))
            #expect(TimberCuttingCost.minimumCost(length: length, marks: marks) == bruteForce(length: length, marks: marks), "length \(length), marks \(marks)")
        }
    }

    @Test("Hundreds of marks")
    func large() {
        // Marks at every unit of a 128-long beam: halving every piece is best, 128 per level, 7 levels
        #expect(TimberCuttingCost.minimumCost(length: 128, marks: Array((1..<128).reversed())) == 896)

        var random = TimberRandom(seed: 400)
        var chosen = Set<Int>()
        while chosen.count < 150 {
            chosen.insert(Int.random(in: 1..<1_000_000, using: &random))
        }
        let marks = Array(chosen).sorted().shuffled(using: &random)
        #expect(TimberCuttingCost.minimumCost(length: 1_000_000, marks: marks) == reference(length: 1_000_000, marks: marks))
    }
}
