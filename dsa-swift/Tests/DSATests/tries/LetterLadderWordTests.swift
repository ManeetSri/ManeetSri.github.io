import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct LetterLadderWordTests {
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
        (["b", "ba", "ban", "band", "bandit", "banda", "a", "an", "ant"], "banda"),
        (["a", "ab", "ac", "b", "bc"], "ab"),
        (["c", "ca", "cats"], "ca"),
        (["to", "top", "tops"], ""),
        (["q"], "q"),
    ])
    func examples(words: [String], expected: String) {
        #expect(LetterLadderWord.longest(in: words) == expected)
    }

    @Test("An empty list gives the empty string")
    func empty() {
        #expect(LetterLadderWord.longest(in: []) == "")
    }

    @Test("Ties go to the alphabetically smallest word, whatever the input order")
    func ties() {
        #expect(LetterLadderWord.longest(in: ["z", "zy", "y", "yz", "x"]) == "yz")
        #expect(LetterLadderWord.longest(in: ["yz", "y", "zy", "z", "x"]) == "yz")
        #expect(LetterLadderWord.longest(in: ["m", "k", "a"]) == "a")
    }

    @Test("Repeated words are fine")
    func repeats() {
        #expect(LetterLadderWord.longest(in: ["d", "do", "d", "dot", "do", "dots", "dote"]) == "dote")
    }

    @Test("A missing rung breaks the ladder above it")
    func missingRung() {
        #expect(LetterLadderWord.longest(in: ["w", "wo", "wor", "words", "wordy", "e", "ea", "ear"]) == "ear")
    }

    @Test("A ladder 1,000 letters tall")
    func tallLadder() {
        let top = String(repeating: "k", count: 1_000)
        let rungs = (1...1_000).map { String(top.prefix($0)) }
        #expect(LetterLadderWord.longest(in: rungs.reversed()) == top)
    }

    @Test("50,000 words agree with the sorting method")
    func large() {
        var steps = Steps(seed: 5)
        let letters = Array("abcdefghij")
        var words: [String] = []
        // Ladders that grow from random shorter words, so many prefixes really are words
        for _ in 0..<50_000 {
            if !words.isEmpty && steps.next(below: 3) > 0 {
                let base = words[steps.next(below: words.count)]
                if base.count < 25 {
                    words.append(base + String(letters[steps.next(below: letters.count)]))
                    continue
                }
            }
            words.append(String((0..<(1 + steps.next(below: 3))).map { _ in letters[steps.next(below: letters.count)] }))
        }
        // The sorting method: in sorted order, every prefix of a word comes before it
        var buildable = Set<String>()
        var best = ""
        for word in Set(words).sorted() where word.count == 1 || buildable.contains(String(word.dropLast())) {
            buildable.insert(word)
            if word.count > best.count { best = word }
        }
        #expect(LetterLadderWord.longest(in: words) == best)
    }
}
