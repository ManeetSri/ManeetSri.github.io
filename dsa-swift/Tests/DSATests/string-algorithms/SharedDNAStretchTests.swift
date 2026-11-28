import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SharedDNAStretchTests {
    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    private static func strand(_ length: Int, from letters: [Character], _ steps: inout Steps) -> String {
        String((0..<length).map { _ in letters[steps.next(below: letters.count)] })
    }

    /// The dynamic programming answer: run[i][j] = the common stretch ending at a[i - 1] and b[j - 1].
    private static func dynamicProgramming(_ first: String, _ second: String) -> Int {
        let a = Array(first.utf8), b = Array(second.utf8)
        var best = 0
        var previous = [Int](repeating: 0, count: b.count + 1)
        for i in a.indices {
            var current = [Int](repeating: 0, count: b.count + 1)
            for j in b.indices where a[i] == b[j] {
                current[j + 1] = previous[j] + 1
                best = max(best, current[j + 1])
            }
            previous = current
        }
        return best
    }

    /// A different method for long strands: a suffix automaton of the first strand, then the second
    /// strand walked through it, following suffix links to shorten the match on a dead end.
    private static func viaAutomaton(_ first: String, _ second: String) -> Int {
        func code(_ byte: UInt8) -> Int { byte == 65 ? 0 : byte == 67 ? 1 : byte == 71 ? 2 : 3 }
        var len = [0], link = [-1]
        var next = [[Int]](repeating: [-1, -1, -1, -1], count: 1)
        var last = 0
        for byte in first.utf8 {
            let c = code(byte)
            let cur = len.count
            len.append(len[last] + 1); link.append(0); next.append([-1, -1, -1, -1])
            var p = last
            while p != -1 && next[p][c] == -1 { next[p][c] = cur; p = link[p] }
            if p != -1 {
                let q = next[p][c]
                if len[p] + 1 == len[q] {
                    link[cur] = q
                } else {
                    let clone = len.count
                    len.append(len[p] + 1); link.append(link[q]); next.append(next[q])
                    while p != -1 && next[p][c] == q { next[p][c] = clone; p = link[p] }
                    link[q] = clone
                    link[cur] = clone
                }
            }
            last = cur
        }
        var state = 0, matched = 0, best = 0
        for byte in second.utf8 {
            let c = code(byte)
            while state != 0 && next[state][c] == -1 {
                state = link[state]
                matched = len[state]
            }
            if next[state][c] != -1 {
                state = next[state][c]
                matched += 1
            }
            best = max(best, matched)
        }
        return best
    }

    @Test("Examples and edge cases", arguments: [
        ("ACGTACGT", "TACG", 4),
        ("GATTACA", "TACAGAT", 4),
        ("AAAA", "CCCC", 0),
        ("", "ACGT", 0),
        ("ACGT", "", 0),
        ("A", "A", 1),
        ("ACGT", "ACGT", 4),
        ("CCCCGATTCC", "GATT", 4),
    ])
    func examples(first: String, second: String, expected: Int) {
        #expect(SharedDNAStretch.longest(first, second) == expected)
    }

    @Test("Matches dynamic programming on 1,000 random short strands")
    func randomSmall() {
        var steps = Steps(seed: 5)
        for round in 0..<1_000 {
            let letters: [Character] = round % 2 == 0 ? ["A", "C"] : ["A", "C", "G", "T"]
            let first = Self.strand(steps.next(below: 30), from: letters, &steps)
            let second = Self.strand(steps.next(below: 30), from: letters, &steps)
            #expect(SharedDNAStretch.longest(first, second) == Self.dynamicProgramming(first, second))
            #expect(SharedDNAStretch.longest(first, second) == Self.viaAutomaton(first, second))
        }
    }

    @Test("Strands of 100,000 where comparing every pair of positions is far too slow")
    func structured() {
        let allA = String(repeating: "A", count: 100_000)
        #expect(SharedDNAStretch.longest(allA, allA) == 100_000)
        let split = String(repeating: "A", count: 50_000) + "C" + String(repeating: "A", count: 49_999)
        #expect(SharedDNAStretch.longest(allA, split) == 50_000)
        #expect(SharedDNAStretch.longest(String(repeating: "C", count: 30_000), String(repeating: "G", count: 30_000)) == 0)
    }

    @Test("Random strands with a planted shared stretch")
    func planted() {
        var steps = Steps(seed: 63)
        let letters: [Character] = ["A", "C", "G", "T"]
        let first = Self.strand(50_000, from: letters, &steps)
        var second = Array(Self.strand(40_000, from: letters, &steps))
        second.replaceSubrange(30_000..<32_500, with: Array(first)[10_000..<12_500])
        let other = String(second)
        let expected = Self.viaAutomaton(first, other)
        #expect(expected >= 2_500)
        #expect(SharedDNAStretch.longest(first, other) == expected)

        let unplanted = Self.strand(30_000, from: letters, &steps)
        #expect(SharedDNAStretch.longest(first, unplanted) == Self.viaAutomaton(first, unplanted))
    }
}
