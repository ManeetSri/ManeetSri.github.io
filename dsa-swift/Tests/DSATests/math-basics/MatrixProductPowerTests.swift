import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct MatrixProductPowerTests {
    static let prime = 1_000_000_007

    @Test("Product examples")
    func productExamples() {
        #expect(MatrixProductPower.product([[2, 0, 1]], [[1], [4], [3]]) == [[5]])
        #expect(MatrixProductPower.product([[1], [2]], [[3, 4]]) == [[3, 4], [6, 8]])
        #expect(MatrixProductPower.product([[1, 2], [3, 4]], [[1, 2], [3, 4], [5, 6]]) == nil)
        #expect(MatrixProductPower.product([[1, 2], [3, 4]], [[5, 6], [7, 8]]) == [[19, 22], [43, 50]])
        #expect(MatrixProductPower.product([[5, 6], [7, 8]], [[1, 2], [3, 4]]) == [[23, 34], [31, 46]])
        #expect(MatrixProductPower.product([[1, 0, 2], [0, 3, 1]], [[1, 2], [0, 1], [4, 0]]) == [[9, 2], [4, 3]])
        #expect(MatrixProductPower.product([[-3]], [[7]]) == [[-21]])
    }

    @Test("Shapes that don't fit give nil")
    func mismatchedShapes() {
        #expect(MatrixProductPower.product([[1, 2, 3]], [[1, 2, 3]]) == nil)
        #expect(MatrixProductPower.product([[1], [2]], [[1], [2]]) == nil)
        #expect(MatrixProductPower.product([[1, 2]], [[1, 2]]) == nil)
    }

    @Test("Identity matrices", arguments: [1, 2, 3, 7, 100])
    func identities(size: Int) {
        let m = MatrixProductPower.identity(size: size)
        #expect(m.count == size)
        #expect(m.allSatisfy { $0.count == size })
        let onlyDiagonal = m.enumerated().allSatisfy { i, row in
            row.enumerated().allSatisfy { j, value in value == (i == j ? 1 : 0) }
        }
        #expect(onlyDiagonal)
    }

    @Test("The identity changes nothing on either side")
    func identityIsNeutral() {
        let a = [[3, -1, 4], [1, 5, -9]]
        #expect(MatrixProductPower.product(MatrixProductPower.identity(size: 2), a) == a)
        #expect(MatrixProductPower.product(a, MatrixProductPower.identity(size: 3)) == a)
    }

    @Test("A 60 × 60 product")
    func largeProduct() throws {
        let size = 60
        let a = (0..<size).map { i in (0..<size).map { j in (i * 31 + j * 17) % 201 - 100 } }
        let b = (0..<size).map { i in (0..<size).map { j in (i * 13 + j * 7) % 151 - 75 } }
        let c = try #require(MatrixProductPower.product(a, b))
        try #require(c.count == size && c.allSatisfy { $0.count == size })
        var expected00 = 0
        var expected5959 = 0
        for t in 0..<size {
            expected00 += a[0][t] * b[t][0]
            expected5959 += a[59][t] * b[t][59]
        }
        #expect(c[0][0] == expected00)
        #expect(c[59][59] == expected5959)
    }

    @Test("Power examples")
    func powerExamples() {
        #expect(MatrixProductPower.power([[1, 1], [1, 0]], 10, modulo: Self.prime) == [[89, 55], [55, 34]])
        #expect(MatrixProductPower.power([[2, 0], [0, 3]], 10, modulo: 1_000) == [[24, 0], [0, 49]])
        #expect(MatrixProductPower.power([[5, 7], [1, 9]], 0, modulo: 13) == [[1, 0], [0, 1]])
        #expect(MatrixProductPower.power([[2]], 10, modulo: 1_000) == [[24]])
        #expect(MatrixProductPower.power([[0, 1], [1, 0]], 7, modulo: 10) == [[0, 1], [1, 0]])
        #expect(MatrixProductPower.power([[1, 2], [3, 4]], 5, modulo: Self.prime) == [[1_069, 1_558], [2_337, 3_406]])
        #expect(MatrixProductPower.power([[4, 5], [6, 1]], 1, modulo: 7) == [[4, 5], [6, 1]])
    }

    @Test("Power matches repeated multiplication for small exponents")
    func powerMatchesRepeated() {
        let m = [[2, 1, 0], [1, 3, 1], [0, 1, 4]]
        var expected = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
        for exponent in 0...12 {
            #expect(MatrixProductPower.power(m, exponent, modulo: 997) == expected, "exponent \(exponent)")
            var next = [[0, 0, 0], [0, 0, 0], [0, 0, 0]]
            for i in 0..<3 {
                for j in 0..<3 {
                    for t in 0..<3 {
                        next[i][j] = (next[i][j] + expected[i][t] * m[t][j]) % 997
                    }
                }
            }
            expected = next
        }
    }

    @Test("Exponents up to 10¹⁸")
    func powerHuge() {
        // [0][1] of the Fibonacci matrix to the nth power is F(n)
        let fibonacci = MatrixProductPower.power([[1, 1], [1, 0]], 1_000_000_000_000_000_000, modulo: Self.prime)
        #expect(fibonacci == [[680_057_396, 209_783_453], [209_783_453, 470_273_943]])
        // this matrix's nth power is [[1, n, n(n − 1)/2], [0, 1, n], [0, 0, 1]]
        let steps = MatrixProductPower.power([[1, 1, 0], [0, 1, 1], [0, 0, 1]], 1_000_000_000_000_000_000, modulo: Self.prime)
        #expect(steps == [[1, 49, 1_176], [0, 1, 49], [0, 0, 1]])
        let tribonacci = MatrixProductPower.power([[1, 1, 1], [1, 0, 0], [0, 1, 0]], 50, modulo: Self.prime)
        #expect(tribonacci.first == [230_552_708, 740_208_410, 568_701_031])
    }
}
