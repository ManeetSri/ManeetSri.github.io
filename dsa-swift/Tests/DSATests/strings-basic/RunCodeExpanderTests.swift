import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RunCodeExpanderTests {
    /// A tiny deterministic generator, so the random cases are the same every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    @Test("Expands each run", arguments: [
        ("a2bc6", "aabcccccc"),
        ("m10n2", "mmmmmmmmmmnn"),
        ("xyz", "xyz"),
        ("k1", "k"),
        ("w3!2", "www!!"),
        ("", ""),
        ("z", "z"),
        ("a1b1c1", "abc"),
        ("é3", "ééé"),
        ("q12", String(repeating: "q", count: 12)),
        ("a2a3", "aaaaa"),
    ])
    func examples(code: String, expected: String) {
        #expect(RunCodeExpander.expand(code) == expected)
    }

    @Test("Reads every digit of a long count", arguments: [99, 100, 1_000, 20_001, 200_000])
    func longCounts(count: Int) {
        #expect(RunCodeExpander.expand("b\(count)c") == String(repeating: "b", count: count) + "c")
        #expect(RunCodeExpander.expand("c" + "b\(count)") == "c" + String(repeating: "b", count: count))
    }

    @Test("Undoes compression on random texts")
    func roundTrip() {
        var steps = Steps(seed: 2_310)
        var mismatches = 0
        for _ in 0..<500 {
            var code = ""
            var expected = ""
            for _ in 0..<steps.next(below: 8) {
                let letter: Character = ["a", "b", "c", "-"][steps.next(below: 4)]
                let length = 1 + steps.next(below: 25)
                code.append(letter)
                if length > 1 || steps.next(below: 2) == 0 { code += String(length) }
                expected += String(repeating: letter, count: length)
            }
            if RunCodeExpander.expand(code) != expected { mismatches += 1 }
        }
        #expect(mismatches == 0)
    }

    @Test("Stays fast on a long code")
    func large() {
        var code = ""
        var expected = ""
        for index in 0..<20_000 {
            let letter: Character = index.isMultiple(of: 2) ? "x" : "y"
            let length = 1 + index % 9
            code.append(letter)
            if length > 1 { code += String(length) }
            expected += String(repeating: letter, count: length)
        }
        #expect(RunCodeExpander.expand(code) == expected)
    }
}
