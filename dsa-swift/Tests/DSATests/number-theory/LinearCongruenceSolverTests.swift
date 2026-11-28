import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct CongruenceRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct LinearCongruenceSolverTests {
    private func gcd(_ a: Int, _ b: Int) -> Int {
        b == 0 ? a : gcd(b, a % b)
    }

    /// a·b mod m for 0 ≤ a, b < m, exactly
    private func mulMod(_ a: Int, _ b: Int, _ m: Int) -> Int {
        m.dividingFullWidth(a.multipliedFullWidth(by: b)).remainder
    }

    private func reduced(_ value: Int, _ m: Int) -> Int {
        ((value % m) + m) % m
    }

    @Test("Examples and edge cases", arguments: [
        (6, 4, 10, 4),
        (6, 5, 10, nil),
        (3, 1, 11, 4),
        (-3, 1, 11, 7),
        (14, 7, 21, 2),
        (4, -2, 6, 1),
        (0, 0, 7, 0),
        (0, 3, 7, nil),
        (5, 3, 1, 0),
        (12, 18, 30, 4),
        (25, 10, 35, 6),
    ] as [(Int, Int, Int, Int?)])
    func examples(a: Int, b: Int, m: Int, expected: Int?) {
        #expect(LinearCongruenceSolver.smallestSolution(a: a, b: b, modulus: m) == expected)
    }

    @Test("Matches trying every x for every small modulus")
    func bruteForce() {
        for m in 1...24 {
            for a in stride(from: -30, through: 30, by: 1) {
                for b in stride(from: -30, through: 30, by: 3) {
                    let expected = (0..<m).first { reduced(a * $0 - b, m) == 0 }
                    #expect(LinearCongruenceSolver.smallestSolution(a: a, b: b, modulus: m) == expected,
                            "a = \(a), b = \(b), m = \(m)")
                }
            }
        }
    }

    @Test("Values at the edge of the constraints")
    func limits() {
        let m = 1_000_000_000_000_000_000
        // 10¹⁸ − 1 is −1 modulo 10¹⁸, so x = −1 as well
        #expect(LinearCongruenceSolver.smallestSolution(a: m - 1, b: 1, modulus: m) == m - 1)
        // −10¹⁸ is 0 modulo 10¹⁸
        #expect(LinearCongruenceSolver.smallestSolution(a: -m, b: 0, modulus: m) == 0)
        #expect(LinearCongruenceSolver.smallestSolution(a: -m, b: 5, modulus: m) == nil)
        // An even multiplier can't reach an odd target modulo an even modulus
        #expect(LinearCongruenceSolver.smallestSolution(a: 2, b: m - 1, modulus: m) == nil)
        // The inverse of 3 modulo 10¹⁸ + 3 (a prime): 3x = 2·(10¹⁸ + 3) + 1
        let p = 1_000_000_000_000_000_003
        #expect(LinearCongruenceSolver.smallestSolution(a: 3, b: 1, modulus: p) == (2 * p + 1) / 3)
        #expect(LinearCongruenceSolver.smallestSolution(a: -m, b: -m, modulus: p) == 1)
    }

    @Test("Planted answers with moduli near 10¹⁸")
    func planted() {
        var random = CongruenceRandom(seed: 66)
        for _ in 0..<300 {
            // Choose g, a coprime pair (a', m'), and the answer x < m'. Then b = a'·g·x mod g·m'.
            let g = [1, 1, 2, 3, 7, 1_000, 999_983][Int.random(in: 0..<7, using: &random)]
            let reducedModulus = Int.random(in: 2...(1_000_000_000_000_000_000 / g), using: &random)
            var reducedA = Int.random(in: 1..<reducedModulus, using: &random)
            while gcd(reducedA, reducedModulus) != 1 { reducedA = Int.random(in: 1..<reducedModulus, using: &random) }
            let x = Int.random(in: 0..<reducedModulus, using: &random)
            let m = g * reducedModulus
            let a = g * reducedA
            let b = mulMod(a, x, m)
            // Shift a and b by random multiples of m: the answer mustn't change
            let shiftA = a - m * Int.random(in: 0...1, using: &random)
            let shiftB = b - m * Int.random(in: 0...1, using: &random)
            #expect(LinearCongruenceSolver.smallestSolution(a: shiftA, b: shiftB, modulus: m) == x,
                    "a = \(shiftA), b = \(shiftB), m = \(m)")
        }
    }

    @Test("Random big inputs: a returned x solves it and is the smallest, and nil means no solution")
    func properties() {
        var random = CongruenceRandom(seed: 2_026)
        for _ in 0..<400 {
            let m = Int.random(in: 1...1_000_000_000_000_000_000, using: &random)
            let a = Int.random(in: -1_000_000_000_000_000_000...1_000_000_000_000_000_000, using: &random)
            var b = Int.random(in: -1_000_000_000_000_000_000...1_000_000_000_000_000_000, using: &random)
            let g = gcd(reduced(a, m), m)
            if Bool.random(using: &random) { b -= reduced(b, g) }            // make about half solvable
            let answer = LinearCongruenceSolver.smallestSolution(a: a, b: b, modulus: m)
            if reduced(b, m) % g == 0 {
                guard let x = answer else {
                    Issue.record("expected a solution for a = \(a), b = \(b), m = \(m)")
                    continue
                }
                #expect(x >= 0 && x < m / g)                                  // smaller than the gap between solutions
                #expect(mulMod(reduced(a, m), x, m) == reduced(b, m))
            } else {
                #expect(answer == nil, "a = \(a), b = \(b), m = \(m) has no solution")
            }
        }
    }
}
