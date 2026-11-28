import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct EditScriptRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct WordEditScriptTests {
    typealias Step = WordEditScript.Step

    /// Tries all three edits at every position, even when the characters already match. Exponential,
    /// but clearly right on short words.
    private func bruteDistance(_ a: [Character], _ b: [Character], _ i: Int, _ j: Int) -> Int {
        if i == a.count { return b.count - j }
        if j == b.count { return a.count - i }
        let diagonal = bruteDistance(a, b, i + 1, j + 1) + (a[i] == b[j] ? 0 : 1)
        return min(diagonal, bruteDistance(a, b, i + 1, j) + 1, bruteDistance(a, b, i, j + 1) + 1)
    }

    /// A separate two-row table over bytes, for strings too long for the recursion
    private func referenceDistance(_ source: String, _ target: String) -> Int {
        let a = Array(source.utf8), b = Array(target.utf8)
        var previous = Array(0...b.count)
        var current = previous
        for (index, x) in a.enumerated() {
            current[0] = index + 1
            for j in 1..<(b.count + 1) {
                current[j] = x == b[j - 1] ? previous[j - 1] : 1 + min(previous[j - 1], previous[j], current[j - 1])
            }
            swap(&previous, &current)
        }
        return previous[b.count]
    }

    /// Runs a script over the source. Returns what it writes, or nil if a step doesn't fit the source.
    private func apply(_ steps: [Step], to source: String) -> String? {
        let characters = Array(source)
        var position = 0
        var output: [Character] = []
        for step in steps {
            switch step {
            case .keep(let character):
                guard position < characters.count, characters[position] == character else { return nil }
                output.append(character)
                position += 1
            case .replace(let old, let new):
                guard position < characters.count, characters[position] == old, old != new else { return nil }
                output.append(new)
                position += 1
            case .delete(let character):
                guard position < characters.count, characters[position] == character else { return nil }
                position += 1
            case .insert(let character):
                output.append(character)
            }
        }
        return position == characters.count ? String(output) : nil
    }

    private func edits(_ steps: [Step]) -> Int {
        steps.filter { if case .keep = $0 { return false } else { return true } }.count
    }

    /// A script is right if it turns source into target and uses exactly the fewest edits
    private func checkScript(_ source: String, _ target: String, expected: Int) {
        let steps = WordEditScript.script(from: source, to: target)
        #expect(apply(steps, to: source) == target, "the script for \"\(source)\" → \"\(target)\" doesn't produce the target")
        #expect(edits(steps) == expected, "the script for \"\(source)\" → \"\(target)\" uses \(edits(steps)) edits")
    }

    private func randomText(_ alphabet: [Character], _ length: Int, _ random: inout EditScriptRandom) -> String {
        String((0..<length).map { _ in alphabet[Int.random(in: 0..<alphabet.count, using: &random)] })
    }

    @Test("Examples and small cases", arguments: [
        ("kitten", "sitting", 3),
        ("sunday", "saturday", 3),
        ("intention", "execution", 5),
        ("swift", "swift", 0),
        ("", "abc", 3),
        ("abc", "", 3),
        ("", "", 0),
        ("a", "b", 1),
        ("ab", "ba", 2),
        ("café", "cafe", 1),
        ("flaw", "lawn", 2),
    ])
    func examples(source: String, target: String, expected: Int) {
        #expect(WordEditScript.distance(from: source, to: target) == expected)
        checkScript(source, target, expected: expected)
    }

    @Test("Scripts with only one possible shape")
    func forcedScripts() {
        #expect(WordEditScript.script(from: "swift", to: "swift") == "swift".map { Step.keep($0) })
        #expect(WordEditScript.script(from: "", to: "ab") == [.insert("a"), .insert("b")])
        #expect(WordEditScript.script(from: "ab", to: "") == [.delete("a"), .delete("b")])
        #expect(WordEditScript.script(from: "cat", to: "cut") == [.keep("c"), .replace("a", with: "u"), .keep("t")])
    }

    @Test("Matches the brute force on 250 random short pairs")
    func randomSmall() {
        var random = EditScriptRandom(seed: 543)
        for _ in 0..<250 {
            let source = randomText(Array("abc"), Int.random(in: 0...5, using: &random), &random)
            let target = randomText(Array("abc"), Int.random(in: 0...5, using: &random), &random)
            let expected = bruteDistance(Array(source), Array(target), 0, 0)
            #expect(WordEditScript.distance(from: source, to: target) == expected, "\"\(source)\" → \"\(target)\"")
            checkScript(source, target, expected: expected)
        }
    }

    @Test("A 1,500-character text and a copy with 100 random edits")
    func longEdited() {
        var random = EditScriptRandom(seed: 1_500)
        let source = randomText(Array("abcdefghij"), 1_500, &random)
        var target = Array(source)
        for _ in 0..<100 {
            let position = Int.random(in: 0..<target.count, using: &random)
            switch Int.random(in: 0..<3, using: &random) {
            case 0: target.insert("z", at: position)
            case 1: target.remove(at: position)
            default: target[position] = "y"
            }
        }
        let edited = String(target)
        let expected = referenceDistance(source, edited)
        #expect(expected <= 100)
        #expect(WordEditScript.distance(from: source, to: edited) == expected)
        checkScript(source, edited, expected: expected)
    }

    @Test("Long strings with nothing in common")
    func longDisjoint() {
        let source = String(repeating: "a", count: 1_200)
        let target = String(repeating: "b", count: 1_000)
        #expect(WordEditScript.distance(from: source, to: target) == 1_200)     // 1,000 replacements, 200 deletions
        checkScript(source, target, expected: 1_200)
    }
}
