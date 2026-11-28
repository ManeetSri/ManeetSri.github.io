import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct MajorityVoteTests {
    @Test("Finds the majority", arguments: [
        ([3, 1, 3], 3),
        ([2, 2, 1, 1, 2], 2),
        ([7], 7),
        ([5, 5], 5),
        ([1, 9, 9, 4, 9, 9, 2], 9),
        ([-4, 0, -4, -4], -4),
        ([0, 0, 0, 1, 2], 0),
        ([8, 8, 8, 1, 1, 1, 8], 8),
    ])
    func finds(numbers: [Int], expected: Int) {
        #expect(MajorityVote.majority(in: numbers) == expected)
    }

    @Test("Returns nil when no value is a majority", arguments: [
        [Int](),
        [1, 2],
        [4, 4, 1, 1],
        [1, 2, 3],
        [6, 6, 6, 2, 2, 2],
        [1, 2, 3, 3],
        [0, 5, 0, 5, 7],
    ])
    func none(numbers: [Int]) {
        #expect(MajorityVote.majority(in: numbers) == nil)
    }

    @Test("Exactly half is not a majority")
    func exactlyHalf() {
        #expect(MajorityVote.majority(in: [3, 3, 3, 1, 2, 4]) == nil)
        #expect(MajorityVote.majority(in: [3, 3, 3, 1, 2, 4, 3]) == 3)
    }

    @Test("Matches counting on many small arrays")
    func matchesCounting() {
        var firstMismatch: [Int]? = nil
        for seed in 0..<500 {
            let numbers = (0..<(seed % 9)).map { index in index % 3 == 0 ? 1 : (index * seed) % 4 }
            var expected: Int? = nil
            for value in Set(numbers) where numbers.filter({ $0 == value }).count * 2 > numbers.count {
                expected = value
            }
            if MajorityVote.majority(in: numbers) != expected {
                firstMismatch = firstMismatch ?? numbers
            }
        }
        #expect(firstMismatch == nil, "the first array where the answer differs from counting")
    }

    @Test("Stays fast on 100,000 numbers")
    func large() {
        let spread = (0..<100_000).map { index in index % 2 == 0 ? 42 : index }
        #expect(MajorityVote.majority(in: spread) == nil)
        let winning = spread + [42]
        #expect(MajorityVote.majority(in: winning) == 42)
        let late = Array(0..<49_999) + Array(repeating: -1, count: 50_001)
        #expect(MajorityVote.majority(in: late) == -1)
    }
}
