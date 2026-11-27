import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// The pivot rule worked out the slow way: sort every group, then sort the medians.
private func slowPivot(_ numbers: [Int]) -> Int {
    let medians = stride(from: 0, to: numbers.count, by: 5).map { start -> Int in
        let group = numbers[start..<min(start + 5, numbers.count)].sorted()
        return group[group.count / 2]
    }
    return medians.sorted()[medians.count / 2]
}

/// True when `pivot` has the guaranteed share of `numbers` on each side: at least 3 × (g/2 + 1) − 2
/// elements ≤ it and 3 × (g − g/2) − 2 elements ≥ it, for g groups of 5.
private func hasGuarantee(_ pivot: Int, _ numbers: [Int]) -> Bool {
    let groups = (numbers.count + 4) / 5
    let atMost = numbers.filter { $0 <= pivot }.count
    let atLeast = numbers.filter { $0 >= pivot }.count
    return atMost >= 3 * (groups / 2 + 1) - 2 && atLeast >= 3 * (groups - groups / 2) - 2
}

private struct Dice {
    var state: UInt64
    mutating func roll(_ bound: Int) -> Int {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return Int(state >> 33) % bound
    }
}

@Suite struct MedianOfMediansSelectTests {
    @Test("Pivot examples", arguments: [
        ([9, 1, 7, 3, 5, 8, 2, 6, 4, 0, 11], 5),
        ([42], 42),
        ([4, 4, 1, 2], 4),
        ([5, 4, 3, 2, 1, 10, 9, 8, 7, 6], 8),           // medians 3 and 8: index 1 of [3, 8]
        ([-3, -1, -2], -2),
    ])
    func pivotExamples(numbers: [Int], expected: Int) {
        #expect(MedianOfMediansSelect.pivot(of: numbers) == expected)
    }

    @Test("Selection examples", arguments: [
        ([9, 1, 7, 3, 5], 0, 1),
        ([9, 1, 7, 3, 5], 3, 7),
        ([5, 8, 8, 3, 8, 1], 4, 8),
        ([5, 8, 8, 3, 8, 1], 2, 5),
        ([42], 0, 42),
        ([Int.max, Int.min, 0], 0, Int.min),
        ([Int.max, Int.min, 0], 2, Int.max),
    ])
    func selectionExamples(numbers: [Int], index: Int, expected: Int) {
        #expect(MedianOfMediansSelect.value(atSortedIndex: index, in: numbers) == expected)
    }

    @Test("The pivot follows the rule exactly, and has the guarantee, on hundreds of arrays")
    func pivotRule() {
        var dice = Dice(state: 31)
        var failures: [String] = []
        for _ in 0..<400 {
            let count = dice.roll(160) + 1
            let spread = dice.roll(3) == 0 ? 4 : 1_000
            let numbers = (0..<count).map { _ in dice.roll(spread) - spread / 2 }
            let pivot = MedianOfMediansSelect.pivot(of: numbers)
            if failures.count < 3 && (pivot != slowPivot(numbers) || !hasGuarantee(pivot, numbers)) {
                failures.append("\(numbers): got \(pivot), expected \(slowPivot(numbers))")
            }
        }
        #expect(failures.isEmpty, "\(failures)")
    }

    @Test("Selection agrees with sorting for every index on hundreds of arrays")
    func matchesSorting() {
        var dice = Dice(state: 73)
        var failures: [String] = []
        for _ in 0..<250 {
            let count = dice.roll(80) + 1
            let spread = dice.roll(3) == 0 ? 3 : 500
            let numbers = (0..<count).map { _ in dice.roll(spread) }
            let sorted = numbers.sorted()
            for index in numbers.indices {
                let value = MedianOfMediansSelect.value(atSortedIndex: index, in: numbers)
                if value != sorted[index] && failures.count < 3 {
                    failures.append("index \(index) in \(numbers): got \(value), expected \(sorted[index])")
                }
            }
        }
        #expect(failures.isEmpty, "\(failures)")
    }

    @Test("The caller's array is left alone")
    func unchanged() {
        let numbers = [8, 3, 9, 1, 7, 2, 6]
        _ = MedianOfMediansSelect.value(atSortedIndex: 3, in: numbers)
        _ = MedianOfMediansSelect.pivot(of: numbers)
        #expect(numbers == [8, 3, 9, 1, 7, 2, 6])
    }

    @Test("100,000 values that trap simple pivots: sorted, reversed, equal, few distinct, organ pipe")
    func adversarial() {
        let n = 100_000
        let inputs: [(String, [Int])] = [
            ("sorted", Array(0..<n)),
            ("reversed", Array((0..<n).reversed())),
            ("all equal", Array(repeating: 7, count: n)),
            ("three values", (0..<n).map { $0 % 3 }),
            ("organ pipe", (0..<n).map { min($0, n - 1 - $0) }),
        ]
        for (name, numbers) in inputs {
            let sorted = numbers.sorted()
            for index in [n / 3, n - 1] {
                #expect(MedianOfMediansSelect.value(atSortedIndex: index, in: numbers) == sorted[index], "\(name), index \(index)")
            }
            let pivot = MedianOfMediansSelect.pivot(of: numbers)
            #expect(pivot == slowPivot(numbers), "\(name) pivot")
            #expect(hasGuarantee(pivot, numbers), "\(name) pivot guarantee")
        }
    }
}
