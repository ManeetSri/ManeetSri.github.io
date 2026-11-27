import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct FirstUniqueInStreamTests {
    typealias UniqueWatcher = FirstUniqueInStream.UniqueWatcher

    /// The answer after each character, with "#" for none.
    private func answers(for text: String) -> String {
        var watcher = UniqueWatcher<Character>()
        var result = ""
        for character in text {
            watcher.add(character)
            result.append(watcher.firstUnique ?? "#")
        }
        return result
    }

    @Test("Reports the first unique character after each arrival", arguments: [
        ("aabcbd", "a#bbcc"),
        ("abacbd", "aabbcc"),
        ("swiss", "sssww"),
        ("abc", "aaa"),
        ("aaaa", "a###"),
        ("abba", "aaa#"),
        ("z", "z"),
        ("abcabc", "aaabc#"),
        ("xyxzy", "xxyyz"),
    ])
    func characters(text: String, expected: String) {
        #expect(answers(for: text) == expected)
    }

    @Test("A new watcher has no answer")
    func startsEmpty() {
        let watcher = UniqueWatcher<Int>()
        #expect(watcher.firstUnique == nil)
    }

    @Test("Works with any Hashable element")
    func otherElements() {
        var numbers = UniqueWatcher<Int>()
        for value in [7, 3, 7, 3, 9] {
            numbers.add(value)
        }
        #expect(numbers.firstUnique == 9)

        var words = UniqueWatcher<String>()
        words.add("hi")
        words.add("yo")
        #expect(words.firstUnique == "hi")
        words.add("hi")
        #expect(words.firstUnique == "yo")
        words.add("hi")
        #expect(words.firstUnique == "yo")
    }

    @Test("An element seen three times stays repeated")
    func staysRepeated() {
        var watcher = UniqueWatcher<Character>()
        for character in "aab" {
            watcher.add(character)
        }
        #expect(watcher.firstUnique == "b")
        watcher.add("a")
        #expect(watcher.firstUnique == "b")
        watcher.add("b")
        #expect(watcher.firstUnique == nil)
    }

    @Test("Matches a brute force on many small streams")
    func matchesBruteForce() {
        var firstMismatch: String? = nil
        for seed in 0..<200 {
            let stream = (0..<(seed % 15)).map { ($0 * 7 + seed * 3) % (seed % 5 + 2) }
            var watcher = UniqueWatcher<Int>()
            for index in stream.indices {
                watcher.add(stream[index])
                let seen = stream[...index]
                let expected = seen.first { value in seen.filter { $0 == value }.count == 1 }
                if watcher.firstUnique != expected {
                    firstMismatch = firstMismatch ?? "\(Array(seen))"
                }
            }
        }
        #expect(firstMismatch == nil, "the first stream prefix where the answer differs from a brute force")
    }

    @Test("Stays fast over 200,000 arrivals")
    func large() {
        var watcher = UniqueWatcher<Int>()
        for value in 0..<100_000 {
            watcher.add(value)
        }
        #expect(watcher.firstUnique == 0)
        var correct = true
        for value in 0..<100_000 {
            watcher.add(value)                    // each repeat knocks out the current answer
            let expected: Int? = value < 99_999 ? value + 1 : nil
            if watcher.firstUnique != expected { correct = false }
        }
        #expect(correct)
        #expect(watcher.firstUnique == nil)
        watcher.add(-1)
        #expect(watcher.firstUnique == -1)
    }
}
