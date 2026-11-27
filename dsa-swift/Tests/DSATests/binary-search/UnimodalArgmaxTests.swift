import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// The evaluations allowed for a range of n prices.
private func budget(_ n: Int) -> Int {
    2 * (Int.bitWidth - n.leadingZeroBitCount) + 2
}

/// Runs the search, counting evaluations and noting any outside the range.
private func search(_ range: ClosedRange<Int>, _ profit: (Int) -> Int) -> (peak: Int, calls: Int, outside: Bool) {
    var calls = 0
    var outside = false
    let peak = UnimodalArgmax.peak(in: range) { price in
        calls += 1
        if !range.contains(price) { outside = true }
        return profit(price)
    }
    return (peak, calls, outside)
}

/// A strictly unimodal profit curve over `range` peaking at `top`, steeper on the right.
private func curve(peakingAt top: Int) -> (Int) -> Int {
    { price in price <= top ? 3 * (price - top) : -7 * (price - top) }
}

@Suite struct UnimodalArgmaxTests {
    @Test("The lesson's price curve")
    func lessonCurve() {
        let result = search(0...10_000) { -($0 - 6_180) * ($0 - 6_180) }
        #expect(result.peak == 6_180)
        #expect(result.calls <= budget(10_001))
        #expect(!result.outside)
    }

    @Test("Small examples")
    func small() {
        let table = [3, 8, 9, 4, 1]
        #expect(search(1...5) { table[$0 - 1] }.peak == 3)
        #expect(search(1...5) { $0 }.peak == 5)
        #expect(search(-8...2) { -$0 }.peak == -8)
        let single = search(7...7) { _ in 0 }
        #expect(single.peak == 7)
        #expect(single.calls <= budget(1))
        #expect(search(4...5) { -$0 }.peak == 4)
        #expect(search(4...5) { $0 }.peak == 5)
    }

    @Test("Every peak position in every small range, within the budget")
    func everyPosition() {
        var failures: [String] = []
        for count in 1...60 {
            let range = -20...(-21 + count)
            for top in range {
                let result = search(range, curve(peakingAt: top))
                if failures.count < 3 && (result.peak != top || result.outside || result.calls > budget(count)) {
                    failures.append("\(range) peaking at \(top): got \(result.peak) after \(result.calls) calls (allowed \(budget(count)))")
                }
            }
        }
        #expect(failures.isEmpty, "\(failures)")
    }

    @Test("Random strictly unimodal tables")
    func randomTables() {
        var state: UInt64 = 45
        func next(_ bound: Int) -> Int {
            state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            return Int(state >> 33) % bound
        }
        var failures: [String] = []
        for _ in 0..<300 {
            let count = next(200) + 1
            let top = next(count)
            var table = [Int](repeating: 0, count: count)
            table[top] = 1_000_000
            if top > 0 { for i in stride(from: top - 1, through: 0, by: -1) { table[i] = table[i + 1] - 1 - next(50) } }
            if top + 1 < count { for i in (top + 1)..<count { table[i] = table[i - 1] - 1 - next(50) } }
            let result = search(0...(count - 1)) { table[$0] }
            if failures.count < 3 && (result.peak != top || result.outside || result.calls > budget(count)) {
                failures.append("\(table): got \(result.peak) after \(result.calls) calls")
            }
        }
        #expect(failures.isEmpty, "\(failures)")
    }

    @Test("Two trillion prices: about 80 evaluations, where ternary search needs about 140")
    func huge() {
        let range = -1_000_000_000_000...1_000_000_000_000
        for top in [range.lowerBound, -123_456_789_012, 0, 1, 999_999_999_999, range.upperBound] {
            let result = search(range) { -abs($0 - top) }
            #expect(result.peak == top)
            #expect(result.calls <= budget(range.count), "peak at \(top): \(result.calls) calls")
            #expect(!result.outside)
        }
    }
}
