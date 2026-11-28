import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct StreamKthLargestTests {
    typealias Tracker = StreamKthLargest.KthLargestTracker

    private func answers(k: Int, _ scores: [Int]) -> [Int?] {
        var tracker = Tracker(k: k)
        return scores.map { tracker.add($0) }
    }

    @Test("The examples")
    func examples() {
        #expect(answers(k: 3, [40, 10, 70, 20, 90, 60]) == [nil, nil, 10, 20, 40, 60])
        #expect(answers(k: 1, [5, 3, 8, 8, 1]) == [5, 5, 8, 8, 8])
        #expect(answers(k: 2, [50, 50, 50, 10]) == [nil, 50, 50, 50])
        #expect(answers(k: 4, [-5, -1, -9]) == [nil, nil, nil])
    }

    @Test("Agrees with sorting after every score")
    func matchesSorting() {
        var mismatches = 0
        for k in [1, 2, 5, 17] {
            let scores = (0..<300).map { ($0 * 7_919 + k * 31) % 97 - 40 }
            let got = answers(k: k, scores)
            for i in scores.indices {
                let expected = i + 1 < k ? nil : scores[...i].sorted(by: >)[k - 1]
                if got[i] != expected { mismatches += 1 }
            }
        }
        #expect(mismatches == 0)
    }

    @Test("200,000 scores with k = 50,000")
    func large() {
        let scores = (0..<200_000).map { ($0 * 7_919 + 13) % 1_000_003 }
        let got = answers(k: 50_000, scores)
        #expect(got.prefix(49_999).allSatisfy { $0 == nil })
        #expect(got[49_999] == 7)
        #expect(got[99_999] == 499_941)
        #expect(got[199_999] == 749_918)
        #expect(got.compactMap { $0 }.reduce(0, +) == 80_667_385_242)
    }

    @Test("200,000 rising scores with k = 1, and with k = 200,000")
    func largeExtremes() {
        let rising = Array(1...200_000)
        #expect(answers(k: 1, rising) == rising.map { Optional($0) })
        let all = answers(k: 200_000, rising)
        #expect(all.prefix(199_999).allSatisfy { $0 == nil })
        #expect(all.last == 1)
    }
}
