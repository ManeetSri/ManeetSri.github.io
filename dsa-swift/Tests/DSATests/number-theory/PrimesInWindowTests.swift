import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct WindowRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct PrimesInWindowTests {
    /// Trial division: slow, but clearly right
    private func isPrime(_ n: Int) -> Bool {
        if n < 2 { return false }
        if n % 2 == 0 { return n == 2 }
        var d = 3
        while d * d <= n {
            if n % d == 0 { return false }
            d += 2
        }
        return true
    }

    @Test("Examples and small windows", arguments: [
        (1, 30, [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]),
        (100, 130, [101, 103, 107, 109, 113, 127]),
        (1, 1, []),
        (1, 2, [2]),
        (2, 2, [2]),
        (24, 28, []),
        (89, 97, [89, 97]),
        (1_000_000_000_000, 1_000_000_000_100, [1_000_000_000_039, 1_000_000_000_061, 1_000_000_000_063, 1_000_000_000_091]),
    ])
    func examples(low: Int, high: Int, expected: [Int]) {
        #expect(PrimesInWindow.primes(from: low, through: high) == expected)
    }

    @Test("Matches trial division on 300 random windows below 20,000")
    func randomSmall() {
        var random = WindowRandom(seed: 63)
        for _ in 0..<300 {
            let low = Int.random(in: 1...20_000, using: &random)
            let high = min(20_000, low + Int.random(in: 0...400, using: &random))
            #expect(PrimesInWindow.primes(from: low, through: high) == (low...high).filter(isPrime), "[\(low), \(high)]")
        }
    }

    @Test("A window starting at 1 keeps the small primes")
    func fromOne() {
        let primes = PrimesInWindow.primes(from: 1, through: 200_000)
        #expect(primes.count == 17_984)
        #expect(primes.prefix(5) == [2, 3, 5, 7, 11])
        #expect(primes.last == 199_999)
    }

    @Test("Windows of a million near 10¹²")
    func large() {
        let trillion = 1_000_000_000_000
        let above = PrimesInWindow.primes(from: trillion, through: trillion + 1_000_000)
        #expect(above.count == 36_249)
        #expect(above.first == 1_000_000_000_039)
        #expect(above.last == 1_000_000_999_999)
        let below = PrimesInWindow.primes(from: trillion - 100_000, through: trillion)
        #expect(below.count == 3_613)
        #expect(below.first == 999_999_900_019)
        #expect(below.last == 999_999_999_989)

        // Spot checks with trial division: some returned numbers, and some numbers between them
        guard above.count == 36_249 else { return }
        var random = WindowRandom(seed: 12)
        for _ in 0..<15 {
            let index = Int.random(in: 0..<above.count, using: &random)
            #expect(isPrime(above[index]))
            if index + 1 < above.count, above[index] + 1 < above[index + 1] {
                let gap = Int.random(in: (above[index] + 1)..<above[index + 1], using: &random)
                #expect(!isPrime(gap))
            }
        }
    }

    @Test("The square of the largest base prime is crossed out")
    func squareOfBasePrime() {
        let square = 999_983 * 999_983
        let primes = PrimesInWindow.primes(from: square - 1_000, through: square + 1_000)
        #expect(!primes.contains(square))
        #expect(primes.count == 59)
        #expect(primes == primes.sorted())
        #expect(primes.allSatisfy { $0 >= square - 1_000 && $0 <= square + 1_000 })
    }
}
