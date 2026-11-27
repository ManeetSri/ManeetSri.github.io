import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct StrassenRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct StrassenSevenProductsTests {
    /// Row times column, the standard way
    private func standard(_ a: [[Int]], _ b: [[Int]]) -> [[Int]] {
        let n = a.count
        return (0..<n).map { i in (0..<n).map { j in (0..<n).reduce(0) { $0 + a[i][$1] * b[$1][j] } } }
    }

    /// n³ at or below the cutoff, otherwise seven half-size products
    private func expectedMultiplications(_ n: Int, _ cutoff: Int) -> Int {
        n <= cutoff ? n * n * n : 7 * expectedMultiplications(n / 2, cutoff)
    }

    private func randomMatrix(_ n: Int, using random: inout StrassenRandom) -> [[Int]] {
        (0..<n).map { _ in (0..<n).map { _ in Int.random(in: -1_000...1_000, using: &random) } }
    }

    @Test("The 2 × 2 example from the lesson")
    func lessonExample() {
        let a = [[1, 2], [3, 4]], b = [[5, 6], [7, 8]]
        let strassen = StrassenSevenProducts.multiply(a, b, cutoff: 1)
        #expect(strassen.product == [[19, 22], [43, 50]])
        #expect(strassen.multiplications == 7)
        let plain = StrassenSevenProducts.multiply(a, b, cutoff: 2)
        #expect(plain.product == [[19, 22], [43, 50]])
        #expect(plain.multiplications == 8)
        // The other order gives a different matrix: blocks must keep A on the left
        #expect(StrassenSevenProducts.multiply(b, a, cutoff: 1).product == [[23, 34], [31, 46]])
    }

    @Test("Small cases", arguments: [
        ([[3]], [[-4]], 1, [[-12]], 1),
        ([[3]], [[-4]], 5, [[-12]], 1),
        ([[0, 1], [0, 0]], [[0, 0], [1, 0]], 1, [[1, 0], [0, 0]], 7),
        ([[1, 0], [0, 1]], [[9, -2], [4, 7]], 1, [[9, -2], [4, 7]], 7),
        ([[2, 0], [0, 2]], [[1, 2], [3, 4]], 1, [[2, 4], [6, 8]], 7),
    ] as [([[Int]], [[Int]], Int, [[Int]], Int)])
    func small(a: [[Int]], b: [[Int]], cutoff: Int, product: [[Int]], multiplications: Int) {
        let result = StrassenSevenProducts.multiply(a, b, cutoff: cutoff)
        #expect(result.product == product)
        #expect(result.multiplications == multiplications)
    }

    @Test("4 × 4 with every cutoff", arguments: [(1, 49), (2, 56), (3, 56), (4, 64), (10, 64)])
    func fourByFour(cutoff: Int, multiplications: Int) {
        let a = [[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12], [13, 14, 15, 16]]
        let b = [[2, 0, -1, 3], [1, 4, 0, -2], [0, 1, 5, 1], [-3, 2, 2, 0]]
        let result = StrassenSevenProducts.multiply(a, b, cutoff: cutoff)
        #expect(result.product == standard(a, b))
        #expect(result.multiplications == multiplications)
    }

    @Test("Matches the standard method on 200 random pairs of matrices")
    func randomSmall() {
        var random = StrassenRandom(seed: 1_969)
        for _ in 0..<200 {
            let n = [1, 2, 4, 8, 16][Int.random(in: 0..<5, using: &random)]
            let cutoff = Int.random(in: 1...(n + 2), using: &random)
            let a = randomMatrix(n, using: &random), b = randomMatrix(n, using: &random)
            let result = StrassenSevenProducts.multiply(a, b, cutoff: cutoff)
            #expect(result.product == standard(a, b))
            #expect(result.multiplications == expectedMultiplications(n, cutoff))
        }
    }

    @Test("32 × 32 all the way down, and 128 × 128 with a cutoff of 16")
    func large() {
        var random = StrassenRandom(seed: 2_807)
        let a = randomMatrix(32, using: &random), b = randomMatrix(32, using: &random)
        let deep = StrassenSevenProducts.multiply(a, b, cutoff: 1)
        #expect(deep.product == standard(a, b))
        #expect(deep.multiplications == 16_807)                      // 7⁵, against 32³ = 32,768

        let c = randomMatrix(128, using: &random), d = randomMatrix(128, using: &random)
        let blocked = StrassenSevenProducts.multiply(c, d, cutoff: 16)
        #expect(blocked.product == standard(c, d))
        #expect(blocked.multiplications == 343 * 4_096)              // 7³ products of 16 × 16 blocks
    }
}
