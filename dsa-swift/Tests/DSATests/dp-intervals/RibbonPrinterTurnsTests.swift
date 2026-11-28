import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct RibbonRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct RibbonPrinterTurnsTests {
    /// Breadth-first search over everything the ribbon could look like, one turn at a time. Each
    /// ribbon is a number in base (letters + 1), with digit 0 for a blank position. Only for short
    /// ribbons with few letters.
    private func bruteForce(_ pattern: String) -> Int {
        let target = Array(pattern)
        let n = target.count
        guard n > 0 else { return 0 }
        let letters = Array(Set(target)).sorted()
        let base = letters.count + 1
        var power = [1]
        for _ in 0..<n {
            power.append(power.last! * base)
        }
        let goal = target.indices.reduce(0) { $0 + (letters.firstIndex(of: target[$1])! + 1) * power[$1] }
        var distance = Array(repeating: -1, count: power[n])
        distance[0] = 0
        var queue = [0]
        var head = 0
        while head < queue.count {
            let ribbon = queue[head]
            head += 1
            if ribbon == goal { return distance[ribbon] }
            for letter in 1...letters.count {
                for from in 0..<n {
                    var printed = ribbon
                    for to in from..<n {
                        let digit = (printed / power[to]) % base
                        printed += (letter - digit) * power[to]       // print this letter at position `to`
                        if distance[printed] == -1 {
                            distance[printed] = distance[ribbon] + 1
                            queue.append(printed)
                        }
                    }
                }
            }
        }
        return -1
    }

    /// The same recurrence top-down with a memo, without collapsing runs first
    private func reference(_ pattern: String) -> Int {
        let s = Array(pattern)
        let n = s.count
        guard n > 0 else { return 0 }
        var memo = Array(repeating: Array(repeating: -1, count: n), count: n)
        func turns(_ i: Int, _ j: Int) -> Int {
            if i > j { return 0 }
            if memo[i][j] >= 0 { return memo[i][j] }
            var answer = 1 + turns(i + 1, j)
            if i < j {
                for k in (i + 1)...j where s[k] == s[i] {
                    answer = min(answer, turns(i + 1, k - 1) + turns(k, j))
                }
            }
            memo[i][j] = answer
            return answer
        }
        return turns(0, n - 1)
    }

    private func randomPattern(_ length: Int, letters: [Character], using random: inout RibbonRandom) -> String {
        String((0..<length).map { _ in letters.randomElement(using: &random)! })
    }

    @Test("Examples and edge cases", arguments: [
        ("abcba", 3),
        ("aaabbb", 2),
        ("abab", 3),
        ("abcabc", 5),
        ("banana", 4),
        ("xyzzyx", 3),
        ("abba", 2),
        ("q", 1),
        ("", 0),
    ])
    func examples(pattern: String, expected: Int) {
        #expect(RibbonPrinterTurns.fewestTurns(pattern) == expected)
    }

    @Test("Matches a search over every printing plan on 150 short ribbons")
    func randomSmall() {
        var random = RibbonRandom(seed: 61)
        for _ in 0..<150 {
            let letters: [Character] = Bool.random(using: &random) ? ["a", "b"] : ["a", "b", "c"]
            let pattern = randomPattern(Int.random(in: 0...6, using: &random), letters: letters, using: &random)
            #expect(RibbonPrinterTurns.fewestTurns(pattern) == bruteForce(pattern), "pattern: \(pattern)")
        }
    }

    @Test("200-letter ribbons")
    func large() {
        #expect(RibbonPrinterTurns.fewestTurns(String(repeating: "z", count: 200)) == 1)
        // "abab…ab": one long run of a's, then each b on its own
        #expect(RibbonPrinterTurns.fewestTurns(String(repeating: "ab", count: 100)) == 101)

        var random = RibbonRandom(seed: 200)
        for letters in [Array("abc"), Array("abcdefghij")] {
            let pattern = randomPattern(120, letters: letters, using: &random)
            #expect(RibbonPrinterTurns.fewestTurns(pattern) == reference(pattern))
        }
    }
}
