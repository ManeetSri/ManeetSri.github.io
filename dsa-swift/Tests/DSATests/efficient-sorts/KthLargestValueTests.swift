import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct KthLargestValueTests {
    @Test("Finds the kth largest in small arrays", arguments: [
        ([7, 2, 9, 4, 6], 1, 9),
        ([7, 2, 9, 4, 6], 2, 7),
        ([7, 2, 9, 4, 6], 5, 2),
        ([5, 8, 8, 3, 8, 1], 3, 8),
        ([5, 8, 8, 3, 8, 1], 4, 5),
        ([-4, -9, -1, -6], 2, -4),
        ([3, 3, 3], 2, 3),
        ([10, 20], 2, 10),
        ([42], 1, 42),
    ])
    func small(numbers: [Int], k: Int, expected: Int) {
        #expect(KthLargestValue.kthLargest(in: numbers, k: k) == expected)
    }

    @Test("Agrees with sorting for every k on hundreds of arrays")
    func matchesSorting() {
        var mismatches = 0
        for seed in 1...120 {
            let count = 1 + seed % 30
            let numbers = (0..<count).map { ($0 * 7_919 + seed * 104_729) % (2 + seed % 50) - 10 }
            let descending = numbers.sorted(by: >)
            for k in 1...count where KthLargestValue.kthLargest(in: numbers, k: k) != descending[k - 1] {
                mismatches += 1
            }
        }
        #expect(mismatches == 0)
    }

    @Test("100,000 numbers already in increasing order, and in decreasing order")
    func largeOrdered() {
        let ascending = Array(1...100_000)
        #expect(KthLargestValue.kthLargest(in: ascending, k: 1) == 100_000)
        #expect(KthLargestValue.kthLargest(in: ascending, k: 100_000) == 1)
        #expect(KthLargestValue.kthLargest(in: ascending, k: 25_000) == 75_001)
        let descending = Array(ascending.reversed())
        #expect(KthLargestValue.kthLargest(in: descending, k: 50_000) == 50_001)
    }

    @Test("100,000 copies of one value, and of two values")
    func largeDuplicates() {
        let same = Array(repeating: 6, count: 100_000)
        #expect(KthLargestValue.kthLargest(in: same, k: 1) == 6)
        #expect(KthLargestValue.kthLargest(in: same, k: 77_777) == 6)
        let twoValues = (0..<100_000).map { $0 % 2 == 0 ? 9 : 4 }
        #expect(KthLargestValue.kthLargest(in: twoValues, k: 50_000) == 9)
        #expect(KthLargestValue.kthLargest(in: twoValues, k: 50_001) == 4)
    }

    @Test("100,000 scrambled numbers")
    func largeScrambled() {
        let numbers = (0..<100_000).map { ($0 * 7_919) % 100_000 }    // 0..<100,000, each once
        #expect(KthLargestValue.kthLargest(in: numbers, k: 1) == 99_999)
        #expect(KthLargestValue.kthLargest(in: numbers, k: 30_000) == 70_000)
        #expect(KthLargestValue.kthLargest(in: numbers, k: 100_000) == 0)
    }
}
