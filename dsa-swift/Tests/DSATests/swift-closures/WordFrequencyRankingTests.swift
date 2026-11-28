import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct WordFrequencyRankingTests {
    @Test("Ranks by how often each word appears")
    func ranks() {
        let words = ["apple", "banana", "apple", "cherry", "banana", "apple"]
        #expect(WordFrequencyRanking.mostFrequent(words, count: 1) == ["apple"])
        #expect(WordFrequencyRanking.mostFrequent(words, count: 2) == ["apple", "banana"])
        #expect(WordFrequencyRanking.mostFrequent(words, count: 3) == ["apple", "banana", "cherry"])
    }

    @Test("Breaks ties alphabetically")
    func ties() {
        let words = ["pear", "fig", "kiwi", "fig", "pear", "kiwi", "date"]
        #expect(WordFrequencyRanking.mostFrequent(words, count: 2) == ["fig", "kiwi"])
        #expect(WordFrequencyRanking.mostFrequent(words, count: 4) == ["fig", "kiwi", "pear", "date"])
    }

    @Test("Returns every word when k is bigger than the number of different words")
    func bigK() {
        let words = ["b", "a", "b"]
        #expect(WordFrequencyRanking.mostFrequent(words, count: 10) == ["b", "a"])
    }

    @Test("k of 0 and empty input give an empty result")
    func empty() {
        #expect(WordFrequencyRanking.mostFrequent(["a", "b"], count: 0) == [])
        #expect(WordFrequencyRanking.mostFrequent([], count: 3) == [])
    }

    @Test("A single word")
    func single() {
        #expect(WordFrequencyRanking.mostFrequent(["solo"], count: 1) == ["solo"])
        #expect(WordFrequencyRanking.mostFrequent(["echo", "echo", "echo"], count: 2) == ["echo"])
    }

    @Test("A rarer word that sorts first alphabetically still ranks lower")
    func frequencyBeatsAlphabet() {
        let words = ["zebra", "zebra", "aardvark"]
        #expect(WordFrequencyRanking.mostFrequent(words, count: 2) == ["zebra", "aardvark"])
    }

    @Test("Stays fast on 150,000 words")
    func large() {
        // Word "w<i>" appears 1,000 + (100 - i) × 10 times, so w0 is the most frequent
        var words: [String] = []
        for i in 0..<100 {
            words += Array(repeating: "w\(i)", count: 1_000 + (100 - i) * 10)
        }
        let top = WordFrequencyRanking.mostFrequent(words, count: 3)
        #expect(top == ["w0", "w1", "w2"])
    }
}
