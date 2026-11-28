import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RootReplacementTests {
    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    @Test("Examples from the statement", arguments: [
        ("sunflowers bloom under the moonlight", ["sun", "su", "moon", "bl"], "su bl under the moon"),
        ("rebuild the rerun", ["re", "reb"], "re the re"),
        ("cats chase mice", ["dog"], "cats chase mice"),
        ("a ab abc", ["abc", "ab"], "a ab ab"),
        ("star", ["star"], "star"),
    ])
    func examples(sentence: String, roots: [String], expected: String) {
        #expect(RootReplacement.replace(in: sentence, roots: roots) == expected)
    }

    @Test("No roots leaves the sentence alone")
    func noRoots() {
        #expect(RootReplacement.replace(in: "nothing to see here", roots: []) == "nothing to see here")
    }

    @Test("A root longer than the word doesn't apply")
    func longerRoot() {
        #expect(RootReplacement.replace(in: "s su sun", roots: ["sun"]) == "s su sun")
    }

    @Test("Repeated roots and repeated words")
    func repeats() {
        #expect(RootReplacement.replace(in: "going going gone", roots: ["go", "go", "gon"]) == "go go go")
    }

    @Test("Single-letter roots catch everything starting with that letter")
    func singleLetter() {
        #expect(RootReplacement.replace(in: "bat ball cat bee", roots: ["b", "ba"]) == "b b cat b")
    }

    @Test("50,000 roots and a 50,000-word sentence")
    func large() {
        var steps = Steps(seed: 11)
        let letters = Array("abcdefgh")
        func randomText(_ length: Int) -> String {
            String((0..<length).map { _ in letters[steps.next(below: letters.count)] })
        }
        var roots: [String] = []
        for _ in 0..<50_000 {
            roots.append(randomText(3 + steps.next(below: 6)))
        }
        var words: [String] = []
        for _ in 0..<50_000 {
            if steps.next(below: 2) == 0 {
                words.append(roots[steps.next(below: roots.count)] + randomText(steps.next(below: 5)))
            } else {
                words.append(randomText(1 + steps.next(below: 10)))
            }
        }
        // The slower, simpler way: try every prefix of each word, shortest first, in a set
        let rootSet = Set(roots)
        let expected = words.map { word -> String in
            for length in 1...word.count where rootSet.contains(String(word.prefix(length))) {
                return String(word.prefix(length))
            }
            return word
        }
        let result = RootReplacement.replace(in: words.joined(separator: " "), roots: roots)
        #expect(result == expected.joined(separator: " "))
    }
}
