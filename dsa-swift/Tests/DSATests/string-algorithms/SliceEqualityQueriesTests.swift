import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SliceEqualityQueriesTests {
    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// Compare the two slices character by character.
    private static func direct(_ text: String, _ queries: [[Int]]) -> [Bool] {
        let s = Array(text.utf8)
        return queries.map { s[$0[0]..<($0[0] + $0[2])].elementsEqual(s[$0[1]..<($0[1] + $0[2])]) }
    }

    @Test("The example")
    func example() {
        let queries = [[0, 7, 4], [0, 3, 1], [1, 8, 3], [0, 1, 4], [2, 2, 5], [4, 9, 0]]
        #expect(SliceEqualityQueries.answer(text: "abracadabra", queries: queries) == [true, true, true, false, true, true])
        #expect(SliceEqualityQueries.answer(text: "", queries: [[0, 0, 0]]) == [true])
        #expect(SliceEqualityQueries.answer(text: "abc", queries: []) == [])
    }

    @Test("Matches direct comparison on 500 random small texts")
    func randomSmall() {
        var steps = Steps(seed: 9)
        for round in 0..<500 {
            let letters = Array(round % 2 == 0 ? "ab" : "abc")
            let n = 1 + steps.next(below: 30)
            let text = String((0..<n).map { _ in letters[steps.next(below: letters.count)] })
            let queries = (0..<20).map { _ -> [Int] in
                let length = steps.next(below: n + 1)
                return [steps.next(below: n - length + 1), steps.next(below: n - length + 1), length]
            }
            #expect(SliceEqualityQueries.answer(text: text, queries: queries) == Self.direct(text, queries))
        }
    }

    @Test("100,000 long equal slices of 100,000 a's: comparing letters would take billions of steps")
    func longEqualSlices() {
        var steps = Steps(seed: 63)
        let n = 100_000
        let text = String(repeating: "a", count: n)
        let queries = (0..<100_000).map { _ -> [Int] in
            let length = 40_000 + steps.next(below: 20_000)
            return [steps.next(below: n - length + 1), steps.next(below: n - length + 1), length]
        }
        #expect(SliceEqualityQueries.answer(text: text, queries: queries) == Array(repeating: true, count: queries.count))
    }

    @Test("Near misses: two copies of a random text that differ in 20 places")
    func nearMisses() {
        var steps = Steps(seed: 2_024)
        let letters = Array("abcdefghijklmnopqrstuvwxyz")
        let half = 50_000
        let original = (0..<half).map { _ in letters[steps.next(below: 26)] }
        var copy = original
        var changed: [Int] = []
        for _ in 0..<20 {
            let position = steps.next(below: half)
            copy[position] = original[position] == "a" ? "b" : "a"      // always differs from the original
            changed.append(position)
        }
        let text = String(original + copy)
        var queries: [[Int]] = []
        var expected: [Bool] = []
        for _ in 0..<100_000 {
            let length = 1 + steps.next(below: 5_000)
            let start = steps.next(below: half - length + 1)
            queries.append([start, half + start, length])
            expected.append(!changed.contains { start <= $0 && $0 < start + length })
        }
        #expect(SliceEqualityQueries.answer(text: text, queries: queries) == expected)
    }

    @Test("Strings built to fool hashes that let UInt64 wrap around (mod 2^64)")
    func antiHash() {
        // Thue–Morse: these collide mod 2^64 for every odd base
        var morse: [Character] = ["a"]
        while morse.count < 4_096 {
            morse += morse.map { $0 == "a" ? "b" : "a" }
        }
        let swapped = morse.map { $0 == "a" ? Character("b") : Character("a") }
        let text = String(morse + swapped + morse)
        let queries = [[0, 4_096, 4_096], [0, 8_192, 4_096], [0, 2_048, 2_048], [4_096, 2_048, 2_048], [1, 8_193, 4_095]]
        #expect(SliceEqualityQueries.answer(text: text, queries: queries) == [false, true, false, true, true])

        // These differ only far from the end, which mod 2^64 with an even base can't see
        let tail = String(repeating: "a", count: 200)
        let farApart = "b" + tail + "c" + tail
        #expect(SliceEqualityQueries.answer(text: farApart, queries: [[0, 201, 201], [1, 202, 200]]) == [false, true])
    }
}
