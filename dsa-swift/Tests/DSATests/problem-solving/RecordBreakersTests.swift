import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RecordBreakersTests {
    @Test("Finds every record", arguments: [
        ([3, 1, 4, 1, 5, 9, 2, 6], [0, 2, 4, 5]),
        ([-8, -3, -5], [0, 1]),
        ([1, 2, 3, 4], [0, 1, 2, 3]),
        ([4, 3, 2, 1], [0]),
        ([2, 7, 1, 8, 2, 8], [0, 1, 3]),
        ([42], [0]),
    ])
    func records(scores: [Int], expected: [Int]) {
        #expect(RecordBreakers.recordIndices(in: scores) == expected)
    }

    @Test("Ties don't set a record")
    func ties() {
        #expect(RecordBreakers.recordIndices(in: [5, 5, 5]) == [0])
        #expect(RecordBreakers.recordIndices(in: [3, 6, 6, 7, 7]) == [0, 1, 3])
    }

    @Test("An empty list has no records")
    func empty() {
        #expect(RecordBreakers.recordIndices(in: []) == [])
    }

    @Test("Works at the extremes of the allowed values")
    func extremes() {
        #expect(RecordBreakers.recordIndices(in: [-1_000_000_000, 0, 1_000_000_000, 999_999_999]) == [0, 1, 2])
    }

    @Test("Matches a brute force on many small lists")
    func matchesBruteForce() {
        var firstMismatch: [Int]? = nil
        for seed in 0..<300 {
            let scores = (0..<(seed % 9)).map { ($0 * 7 + seed * 13) % 11 - 5 }
            var expected: [Int] = []
            for i in scores.indices where scores.prefix(i).allSatisfy({ $0 < scores[i] }) {
                expected.append(i)
            }
            if RecordBreakers.recordIndices(in: scores) != expected {
                firstMismatch = firstMismatch ?? scores
            }
        }
        #expect(firstMismatch == nil, "the first list where the answer differs from the brute force")
    }

    @Test("Stays fast on 100,000 rising scores")
    func large() {
        let scores = Array(0..<100_000)
        let records = RecordBreakers.recordIndices(in: scores)
        #expect(records.count == 100_000)
        #expect(records.last == 99_999)
    }
}
