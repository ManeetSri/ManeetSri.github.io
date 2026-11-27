import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct LowestTermsFractionsTests {
    private func gcd(_ a: Int, _ b: Int) -> Int {
        b == 0 ? a : gcd(b, a % b)
    }

    @Test("φ of small and special numbers", arguments: [
        (1, 1), (2, 1), (3, 2), (4, 2), (9, 6), (12, 4), (36, 12), (97, 96), (100, 40),
        (720_720, 138_240),
        (1_000_000_007, 1_000_000_006),
        (999_999_999_989, 999_999_999_988),                 // a prime near 10¹²: the slowest case
        (1_000_000_000_000, 400_000_000_000),
        (549_755_813_888, 274_877_906_944),                 // 2³⁹
        (999_966_000_289, 999_983 * 999_982),               // 999,983²
        (999_985_999_949, 999_982 * 1_000_002),             // 999,983 × 1,000,003
    ])
    func phiValues(n: Int, expected: Int) {
        #expect(LowestTermsFractions.phi(n) == expected)
    }

    @Test("φ matches counting coprime numerators for every n up to 400")
    func phiBruteForce() {
        for n in 1...400 {
            #expect(LowestTermsFractions.phi(n) == (1...n).filter { gcd($0, n) == 1 }.count, "n = \(n)")
        }
    }

    @Test("Counts for small denominators", arguments: [
        (1, 0), (2, 1), (3, 3), (5, 9), (8, 21), (10, 31),
    ])
    func countExamples(n: Int, expected: Int) {
        #expect(LowestTermsFractions.count(maxDenominator: n) == expected)
    }

    @Test("Counts match checking every fraction for denominators up to 150")
    func countBruteForce() {
        var total = 0
        for q in 1...150 {
            for p in stride(from: 1, to: q, by: 1) where gcd(p, q) == 1 {
                total += 1
            }
            #expect(LowestTermsFractions.count(maxDenominator: q) == total, "N = \(q)")
        }
    }

    @Test("Adding one more denominator adds exactly φ of it")
    func consecutive() {
        for n in [997, 1_000, 1_024, 4_096, 9_973, 10_000] {
            #expect(LowestTermsFractions.count(maxDenominator: n) - LowestTermsFractions.count(maxDenominator: n - 1)
                    == LowestTermsFractions.phi(n), "n = \(n)")
        }
    }

    @Test("Denominators up to a million")
    func large() {
        // Working out φ(q) separately for each q would take about 7 × 10⁸ trial divisions
        #expect(LowestTermsFractions.count(maxDenominator: 1_000_000) == 303_963_552_391)
    }
}
