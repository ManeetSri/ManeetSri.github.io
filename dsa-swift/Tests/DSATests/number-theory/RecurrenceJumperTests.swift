import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct RecurrenceRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct RecurrenceJumperTests {
    private let mod = 1_000_000_007

    private func reduce(_ value: Int) -> Int {
        ((value % mod) + mod) % mod
    }

    /// Step the recurrence one term at a time: slow, but clearly right
    private func walk(_ n: Int, _ coefficients: [Int], _ initial: [Int]) -> Int {
        var terms = initial.map(reduce)
        let c = coefficients.map(reduce)
        while terms.count <= n {
            var next = 0
            for j in 0..<c.count {
                next = (next + c[j] * terms[terms.count - 1 - j]) % mod
            }
            terms.append(next)
        }
        return terms[n]
    }

    /// A different fast method: compute xⁿ modulo the characteristic polynomial, then combine the
    /// first k terms with that remainder's coefficients. O(k² log n).
    private func polynomialReference(_ n: Int, _ coefficients: [Int], _ initial: [Int]) -> Int {
        let k = coefficients.count
        let c = coefficients.map(reduce)
        let a = initial.map(reduce)
        // Multiply two polynomials of degree < k, then reduce with xᵏ = c₁xᵏ⁻¹ + … + c_k
        func mulReduce(_ p: [Int], _ q: [Int]) -> [Int] {
            var product = Array(repeating: 0, count: 2 * k)
            for i in 0..<k where p[i] != 0 {
                for j in 0..<k {
                    product[i + j] = (product[i + j] + p[i] * q[j]) % mod
                }
            }
            for degree in stride(from: 2 * k - 1, through: k, by: -1) where product[degree] != 0 {
                for j in 1...k {
                    product[degree - j] = (product[degree - j] + product[degree] * c[j - 1]) % mod
                }
                product[degree] = 0
            }
            return Array(product[0..<k])
        }
        var result = Array(repeating: 0, count: k)
        result[0] = 1
        var base = Array(repeating: 0, count: k)
        if k == 1 { base[0] = c[0] } else { base[1] = 1 }
        var e = n
        while e > 0 {
            if e & 1 == 1 { result = mulReduce(result, base) }
            base = mulReduce(base, base)
            e >>= 1
        }
        var answer = 0
        for i in 0..<k {
            answer = (answer + result[i] * a[i]) % mod
        }
        return answer
    }

    @Test("Examples", arguments: [
        (10, [1, 1], [0, 1], 55),
        (1_000, [1, 1], [0, 1], 517_691_607),
        (1_000_000_000_000_000_000, [1, 1], [0, 1], 209_783_453),
        (1_000_000_000_000_000_000, [1, 1, 1], [0, 1, 1], 926_781_415),
        (6, [1, 1, 1], [0, 1, 1], 13),
        (0, [5, 7], [3, 4], 3),
        (1, [5, 7], [3, 4], 4),
        (2, [5, 7], [3, 4], 41),
        (1_000_000_000_000_000_001, [-1], [5], 1_000_000_002),
        (123_456_789_012_345_678, [0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 9),
        (1_000_000_000_000_000_000, [3, -1, 4, -1, 5], [2, -7, 1, 8, -2], 437_969_728),
        (7, [1], [-4], 1_000_000_003),
    ])
    func examples(n: Int, coefficients: [Int], initial: [Int], expected: Int) {
        #expect(RecurrenceJumper.term(n, coefficients: coefficients, initial: initial) == expected)
    }

    @Test("Powers of two: a(n) = 2·a(n − 1)")
    func powersOfTwo() {
        var expected = 3
        for n in 0...200 {
            #expect(RecurrenceJumper.term(n, coefficients: [2], initial: [3]) == expected, "n = \(n)")
            expected = expected * 2 % mod
        }
    }

    @Test("Matches stepping term by term on random recurrences")
    func randomSmall() {
        var random = RecurrenceRandom(seed: 88)
        for _ in 0..<150 {
            let k = Int.random(in: 1...10, using: &random)
            let coefficients = (0..<k).map { _ in Int.random(in: -1_000_000_000...1_000_000_000, using: &random) }
            let initial = (0..<k).map { _ in Int.random(in: -1_000_000_000...1_000_000_000, using: &random) }
            let n = Int.random(in: 0...1_500, using: &random)
            #expect(RecurrenceJumper.term(n, coefficients: coefficients, initial: initial) == walk(n, coefficients, initial),
                    "n = \(n), coefficients \(coefficients), initial \(initial)")
        }
    }

    @Test("Matches a different fast method for n up to 10¹⁸")
    func randomHuge() {
        var random = RecurrenceRandom(seed: 1_000_000_007)
        for _ in 0..<30 {
            let k = Int.random(in: 1...10, using: &random)
            let coefficients = (0..<k).map { _ in Int.random(in: -1_000_000_000...1_000_000_000, using: &random) }
            let initial = (0..<k).map { _ in Int.random(in: -1_000_000_000...1_000_000_000, using: &random) }
            let n = Int.random(in: 0...1_000_000_000_000_000_000, using: &random)
            #expect(RecurrenceJumper.term(n, coefficients: coefficients, initial: initial)
                    == polynomialReference(n, coefficients, initial),
                    "n = \(n), coefficients \(coefficients), initial \(initial)")
        }
    }
}
