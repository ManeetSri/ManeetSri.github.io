import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct PinRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct NearestMapPinTests {
    /// Check every pin: O(pins) per query, but clearly right.
    private func bruteForce(_ pins: [[Int]], _ query: [Int]) -> Int {
        var best = (distance: Int.max, index: Int.max)
        for (index, pin) in pins.enumerated() {
            let dx = pin[0] - query[0], dy = pin[1] - query[1]
            let candidate = (dx * dx + dy * dy, index)
            if candidate < best { best = candidate }
        }
        return best.index
    }

    @Test("Examples and small cases", arguments: [
        ([[0, 0], [10, 0], [0, 10]], [[1, 1], [9, 2], [2, 7], [100, 100]], [0, 1, 2, 1]),
        ([[5, 5]], [[0, 0], [5, 5], [-1_000_000, 1_000_000]], [0, 0, 0]),
        ([[0, 0], [2, 0]], [[1, 0], [1, 5], [3, 0]], [0, 0, 1]),
        ([[4, 4], [4, 4], [1, 1]], [[4, 4], [3, 3], [2, 2]], [0, 0, 2]),
        ([[-3, -4], [3, 4], [-3, 4], [3, -4]], [[0, 0], [3, 0], [0, -4]], [0, 1, 0]),
    ] as [([[Int]], [[Int]], [Int])])
    func examples(pins: [[Int]], queries: [[Int]], expected: [Int]) {
        #expect(NearestMapPin.nearest(pins: pins, queries: queries) == expected)
    }

    @Test("No queries gives no answers")
    func noQueries() {
        #expect(NearestMapPin.nearest(pins: [[1, 2]], queries: []) == [])
    }

    @Test("Ties go to the smallest index, wherever it is in the tree")
    func ties() {
        // Eight pins at distance 5 from the origin, and the origin's nearest is the smallest index of them
        let ring = [[3, 4], [4, 3], [-3, 4], [-4, 3], [3, -4], [4, -3], [-3, -4], [-4, -3]]
        for rotation in 0..<ring.count {
            let pins = Array(ring[rotation...] + ring[..<rotation]) + [[50, 50]]
            #expect(NearestMapPin.nearest(pins: pins, queries: [[0, 0]]) == [0])
        }
        // Many copies of one pin: the first copy wins
        let copies = Array(repeating: [7, 7], count: 30) + [[0, 0]]
        #expect(NearestMapPin.nearest(pins: Array(copies.reversed()), queries: [[7, 7], [6, 6], [1, 1]]) == [1, 1, 0])
    }

    @Test("Matches brute force on random small maps", arguments: [1, 2, 3, 4] as [UInt64])
    func randomSmall(seed: UInt64) {
        var random = PinRandom(seed: seed)
        for _ in 0..<150 {
            let range = Int.random(in: 1...30, using: &random)          // small ranges force ties
            let pins = (0..<Int.random(in: 1...60, using: &random)).map { _ in
                [Int.random(in: -range...range, using: &random), Int.random(in: -range...range, using: &random)]
            }
            let queries = (0..<20).map { _ in
                [Int.random(in: -range - 5...range + 5, using: &random), Int.random(in: -range - 5...range + 5, using: &random)]
            }
            let result = NearestMapPin.nearest(pins: pins, queries: queries)
            let expected = queries.map { bruteForce(pins, $0) }
            if result != expected {
                Issue.record("wrong answer for pins \(pins) and queries \(queries)")
                return
            }
        }
    }

    @Test("Collinear pins and a dense grid")
    func degenerate() {
        let line = (0..<500).map { [0, $0 * 3] }
        let lineQueries = (0..<100).map { [$0 % 7 - 3, $0 * 15 + 1] }
        #expect(NearestMapPin.nearest(pins: line, queries: lineQueries) == lineQueries.map { bruteForce(line, $0) })

        let grid = (0..<900).map { [$0 % 30, $0 / 30] }
        let gridQueries = (0..<200).map { [($0 * 7) % 31, ($0 * 11) % 31] }
        #expect(NearestMapPin.nearest(pins: grid, queries: gridQueries) == gridQueries.map { bruteForce(grid, $0) })
    }

    @Test("30,000 pins and 30,000 queries")
    func large() {
        var random = PinRandom(seed: 2_026)
        let pins = (0..<30_000).map { _ in
            [Int.random(in: -1_000_000...1_000_000, using: &random), Int.random(in: -1_000_000...1_000_000, using: &random)]
        }
        let queries = (0..<30_000).map { _ in
            [Int.random(in: -1_000_000...1_000_000, using: &random), Int.random(in: -1_000_000...1_000_000, using: &random)]
        }
        let result = NearestMapPin.nearest(pins: pins, queries: queries)
        #expect(result.count == queries.count)
        guard result.count == queries.count else { return }
        for i in stride(from: 0, to: queries.count, by: 500) where result[i] != bruteForce(pins, queries[i]) {
            Issue.record("query \(i) is wrong")
            return
        }
        // Querying at a pin finds that pin, or the first pin at the same spot
        var firstAt: [[Int]: Int] = [:]
        for (index, pin) in pins.enumerated() where firstAt[pin] == nil {
            firstAt[pin] = index
        }
        let atPins = NearestMapPin.nearest(pins: pins, queries: Array(pins.prefix(5_000)))
        #expect(atPins == pins.prefix(5_000).map { firstAt[$0]! })
    }
}
