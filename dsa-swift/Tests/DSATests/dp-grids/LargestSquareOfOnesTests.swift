import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct PlotRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct LargestSquareOfOnesTests {
    /// Check every square cell by cell
    private func everySquare(_ field: [[Int]]) -> Int {
        let rows = field.count, cols = field[0].count
        var largest = 0
        for top in 0..<rows {
            for left in 0..<cols {
                var size = 1
                while top + size <= rows && left + size <= cols
                        && (top..<(top + size)).allSatisfy({ r in (left..<(left + size)).allSatisfy { field[r][$0] == 1 } }) {
                    largest = max(largest, size)
                    size += 1
                }
            }
        }
        return largest * largest
    }

    /// A different method: binary search on the side, checking squares with 2D prefix sums
    private func prefixSums(_ field: [[Int]]) -> Int {
        let rows = field.count, cols = field[0].count
        var sum = Array(repeating: Array(repeating: 0, count: cols + 1), count: rows + 1)
        for r in 0..<rows {
            for c in 0..<cols {
                sum[r + 1][c + 1] = field[r][c] + sum[r][c + 1] + sum[r + 1][c] - sum[r][c]
            }
        }
        func exists(_ k: Int) -> Bool {
            if k == 0 { return true }
            for r in k...rows {
                for c in k...cols where sum[r][c] - sum[r - k][c] - sum[r][c - k] + sum[r - k][c - k] == k * k {
                    return true
                }
            }
            return false
        }
        var low = 0, high = min(rows, cols)
        while low < high {
            let mid = (low + high + 1) / 2
            if exists(mid) { low = mid } else { high = mid - 1 }
        }
        return low * low
    }

    @Test("Examples and small fields", arguments: [
        ([[1, 0, 1, 1, 1], [1, 1, 1, 1, 1], [0, 1, 1, 1, 1], [1, 1, 1, 1, 0]], 9),
        ([[0]], 0),
        ([[1]], 1),
        ([[1, 1], [1, 1]], 4),
        ([[1, 1, 0], [1, 1, 1], [0, 1, 1]], 4),
        ([[0, 1], [1, 0]], 1),
        ([[1, 1, 1, 1]], 1),
        ([[0, 0, 0], [0, 0, 0]], 0),
        ([[1, 1, 1], [1, 0, 1], [1, 1, 1]], 1),
    ] as [([[Int]], Int)])
    func examples(field: [[Int]], expected: Int) {
        #expect(LargestSquareOfOnes.largestArea(field) == expected)
    }

    @Test("Matches checking every square on 400 small random fields")
    func randomSmall() {
        var random = PlotRandom(seed: 25)
        for _ in 0..<400 {
            let rows = Int.random(in: 1...8, using: &random)
            let cols = Int.random(in: 1...8, using: &random)
            let clearChance = Int.random(in: 30...100, using: &random)
            let field = (0..<rows).map { _ in
                (0..<cols).map { _ in Int.random(in: 0..<100, using: &random) < clearChance ? 1 : 0 }
            }
            #expect(LargestSquareOfOnes.largestArea(field) == everySquare(field))
        }
    }

    @Test("300 × 300 fields match binary search with prefix sums", arguments: [80, 90, 97])
    func largeRandom(clearChance: Int) {
        var random = PlotRandom(seed: UInt64(clearChance))
        let field = (0..<300).map { _ in
            (0..<300).map { _ in Int.random(in: 0..<100, using: &random) < clearChance ? 1 : 0 }
        }
        #expect(LargestSquareOfOnes.largestArea(field) == prefixSums(field))
    }

    @Test("Planted squares in large fields")
    func planted() {
        let allClear = Array(repeating: Array(repeating: 1, count: 300), count: 300)
        #expect(LargestSquareOfOnes.largestArea(allClear) == 90_000)

        // A checkerboard has no 2 × 2 square, until a 40 × 40 clear block is planted in it
        var board = (0..<300).map { r in (0..<300).map { c in (r + c) % 2 } }
        #expect(LargestSquareOfOnes.largestArea(board) == 1)
        for r in 123..<163 {
            for c in 201..<241 {
                board[r][c] = 1
            }
        }
        #expect(LargestSquareOfOnes.largestArea(board) == 1_600)

        // A wide, short field: the square is limited by the height
        let strip = Array(repeating: Array(repeating: 1, count: 300), count: 3)
        #expect(LargestSquareOfOnes.largestArea(strip) == 9)
    }
}
