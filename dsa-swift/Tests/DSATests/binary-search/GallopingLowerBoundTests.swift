import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// Runs the search against `readings` (count readings, reading(i) for each), counting the reads.
/// Returns the answer, the number of reads and whether any read used a negative index.
private func search(_ target: Int, count: Int, _ reading: (Int) -> Int) -> (answer: Int?, reads: Int, negative: Bool) {
    var reads = 0
    var negative = false
    let answer = GallopingLowerBound.firstIndex(atLeast: target) { index in
        reads += 1
        if index < 0 { negative = true; return nil }
        return index < count ? reading(index) : nil
    }
    return (answer, reads, negative)
}

private func search(_ target: Int, in readings: [Int]) -> (answer: Int?, reads: Int, negative: Bool) {
    search(target, count: readings.count) { readings[$0] }
}

/// The reads allowed when the first reading ≥ target (or the end) is at position p.
private func budget(_ p: Int) -> Int {
    2 * (Int.bitWidth - (p + 1).leadingZeroBitCount) + 4
}

@Suite struct GallopingLowerBoundTests {
    @Test("The examples", arguments: [
        ([3, 6, 9, 12, 15, 18], 10, 3 as Int?),
        ([3, 6, 9, 12, 15, 18], 9, 2),
        ([3, 6, 9, 12, 15, 18], -5, 0),
        ([3, 6, 9, 12, 15, 18], 19, nil),
        ([1, 4, 4, 4, 4, 7], 4, 1),
        ([], 0, nil),
    ])
    func examples(readings: [Int], target: Int, expected: Int?) {
        let result = search(target, in: readings)
        #expect(result.answer == expected)
        #expect(!result.negative, "read a negative index")
    }

    @Test("A long run of duplicates: the first one")
    func duplicates() {
        let readings = [1] + Array(repeating: 5, count: 1_000) + [9]
        #expect(search(5, in: readings).answer == 1)
        #expect(search(6, in: readings).answer == 1_001)
        #expect(search(10, in: readings).answer == nil)
        #expect(search(Int.min, in: readings).answer == 0)
    }

    @Test("Extremes of Int")
    func extremes() {
        #expect(search(Int.max, in: [Int.min, 0, Int.max]).answer == 2)
        #expect(search(Int.min, in: [Int.min, Int.min]).answer == 0)
        #expect(search(Int.max, in: [Int.min, Int.max - 1]).answer == nil)
    }

    @Test("Every target in every small archive, within the read budget")
    func everyPosition() {
        var failures: [String] = []
        for count in 0...70 {
            let readings = (0..<count).map { $0 * 2 }                 // 0, 2, 4, …
            for target in -1...(2 * count + 1) {
                let expectedPosition = readings.firstIndex { $0 >= target } ?? count
                let expected: Int? = expectedPosition < count ? expectedPosition : nil
                let result = search(target, in: readings)
                if failures.count < 3 && (result.answer != expected || result.negative || result.reads > budget(expectedPosition)) {
                    failures.append("target \(target) in 0, 2, … (\(count) readings): got \(String(describing: result.answer)) after \(result.reads) reads; expected \(String(describing: expected)) within \(budget(expectedPosition))")
                }
            }
        }
        #expect(failures.isEmpty, "\(failures)")
    }

    @Test("Random archives with duplicates match the slow answer")
    func random() {
        var state: UInt64 = 2_028
        func next(_ bound: Int) -> Int {
            state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            return Int(state >> 33) % bound
        }
        var failures: [String] = []
        for _ in 0..<300 {
            var readings: [Int] = []
            var value = next(20) - 10
            for _ in 0..<next(300) {
                value += next(3)                                       // steps of 0, 1 or 2
                readings.append(value)
            }
            for _ in 0..<10 {
                let target = next(700) - 20
                let position = readings.firstIndex { $0 >= target } ?? readings.count
                let expected: Int? = position < readings.count ? position : nil
                let result = search(target, in: readings)
                if failures.count < 3 && (result.answer != expected || result.negative || result.reads > budget(position)) {
                    failures.append("target \(target), \(readings.count) readings: got \(String(describing: result.answer)) after \(result.reads) reads; expected \(String(describing: expected)) within \(budget(position))")
                }
            }
        }
        #expect(failures.isEmpty, "\(failures)")
    }

    @Test("A hundred million readings, each value three times: a few dozen reads each")
    func large() {
        let n = 100_000_000
        let reading = { (i: Int) in i / 3 }                           // 0, 0, 0, 1, 1, 1, 2, …
        for target in [0, 1, 2, 1_000, 123_456, 9_999_999, 33_333_333, 33_333_334, -7] {
            let position = min(max(0, 3 * target), n)
            let expected: Int? = position < n ? position : nil
            let result = search(target, count: n, reading)
            #expect(result.answer == expected, "target \(target)")
            #expect(result.reads <= budget(position), "target \(target): \(result.reads) reads")
            #expect(!result.negative)
        }
    }
}
