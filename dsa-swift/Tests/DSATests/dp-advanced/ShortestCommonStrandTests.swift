import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct StrandRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct ShortestCommonStrandTests {
    /// Brute force: try every order, gluing each fragment onto the strand with the largest overlap
    /// between the strand's end and the fragment's start, then check that every fragment is present
    private func bruteForce(_ fragments: [String]) -> Int {
        var best = Int.max
        var order: [Int] = []
        var used = [Bool](repeating: false, count: fragments.count)
        func glue(_ strand: String, _ piece: String) -> String {
            let a = Array(strand), b = Array(piece)
            for k in stride(from: min(a.count, b.count), through: 0, by: -1) where Array(a.suffix(k)) == Array(b.prefix(k)) {
                return strand + String(b.dropFirst(k))
            }
            return strand + piece
        }
        func extend(_ strand: String) {
            if order.count == fragments.count {
                if fragments.allSatisfy({ strand.contains($0) }) {
                    best = min(best, strand.count)
                }
                return
            }
            for i in fragments.indices where !used[i] {
                used[i] = true
                order.append(i)
                extend(glue(strand, fragments[i]))
                order.removeLast()
                used[i] = false
            }
        }
        extend("")
        return best
    }

    /// Random distinct fragments over a small alphabet, none inside another
    private func randomFragments(_ count: Int, alphabet: [Character], maxLength: Int, using random: inout StrandRandom) -> [String] {
        var fragments: [String] = []
        var attempts = 0
        while fragments.count < count && attempts < 1_000 {
            attempts += 1
            let length = Int.random(in: 1...maxLength, using: &random)
            let word = String((0..<length).map { _ in alphabet.randomElement(using: &random)! })
            if fragments.contains(where: { $0.contains(word) || word.contains($0) }) { continue }
            fragments.append(word)
        }
        return fragments
    }

    @Test("Examples and small cases", arguments: [
        (["CATG", "TGCA", "GCAT"], 6),
        (["ABC", "XYZ"], 6),
        (["SNOW"], 4),
        (["ABAB", "BABA"], 5),
        (["CDE", "ABC", "EFG"], 7),
        (["AAB", "ABA", "BAA"], 5),
    ] as [([String], Int)])
    func examples(fragments: [String], expected: Int) {
        #expect(ShortestCommonStrand.shortestLength(fragments) == expected)
    }

    @Test("Matches trying every order on 300 small random sets")
    func randomSmall() {
        var random = StrandRandom(seed: 58)
        for round in 0..<300 {
            let alphabet: [Character] = round.isMultiple(of: 2) ? ["A", "B"] : ["A", "C", "G", "T"]
            let fragments = randomFragments(Int.random(in: 1...6, using: &random), alphabet: alphabet, maxLength: 6, using: &random)
            #expect(ShortestCommonStrand.shortestLength(fragments) == bruteForce(fragments))
        }
    }

    @Test("Twelve fragments with a planted best order")
    func planted() {
        // Fragment i is letters i, i + 1 and i + 2 of a scrambled alphabet, so the letters are all
        // different and only the chain fragment 0, 1, 2, … overlaps by two letters at every step.
        var random = StrandRandom(seed: 12)
        for _ in 0..<5 {
            let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").shuffled(using: &random)
            let fragments = (0..<12).map { String(letters[$0...($0 + 2)]) }.shuffled(using: &random)
            #expect(ShortestCommonStrand.shortestLength(fragments) == 14)
        }
    }

    @Test("Twelve fragments of up to 20 letters")
    func large() {
        // Each fragment ends with a letter nothing else uses, so nothing overlaps
        let separate = (0..<12).map { i in String(repeating: "A", count: 19) + String(UnicodeScalar(UInt8(66 + i))) }
        #expect(ShortestCommonStrand.shortestLength(separate) == 240)

        // Twelve shifted windows of one long string: neighbouring windows overlap by 19 letters
        let source = Array("THEQUICKBROWNFOXJUMPSOVERALAZYDOG")
        let windows = (0..<12).map { String(source[$0..<($0 + 20)]) }
        let shuffled = [windows[5], windows[0], windows[11], windows[3], windows[8], windows[1],
                        windows[10], windows[2], windows[7], windows[4], windows[9], windows[6]]
        #expect(ShortestCommonStrand.shortestLength(shuffled) == 31)
    }
}
