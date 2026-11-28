import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RunningMedianTests {
    typealias Tracker = RunningMedian.MedianTracker

    private func medians(_ values: [Int]) -> [Double?] {
        var tracker = Tracker()
        return values.map { value in
            tracker.add(value)
            return tracker.median
        }
    }

    @Test("Nothing added yet")
    func empty() {
        let tracker = Tracker()
        #expect(tracker.median == nil)
        #expect(tracker.count == 0)
    }

    @Test("The examples", arguments: [
        ([6, 2, 9, 4], [6.0, 4.0, 6.0, 5.0]),
        ([5, 15, 1, 3], [5.0, 10.0, 5.0, 4.0]),
        ([1, 2], [1.0, 1.5]),
        ([-3, -8, -1], [-3.0, -5.5, -3.0]),
        ([7, 7, 7, 7], [7.0, 7.0, 7.0, 7.0]),
        ([10, 9, 8, 7, 6], [10.0, 9.5, 9.0, 8.5, 8.0]),
    ])
    func examples(values: [Int], expected: [Double]) {
        #expect(medians(values) == expected.map { Optional($0) })
    }

    @Test("Counts what's been added")
    func count() {
        var tracker = Tracker()
        for value in [4, 1, 8] {
            tracker.add(value)
        }
        #expect(tracker.count == 3)
    }

    @Test("Agrees with sorting after every value")
    func matchesSorting() {
        var mismatches = 0
        for seed in 1...40 {
            let values = (0..<150).map { ($0 * 7_919 + seed * 104_729) % (5 + seed * 3) - seed }
            let got = medians(values)
            for i in values.indices {
                let sorted = values[...i].sorted()
                let n = sorted.count
                let expected = n % 2 == 1 ? Double(sorted[n / 2]) : (Double(sorted[n / 2 - 1]) + Double(sorted[n / 2])) / 2
                if got[i] != expected { mismatches += 1 }
            }
        }
        #expect(mismatches == 0)
    }

    @Test("200,000 values with a median after each")
    func large() {
        let values = (0..<200_000).map { ($0 * 7_919 + 13) % 1_000_003 - 500_000 }
        let got = medians(values)
        let twiceTotal = got.reduce(0) { $0 + Int(($1 ?? 0) * 2) }
        #expect(twiceTotal == -301_008_558)
        #expect(got[100_000] == -59.0)
        #expect(got.last == -63.5)
    }

    @Test("200,000 rising, falling and equal values")
    func largeShapes() {
        let rising = medians(Array(1...200_000))
        #expect(rising[99_999] == 50_000.5)
        #expect(rising.last == 100_000.5)
        let falling = medians(Array((1...200_000).reversed()))
        #expect(falling[0] == 200_000)
        #expect(falling.last == 100_000.5)
        let equal = medians(Array(repeating: -42, count: 200_000))
        #expect(equal.allSatisfy { $0 == -42 })
    }
}
