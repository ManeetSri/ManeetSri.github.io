import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct TwoArrayMedianTests {
    /// The median by merging: slow, but obviously right.
    private func merged(_ first: [Int], _ second: [Int]) -> Double {
        let all = (first + second).sorted()
        let middle = all.count / 2
        return all.count % 2 == 1 ? Double(all[middle]) : Double(all[middle - 1] + all[middle]) / 2
    }

    /// The median of a huge sorted array and a tiny one, looking only near the middle: the values of
    /// `huge` far from its middle can't be either middle value of the combined list.
    private func nearMiddle(_ huge: [Int], _ tiny: [Int]) -> Double {
        let total = huge.count + tiny.count
        let lowerMiddle = (total - 1) / 2
        let upperMiddle = total / 2
        let start = Swift.max(0, lowerMiddle - tiny.count - 1)
        let end = Swift.min(huge.count, upperMiddle + 2)
        // Everything before the window: huge[..<start], plus any tiny values smaller than huge[start]
        let smallTiny = tiny.filter { $0 < huge[start] }
        let before = start + smallTiny.count
        let window = (Array(huge[start..<end]) + tiny.filter { $0 >= huge[start] }).sorted()
        let low = window[lowerMiddle - before]
        let high = window[upperMiddle - before]
        return Double(low + high) / 2
    }

    @Test("Examples", arguments: [
        ([1, 4, 9], [2, 3], 3.0),
        ([1, 4, 9], [2, 3, 10], 3.5),
        ([5], [7], 6.0),
        ([], [8], 8.0),
        ([2, 6], [], 4.0),
        ([1, 2, 3], [10, 20, 30, 40], 10.0),
        ([10, 20, 30, 40], [1, 2, 3], 10.0),
        ([3, 3, 3], [3, 3], 3.0),
        ([-5, -1], [-4, 0], -2.5),
    ])
    func examples(first: [Int], second: [Int], expected: Double) {
        #expect(TwoArrayMedian.median(of: first, and: second) == expected)
    }

    @Test("The order of the two arrays doesn't matter")
    func symmetric() {
        let a = [1, 5, 8, 12, 20]
        let b = [2, 3]
        #expect(TwoArrayMedian.median(of: a, and: b) == TwoArrayMedian.median(of: b, and: a))
        #expect(TwoArrayMedian.median(of: a, and: b) == 5.0)
    }

    @Test("Values at the edges of the allowed range")
    func bigValues() {
        #expect(TwoArrayMedian.median(of: [1_000_000_000], and: [1_000_000_000]) == 1_000_000_000)
        #expect(TwoArrayMedian.median(of: [-1_000_000_000], and: [1_000_000_000]) == 0)
        #expect(TwoArrayMedian.median(of: [-1_000_000_000, -999_999_999], and: []) == -999_999_999.5)
    }

    @Test("Matches merging on thousands of small pairs of arrays")
    func manySmall() {
        var firstMismatch: String? = nil
        var state = 7
        func next(_ limit: Int) -> Int {
            state = (state * 1_103_515_245 + 12_345) % 2_147_483_648
            return state % limit
        }
        for _ in 0..<5_000 {
            let first = (0..<next(7)).map { _ in next(12) - 4 }.sorted()
            var second = (0..<next(7)).map { _ in next(12) - 4 }.sorted()
            if first.isEmpty && second.isEmpty {
                second = [next(5)]
            }
            if TwoArrayMedian.median(of: first, and: second) != merged(first, second) {
                firstMismatch = firstMismatch ?? "\(first) and \(second)"
            }
        }
        #expect(firstMismatch == nil, "the first input where the answer is wrong")
    }

    @Test("One array entirely before the other")
    func separated() {
        let low = Array(0..<50)
        let high = Array(100..<160)
        #expect(TwoArrayMedian.median(of: low, and: high) == merged(low, high))
        #expect(TwoArrayMedian.median(of: high, and: low) == merged(low, high))
    }

    @Test("A million values against 2,000 short arrays")
    func large() {
        let huge = Array(stride(from: 0, to: 2_000_000, by: 2))          // 0, 2, …, 1,999,998
        var wrong = 0
        var state = 11
        for round in 0..<2_000 {
            state = (state * 1_103_515_245 + 12_345) % 2_147_483_648
            let size = round % 5
            // Short arrays scattered across the whole range, sometimes near the middle
            let tiny = (0..<size).map { offset in
                round % 3 == 0 ? 999_990 + (state + offset * 7) % 21 : (state / 3 + offset * 499_999) % 2_100_000 - 50_000
            }.sorted()
            let expected = nearMiddle(huge, tiny)
            if TwoArrayMedian.median(of: huge, and: tiny) != expected { wrong += 1 }
            if TwoArrayMedian.median(of: tiny, and: huge) != expected { wrong += 1 }
        }
        #expect(wrong == 0)
    }

    @Test("Two arrays of half a million values each")
    func bothLarge() {
        let evens = Array(stride(from: 0, to: 1_000_000, by: 2))
        let odds = Array(stride(from: 1, to: 1_000_000, by: 2))
        #expect(TwoArrayMedian.median(of: evens, and: odds) == 499_999.5)
        let shifted = odds.map { $0 + 400_000 }
        #expect(TwoArrayMedian.median(of: evens, and: shifted) == merged(evens, shifted))
    }
}
