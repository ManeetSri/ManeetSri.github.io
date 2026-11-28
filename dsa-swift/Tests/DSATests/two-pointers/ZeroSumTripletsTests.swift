import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ZeroSumTripletsTests {
    /// Sorts the list of triplets so answers in any order compare equal.
    private static func normalised(_ triplets: [[Int]]) -> [[Int]] {
        triplets.sorted { $0.lexicographicallyPrecedes($1) }
    }

    private static func slowTriplets(_ numbers: [Int]) -> [[Int]] {
        var found = Set<[Int]>()
        for i in numbers.indices {
            for j in (i + 1)..<numbers.count {
                for k in (j + 1)..<numbers.count where numbers[i] + numbers[j] + numbers[k] == 0 {
                    found.insert([numbers[i], numbers[j], numbers[k]].sorted())
                }
            }
        }
        return normalised(Array(found))
    }

    @Test("Finds every distinct triplet", arguments: [
        ([-2, 0, 1, 1, 2, -1, -4, 2], [[-4, 2, 2], [-2, 0, 2], [-2, 1, 1], [-1, 0, 1]]),
        ([0, 0, 0, 0], [[0, 0, 0]]),
        ([3, -1, -1, 0, 1, -2, 2], [[-2, -1, 3], [-2, 0, 2], [-1, -1, 2], [-1, 0, 1]]),
        ([-5, 2, 3], [[-5, 2, 3]]),
        ([1, 2, 3], []),
        ([-1, -1, -1], []),
        ([0, 0], []),
        ([], []),
    ])
    func triplets(numbers: [Int], expected: [[Int]]) {
        #expect(Self.normalised(ZeroSumTriplets.triplets(in: numbers)) == expected)
    }

    @Test("Each triplet is in non-decreasing order")
    func eachTripletSorted() {
        let result = ZeroSumTriplets.triplets(in: [5, -3, -2, 1, 2, -1, 0, -4, 4])
        #expect(!result.isEmpty)
        #expect(result.allSatisfy { $0.count == 3 && $0 == $0.sorted() })
    }

    @Test("Matches a brute force on many small arrays with repeats")
    func matchesBruteForce() {
        var firstMismatch: [Int]? = nil
        for seed in 0..<300 {
            let numbers = (0..<(seed % 9)).map { ($0 * 5 + seed * 7) % 7 - 3 }
            if Self.normalised(ZeroSumTriplets.triplets(in: numbers)) != Self.slowTriplets(numbers) {
                firstMismatch = firstMismatch ?? numbers
            }
        }
        #expect(firstMismatch == nil, "the first array where the answer differs from the brute force")
    }

    @Test("Stays fast on 3,000 numbers")
    func large() {
        // Values of the form 4k + 1, each twice: any three add up to 3 more than a multiple of 4,
        // so only the planted zeros make a triplet.
        let base = (-750..<750).map { 4 * $0 + 1 }
        let numbers = base + base.reversed() + [0, 0, 0]
        #expect(ZeroSumTriplets.triplets(in: numbers) == [[0, 0, 0]])

        // Adding one -2 creates the triplets [-2, a, 2 - a] for a = -2995, -2991, …, 1: 750 of them
        let withMinusTwo = numbers + [-2]
        let result = ZeroSumTriplets.triplets(in: withMinusTwo)
        #expect(result.count == 751)
        #expect(Set(result).count == result.count)
        #expect(result.allSatisfy { $0.count == 3 && $0.reduce(0, +) == 0 })
    }
}
