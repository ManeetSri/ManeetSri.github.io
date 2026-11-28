import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// The height found by really inserting, with child positions in arrays. Fine for shuffled input.
private func simulatedHeight(_ values: [Int]) -> Int {
    var left: [Int] = []
    var right: [Int] = []
    var height = 0
    for (index, value) in values.enumerated() {
        left.append(-1)
        right.append(-1)
        var depth = 1
        var node = 0
        while index > 0 {
            depth += 1
            if value < values[node] {
                if left[node] < 0 { left[node] = index; break }
                node = left[node]
            } else {
                if right[node] < 0 { right[node] = index; break }
                node = right[node]
            }
        }
        height = max(height, depth)
    }
    return height
}

/// 0..<n in a fixed pseudo-random order (a Fisher–Yates shuffle with a seeded generator).
private func shuffled(_ n: Int, seed: UInt64) -> [Int] {
    var values = Array(0..<n)
    var state = seed
    for i in stride(from: n - 1, to: 0, by: -1) {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        values.swapAt(i, Int((state >> 33) % UInt64(i + 1)))
    }
    return values
}

/// The middle of low...high, then the middle of each half, and so on: the order for a perfect tree.
private func middleFirst(_ low: Int, _ high: Int) -> [Int] {
    var order: [Int] = []
    var pending = [(low, high)]
    while let (lo, hi) = pending.popLast() {
        guard lo <= hi else { continue }
        let mid = lo + (hi - lo) / 2
        order.append(mid)
        pending.append((mid + 1, hi))
        pending.append((lo, mid - 1))
    }
    return order
}

@Suite struct InsertionOrderHeightTests {
    @Test("The examples", arguments: [
        ([4, 2, 6, 1, 3, 5, 7], 3),
        ([1, 2, 3, 4, 5], 5),
        ([1, 7, 2, 6, 3, 5, 4], 7),
        ([50, 30, 70, 40, 35], 4),
        ([9], 1),
        ([], 0),
    ])
    func examples(values: [Int], expected: Int) {
        #expect(InsertionOrderHeight.height(afterInserting: values) == expected)
    }

    @Test("More hand-checked orders", arguments: [
        ([5, 4, 3, 2, 1], 5),                               // reversed: a chain to the left
        ([2, 1], 2),
        ([1, 2], 2),
        ([3, 1, 2], 3),                                     // 2 goes right of 1, under 3
        ([3, 1, 5, 2, 4], 3),
        ([10, 5, 15, 3, 7, 12, 20, 1], 4),
        ([-5, Int.max, Int.min, 0, -6], 3),
    ])
    func handChecked(values: [Int], expected: Int) {
        #expect(InsertionOrderHeight.height(afterInserting: values) == expected)
    }

    @Test("Matches building the tree on hundreds of random orders")
    func manyRandom() {
        var failures: [String] = []
        for seed in 1...400 {
            let n = seed % 40 + 1
            let values = shuffled(n, seed: UInt64(seed)).map { $0 * 3 - 50 }
            let expected = simulatedHeight(values)
            let actual = InsertionOrderHeight.height(afterInserting: values)
            if actual != expected && failures.count < 3 {
                failures.append("\(values): got \(actual), expected \(expected)")
            }
        }
        #expect(failures.isEmpty, "\(failures)")
    }

    @Test("200,000 values in sorted, reversed and zigzag order: chains")
    func largeChains() {
        let n = 200_000
        #expect(InsertionOrderHeight.height(afterInserting: Array(0..<n)) == n)
        #expect(InsertionOrderHeight.height(afterInserting: Array((0..<n).reversed())) == n)
        // 0, n − 1, 1, n − 2, …: every value lands below the one before it
        let zigzag = (0..<n).map { $0 % 2 == 0 ? $0 / 2 : n - 1 - $0 / 2 }
        #expect(InsertionOrderHeight.height(afterInserting: zigzag) == n)
    }

    @Test("Middle first gives the minimum height")
    func perfect() {
        #expect(InsertionOrderHeight.height(afterInserting: middleFirst(1, 131_071)) == 17)   // 2¹⁷ − 1 values
        #expect(InsertionOrderHeight.height(afterInserting: middleFirst(1, 131_072)) == 18)
    }

    @Test("200,000 shuffled values match building the tree")
    func largeShuffled() {
        let values = shuffled(200_000, seed: 37).map { $0 * 1_000 - 7 }
        #expect(InsertionOrderHeight.height(afterInserting: values) == simulatedHeight(values))
    }
}
