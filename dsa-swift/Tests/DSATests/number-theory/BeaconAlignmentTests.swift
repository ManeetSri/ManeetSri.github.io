import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct BeaconRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct BeaconAlignmentTests {
    private func gcd(_ a: Int, _ b: Int) -> Int {
        b == 0 ? a : gcd(b, a % b)
    }

    /// Try every time up to the lcm of the periods: slow, but clearly right
    private func bruteForce(_ offsets: [Int], _ periods: [Int]) -> Int? {
        let cycle = periods.reduce(1) { $0 / gcd($0, $1) * $1 }
        return (0..<cycle).first { t in zip(offsets, periods).allSatisfy { t % $0.1 == $0.0 } }
    }

    @Test("Examples and small cases", arguments: [
        ([2, 3, 2], [3, 5, 7], 23),
        ([2, 4], [4, 6], 10),
        ([1, 2], [4, 6], nil),
        ([0, 0], [4, 6], 0),
        ([5], [9], 5),
        ([0], [1], 0),
        ([3, 0], [7, 1], 3),
        ([1, 1, 1], [2, 2, 2], 1),
        ([1, 0], [2, 2], nil),
        ([4, 6, 8], [6, 10, 12], nil),
        ([5, 7, 2], [6, 10, 15], 17),
        ([5, 3, 2], [6, 10, 15], nil),
    ] as [([Int], [Int], Int?)])
    func examples(offsets: [Int], periods: [Int], expected: Int?) {
        #expect(BeaconAlignment.firstSharedFlash(offsets: offsets, periods: periods) == expected)
    }

    @Test("Matches trying every time on 500 small random systems")
    func randomSmall() {
        var random = BeaconRandom(seed: 314)
        for _ in 0..<500 {
            let count = Int.random(in: 1...4, using: &random)
            let periods = (0..<count).map { _ in Int.random(in: 1...12, using: &random) }
            // Half the time, plant a consistent answer; otherwise offsets are random and may clash
            let hidden = Int.random(in: 0..<1_000, using: &random)
            let planted = Bool.random(using: &random)
            let offsets = periods.map { planted ? hidden % $0 : Int.random(in: 0..<$0, using: &random) }
            #expect(BeaconAlignment.firstSharedFlash(offsets: offsets, periods: periods) == bruteForce(offsets, periods),
                    "offsets \(offsets), periods \(periods)")
        }
    }

    @Test("Coprime periods whose product is close to 10¹⁸")
    func largeCoprime() {
        var random = BeaconRandom(seed: 1_001)
        let pairs = [(999_999_937, 1_000_000_007), (1_000_003, 999_999_999_989), (999_999_999_989, 1_000_003),
                     (2, 499_999_999_999_999_999), (999_999_000_001, 999_983)]
        for (p, q) in pairs {
            for _ in 0..<20 {
                let hidden = Int.random(in: 0..<(p * q), using: &random)
                #expect(BeaconAlignment.firstSharedFlash(offsets: [hidden % p, hidden % q], periods: [p, q]) == hidden,
                        "periods \(p) and \(q)")
            }
        }
    }

    @Test("Large periods that share factors")
    func largeShared() {
        var random = BeaconRandom(seed: 7_777)
        let periods = [300_000_000_000_000_000, 200_000_000_000_000_000]   // lcm 6 × 10¹⁷
        #expect(BeaconAlignment.firstSharedFlash(offsets: [100_000_000_000_000_005, 5], periods: periods) == 400_000_000_000_000_005)
        #expect(BeaconAlignment.firstSharedFlash(offsets: [1, 2], periods: periods) == nil)

        // Periods g·p, g·q and g·r with a hidden time below their lcm g·p·q·r
        for _ in 0..<50 {
            let g = Int.random(in: 1...1_000, using: &random)
            let p = 999_983, q = 1_000_003, r = Int.random(in: 1...1_000, using: &random)
            let lcm = g * p * q * (r / gcd(r, p * q))
            let hidden = Int.random(in: 0..<lcm, using: &random)
            let ps = [g * p, g * q, g * r]
            #expect(BeaconAlignment.firstSharedFlash(offsets: ps.map { hidden % $0 }, periods: ps) == hidden)
        }
    }

    @Test("Ten thousand beacons whose periods all divide one lcm")
    func manyBeacons() {
        var random = BeaconRandom(seed: 99)
        // Every period divides L = 2²⁰ · 3¹⁰ · 5⁵ · 7³ · 13, about 8.6 × 10¹⁷
        let primes = [(2, 20), (3, 10), (5, 5), (7, 3), (13, 1)]
        let lcm = primes.reduce(1) { total, pair in total * (0..<pair.1).reduce(1) { value, _ in value * pair.0 } }
        let hidden = Int.random(in: 0..<lcm, using: &random)
        var periods: [Int] = []
        for _ in 0..<10_000 {
            var period = 1
            for (p, e) in primes {
                for _ in 0..<Int.random(in: 0...e, using: &random) { period *= p }
            }
            periods.append(period)
        }
        periods.append(lcm)                       // make sure the full lcm appears
        let offsets = periods.map { hidden % $0 }
        #expect(BeaconAlignment.firstSharedFlash(offsets: offsets, periods: periods) == hidden)

        // One beacon that disagrees by a single step breaks the alignment
        var broken = offsets
        broken[5_000] = (broken[5_000] + 1) % periods[5_000]
        if periods[5_000] > 1 {
            #expect(BeaconAlignment.firstSharedFlash(offsets: broken, periods: periods) == nil)
        }
    }
}
