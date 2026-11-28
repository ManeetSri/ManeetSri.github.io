import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct ZoneRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct LetterZoneSplitTests {
    /// Tries every set of cuts between neighbouring letters, keeps the valid splits, and returns the
    /// lengths of a split with the most zones. Exponential, so only for short strings.
    private func exhaustive(_ text: String) -> [Int] {
        let letters = Array(text.utf8).map { Int($0) - 97 }
        let n = letters.count
        var best: [Int] = []
        for mask in 0..<(1 << max(n - 1, 0)) {
            // Bit i set means cut between letters i and i + 1. Each zone's letters become a bitmask.
            var zoneLetters = [0]
            var lengths = [0]
            for i in 0..<n {
                zoneLetters[zoneLetters.count - 1] |= 1 << letters[i]
                lengths[lengths.count - 1] += 1
                if i < n - 1 && mask & (1 << i) != 0 {
                    zoneLetters.append(0)
                    lengths.append(0)
                }
            }
            var seen = 0
            var valid = true
            for zone in zoneLetters {
                if seen & zone != 0 { valid = false; break }     // a letter already used by an earlier zone
                seen |= zone
            }
            if valid && lengths.count > best.count {
                best = lengths
            }
        }
        return best
    }

    @Test("Examples and small cases", arguments: [
        ("abacbdedfghgih", [5, 3, 1, 5]),
        ("abcabc", [6]),
        ("xyz", [1, 1, 1]),
        ("abcbdefe", [1, 3, 1, 3]),
        ("a", [1]),
        ("aaaa", [4]),
        ("abba", [4]),
        ("abccbaddeffe", [6, 2, 4]),
        ("zyxxyzq", [6, 1]),
    ] as [(String, [Int])])
    func examples(text: String, expected: [Int]) {
        #expect(LetterZoneSplit.zoneLengths(text) == expected)
    }

    @Test("Matches trying every split on 500 short random strings")
    func randomShort() {
        var random = ZoneRandom(seed: 50)
        let alphabet = Array("abcdefghijklmnopqrstuvwxyz")
        for _ in 0..<500 {
            let letterCount = Int.random(in: 1...6, using: &random)
            let text = String((0..<Int.random(in: 1...12, using: &random)).map { _ in alphabet[Int.random(in: 0..<letterCount, using: &random)] })
            #expect(LetterZoneSplit.zoneLengths(text) == exhaustive(text), "text \(text)")
        }
    }

    @Test("About 100,000 letters in planted zones")
    func large() {
        var random = ZoneRandom(seed: 2_026)
        let alphabet = Array("abcdefghijklmnopqrstuvwxyz").shuffled(using: &random)
        // Each zone uses its own letters, starts and ends with the same letter, and mixes in the next one
        var lengths: [Int] = []
        var text = ""
        for zone in 0..<13 {
            let first = alphabet[2 * zone], second = alphabet[2 * zone + 1]
            let middle = (0..<Int.random(in: 1...7_000, using: &random)).map { _ in Bool.random(using: &random) ? first : second }
            let letters = [first] + middle + [first]
            lengths.append(letters.count)
            text += String(letters)
        }
        #expect(LetterZoneSplit.zoneLengths(text) == lengths)

        // One letter at both ends glues everything into a single zone
        #expect(LetterZoneSplit.zoneLengths("q" + String(repeating: "abcdefghijklmnoprstuvwxyz", count: 3_999) + "q") == [99_977])
        // A block of each letter in turn: 26 zones
        let blocks = alphabet.map { String(repeating: $0, count: 3_000) }.joined()
        #expect(LetterZoneSplit.zoneLengths(blocks) == Array(repeating: 3_000, count: 26))
    }
}
