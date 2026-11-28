import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct SwitchRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct SwitchRowFlipsTests {
    /// Try every set of switches to flip, and keep the smallest that leaves the row sorted
    private func everyFlipSet(_ switches: String) -> Int {
        let bits = switches.map { $0 == "1" }
        var best = Int.max
        for mask in 0..<(1 << bits.count) {
            let flipped = bits.indices.map { bits[$0] != (mask & (1 << $0) != 0) }
            if zip(flipped, flipped.dropFirst()).allSatisfy({ !$0 || $1 }) {   // never on then off
                best = min(best, mask.nonzeroBitCount)
            }
        }
        return best
    }

    /// A different method: for each split, the on switches before it plus the off switches after it
    private func everySplit(_ switches: String) -> Int {
        let bits = Array(switches)
        var onBefore = 0
        var offAfter = bits.filter { $0 == "0" }.count
        var best = offAfter
        for bit in bits {
            if bit == "1" { onBefore += 1 } else { offAfter -= 1 }
            best = min(best, onBefore + offAfter)
        }
        return best
    }

    private func randomRow(length: Int, onChance: Int, using random: inout SwitchRandom) -> String {
        String((0..<length).map { _ in Int.random(in: 0..<100, using: &random) < onChance ? Character("1") : Character("0") })
    }

    @Test("Examples and small rows", arguments: [
        ("00110", 1),
        ("010110", 2),
        ("11100", 2),
        ("0000", 0),
        ("", 0),
        ("10", 1),
        ("01", 0),
        ("1", 0),
        ("0", 0),
        ("1010101", 3),
        ("0111111110", 1),
    ])
    func examples(switches: String, expected: Int) {
        #expect(SwitchRowFlips.minimumFlips(switches) == expected)
    }

    @Test("Every row of up to 9 switches matches trying every set of flips")
    func exhaustive() {
        for length in 0...9 {
            for value in 0..<(1 << length) {
                let row = String((0..<length).map { value & (1 << $0) != 0 ? Character("1") : Character("0") })
                #expect(SwitchRowFlips.minimumFlips(row) == everyFlipSet(row))
            }
        }
    }

    @Test("200,000 switches", arguments: [10, 50, 90])
    func large(onChance: Int) {
        var random = SwitchRandom(seed: UInt64(onChance))
        let row = randomRow(length: 200_000, onChance: onChance, using: &random)
        #expect(SwitchRowFlips.minimumFlips(row) == everySplit(row))
    }

    @Test("All on, then all off")
    func reversed() {
        let row = String(repeating: "1", count: 100_000) + String(repeating: "0", count: 100_000)
        #expect(SwitchRowFlips.minimumFlips(row) == 100_000)
        let sorted = String(repeating: "0", count: 100_000) + String(repeating: "1", count: 100_000)
        #expect(SwitchRowFlips.minimumFlips(sorted) == 0)
    }
}
