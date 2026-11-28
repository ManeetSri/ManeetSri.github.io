import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ShortestSumWindowTests {
    @Test("Finds the shortest window reaching the target", arguments: [
        ([5, 1, 3, 5, 10, 7, 4, 9, 2, 8], 15, 2),
        ([4, 2, 6, 1], 6, 1),
        ([3, 1, 4, 1, 5], 9, 3),
        ([1, 2, 3, 4, 5], 15, 5),
        ([1, 4, 2, 2, 3, 1, 5], 8, 3),
        ([10], 10, 1),
        ([2, 2, 2, 2], 4, 2),
    ])
    func examples(values: [Int], target: Int, expected: Int) {
        #expect(ShortestSumWindow.minLength(values, atLeast: target) == expected)
    }

    @Test("Returns 0 when no window is big enough", arguments: [
        ([1, 1, 1, 1], 5),
        ([Int](), 3),
        ([9], 10),
    ])
    func noWindow(values: [Int], target: Int) {
        #expect(ShortestSumWindow.minLength(values, atLeast: target) == 0)
    }

    @Test("Matches a brute force on many small arrays")
    func matchesBruteForce() {
        var firstMismatch: [Int]? = nil
        for seed in 0..<300 {
            let values = (0..<(seed % 10)).map { ($0 * 13 + seed * 7) % 9 + 1 }
            let target = seed % 25 + 1
            var best = 0
            for start in values.indices {
                var sum = 0
                for end in start..<values.count {
                    sum += values[end]
                    if sum >= target {
                        if best == 0 || end - start + 1 < best { best = end - start + 1 }
                        break
                    }
                }
            }
            if ShortestSumWindow.minLength(values, atLeast: target) != best {
                firstMismatch = firstMismatch ?? values
            }
        }
        #expect(firstMismatch == nil, "the first array where the answer differs from the brute force")
    }

    @Test("Stays fast on 100,000 values")
    func large() {
        let ones = [Int](repeating: 1, count: 100_000)
        #expect(ShortestSumWindow.minLength(ones, atLeast: 50_000) == 50_000)
        #expect(ShortestSumWindow.minLength(ones, atLeast: 100_001) == 0)
        var spiky = ones
        spiky[70_000] = 10_000
        #expect(ShortestSumWindow.minLength(spiky, atLeast: 10_002) == 3)
    }
}
