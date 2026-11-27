import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PrefixRepeatBlocksTests {
    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// For every prefix, try every block length that divides it, shortest first. Slow but plain.
    private static func naive(_ text: String) -> [Int] {
        let s = Array(text.utf8)
        return s.indices.map { i in
            let length = i + 1
            for block in 1...length where length % block == 0 {
                if (block..<length).allSatisfy({ s[$0] == s[$0 - block] }) { return block }
            }
            return length
        }
    }

    /// A different method for long texts: the Z-array. The prefix of length L is built from blocks of
    /// length d (d divides L) exactly when the text from d agrees with the start for L - d characters.
    private static func viaZ(_ text: String) -> [Int] {
        let s = Array(text.utf8)
        let n = s.count
        var z = [Int](repeating: 0, count: n)
        var l = 0, r = 0
        for i in s.indices.dropFirst() {
            if i < r { z[i] = min(r - i, z[i - l]) }
            while i + z[i] < n && s[z[i]] == s[i + z[i]] { z[i] += 1 }
            if i + z[i] > r { l = i; r = i + z[i] }
        }
        var answer = Array(1...max(n, 1))
        for block in stride(from: 1, through: n / 2, by: 1) {
            for length in stride(from: 2 * block, through: n, by: block) where answer[length - 1] == length {
                if z[block] >= length - block { answer[length - 1] = block }
            }
        }
        return Array(answer.prefix(n))
    }

    @Test("Examples and edge cases", arguments: [
        ("abababab", [1, 2, 3, 2, 5, 2, 7, 2]),
        ("aaaa", [1, 1, 1, 1]),
        ("abcabcab", [1, 2, 3, 4, 5, 3, 7, 8]),
        ("aabaab", [1, 1, 3, 4, 5, 3]),
        ("x", [1]),
        ("", []),
    ])
    func examples(text: String, expected: [Int]) {
        #expect(PrefixRepeatBlocks.blockLengths(of: text) == expected)
    }

    @Test("Matches the naive answer on 1,000 random short texts")
    func randomSmall() {
        var steps = Steps(seed: 11)
        for round in 0..<1_000 {
            // Short random blocks repeated, cut at a random length, so repeats are common
            let letters = Array(round % 2 == 0 ? "ab" : "abc")
            let block = String((0..<(1 + steps.next(below: 4))).map { _ in letters[steps.next(below: letters.count)] })
            let text = String(String(repeating: block, count: 12).prefix(steps.next(below: 30)))
            #expect(PrefixRepeatBlocks.blockLengths(of: text) == Self.naive(text))
        }
    }

    @Test("Long structured texts")
    func longStructured() {
        let allA = String(repeating: "a", count: 100_000)
        #expect(PrefixRepeatBlocks.blockLengths(of: allA) == Array(repeating: 1, count: 100_000))
        let alternating = String(repeating: "ab", count: 50_000)
        #expect(PrefixRepeatBlocks.blockLengths(of: alternating) == (1...100_000).map { $0 % 2 == 0 ? 2 : $0 })
    }

    @Test("Long texts checked against the Z-array")
    func longChecked() {
        var steps = Steps(seed: 63)
        let abc = Array("abc")
        let block = String((0..<37).map { _ in abc[steps.next(below: 3)] })
        let repeated = String(String(repeating: block, count: 2_800).prefix(100_000))
        #expect(PrefixRepeatBlocks.blockLengths(of: repeated) == Self.viaZ(repeated))

        var fibonacci = ["b", "a"]                                    // a Fibonacci word: many near-repeats
        while fibonacci.last!.count < 100_000 {
            fibonacci.append(fibonacci[fibonacci.count - 1] + fibonacci[fibonacci.count - 2])
        }
        let word = String(fibonacci.last!.prefix(100_000))
        #expect(PrefixRepeatBlocks.blockLengths(of: word) == Self.viaZ(word))

        let random = String((0..<50_000).map { _ in abc[steps.next(below: 2)] })
        #expect(PrefixRepeatBlocks.blockLengths(of: random) == Self.viaZ(random))
    }
}
