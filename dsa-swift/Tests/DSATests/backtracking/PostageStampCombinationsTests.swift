import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct StampRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct PostageStampCombinationsTests {
    /// Sorts each combination, then the list, so answers in any order compare equal
    private func canonical(_ combinations: [[Int]]) -> [[Int]] {
        combinations.map { $0.sorted() }.sorted { $0.lexicographicallyPrecedes($1) }
    }

    /// Decides how many copies of each stamp to use, one stamp at a time: a different tree, same answers
    private func reference(_ stamps: [Int], _ postage: Int) -> [[Int]] {
        var result: [[Int]] = []
        var chosen: [Int] = []
        func use(_ index: Int, _ remaining: Int) {
            if index == stamps.count {
                if remaining == 0 { result.append(chosen) }
                return
            }
            var copies = 0
            while copies * stamps[index] <= remaining {
                chosen += Array(repeating: stamps[index], count: copies)
                use(index + 1, remaining - copies * stamps[index])
                chosen.removeLast(copies)
                copies += 1
            }
        }
        use(0, postage)
        return canonical(result)
    }

    @Test("Examples and small cases", arguments: [
        ([4, 6, 9], 12, [[4, 4, 4], [6, 6]]),
        ([2, 5], 11, [[2, 2, 2, 5]]),
        ([3, 5, 8], 16, [[3, 3, 5, 5], [3, 5, 8], [8, 8]]),
        ([5], 3, []),
        ([7], 7, [[7]]),
        ([9, 2], 4, [[2, 2]]),
    ] as [([Int], Int, [[Int]])])
    func examples(stamps: [Int], postage: Int, expected: [[Int]]) {
        #expect(canonical(PostageStampCombinations.combinations(stamps: stamps, postage: postage)) == canonical(expected))
    }

    @Test("Matches a copies-per-stamp search on 300 random cases")
    func randomSmall() {
        var random = StampRandom(seed: 48)
        for _ in 0..<300 {
            let stamps = Array((2...15).shuffled(using: &random).prefix(Int.random(in: 1...5, using: &random)))
            let postage = Int.random(in: 1...30, using: &random)
            #expect(canonical(PostageStampCombinations.combinations(stamps: stamps, postage: postage)) == reference(stamps, postage),
                    "stamps \(stamps), postage \(postage)")
        }
    }

    @Test("Twelve unsorted stamp values and a postage of 60")
    func larger() {
        let stamps = [37, 2, 19, 5, 31, 11, 3, 29, 7, 23, 13, 17]
        let result = PostageStampCombinations.combinations(stamps: stamps, postage: 60)
        #expect(canonical(result) == reference(stamps, 60))
        #expect(result.allSatisfy { $0.reduce(0, +) == 60 })
    }
}
