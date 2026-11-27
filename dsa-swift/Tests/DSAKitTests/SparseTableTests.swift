import Testing
import DSAKit

@Suite struct SparseTableTests {
    /// A tiny deterministic generator, so the random tests check the same arrays every run.
    private struct Steps {
        private var state: UInt64

        init(seed: UInt64) {
            state = seed
        }

        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    private func gcd(_ a: Int, _ b: Int) -> Int {
        b == 0 ? a : gcd(b, a % b)
    }

    @Test("The example from the documentation")
    func documentedExample() {
        let temperatures = [14, 9, 17, 5, 12, 20, 8]
        let coldest = SparseTable(temperatures, combine: min)
        #expect(coldest.query(1...4) == 5)
        #expect(coldest.query(5...6) == 8)
        #expect(coldest.query(0...0) == 14)
        #expect(coldest.query(0...6) == 5)
        #expect(SparseTable.maximum(temperatures).query(0...2) == 17)
        #expect(SparseTable([12, 18, 30, 45], combine: gcd).query(0...2) == 6)
        #expect(SparseTable([12, 18, 30, 45], combine: gcd).query(2...3) == 15)
    }

    @Test("A single element answers every query with itself")
    func singleElement() {
        let table = SparseTable.minimum([42])
        #expect(table.count == 1)
        #expect(table.levelCount == 1)
        #expect(table.query(0...0) == 42)
        #expect(table.query(0..<1) == 42)
        #expect(table[0] == 42)
        #expect(Array(table) == [42])
    }

    @Test("An empty table has no elements")
    func empty() {
        let table = SparseTable.maximum([Int]())
        #expect(table.isEmpty)
        #expect(table.count == 0)
        #expect(table.levelCount == 1)
        #expect(Array(table) == [])
    }

    @Test("Every range of small arrays matches a direct scan, for min, max and gcd")
    func allRangesSmall() {
        var steps = Steps(seed: 62)
        for n in 1...40 {
            let values = (0..<n).map { _ in steps.next(below: 200) - 100 }
            let positives = values.map { abs($0) + 1 }
            let low = SparseTable.minimum(values)
            let high = SparseTable(values, combine: max)
            let shared = SparseTable(positives, combine: gcd)
            for left in 0..<n {
                for right in left..<n {
                    let slice = values[left...right]
                    #expect(low.query(left...right) == slice.min()!)
                    #expect(high.query(left...right) == slice.max()!)
                    #expect(low.query(left..<(right + 1)) == slice.min()!)
                    #expect(shared.query(left...right) == positives[left...right].reduce(0, gcd))
                }
            }
        }
    }

    @Test("Ranges whose length is an exact power of two use a single block")
    func powerOfTwoLengths() {
        let values = Array((0..<64).reversed())          // 63, 62, ..., 0
        let table = SparseTable.minimum(values)
        #expect(table.levelCount == 7)                    // block lengths 1, 2, 4, ..., 64
        for level in 0..<7 {
            let length = 1 << level
            for start in 0...(64 - length) {
                #expect(table.query(start...(start + length - 1)) == values[start + length - 1])
            }
        }
    }

    @Test("Random queries on a large array match a direct scan")
    func largeRandom() {
        var steps = Steps(seed: 2_026)
        let n = 50_000
        let values = (0..<n).map { _ in steps.next(below: 1_000_000_000) }
        let low = SparseTable.minimum(values)
        let high = SparseTable.maximum(values)
        #expect(low.levelCount == 16)                     // 2^15 = 32,768 ≤ 50,000 < 65,536
        for _ in 0..<300 {
            let a = steps.next(below: n)
            let b = steps.next(below: n)
            let range = min(a, b)...max(a, b)
            #expect(low.query(range) == values[range].min()!)
            #expect(high.query(range) == values[range].max()!)
        }
        #expect(low.query(0...(n - 1)) == values.min()!)
    }

    @Test("Works for any element type, such as strings and bitwise or")
    func otherTypes() {
        let words = ["pear", "apple", "fig", "kiwi", "banana"]
        let first = SparseTable.minimum(words)
        #expect(first.query(0...4) == "apple")
        #expect(first.query(2...4) == "banana")
        #expect(SparseTable.maximum(words).query(1...3) == "kiwi")

        let flags = [0b0001, 0b0100, 0b0010, 0b1000]
        let anySet = SparseTable(flags, combine: |)
        #expect(anySet.query(0...2) == 0b0111)
        #expect(anySet.query(1...3) == 0b1110)
    }

    @Test("Behaves as a collection of the original elements")
    func collection() {
        let table = SparseTable.minimum([5, 3, 8, 1])
        #expect(table.count == 4)
        #expect(table[2] == 8)
        #expect(table.map { $0 * 2 } == [10, 6, 16, 2])
        #expect(table.description == "SparseTable([5, 3, 8, 1])")
    }
}
