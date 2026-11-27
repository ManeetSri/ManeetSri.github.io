// Reference solution: Count the hidden word. ways[j] is the number of ways to pick the first j letters
// of the word from the text read so far. Each text letter either is skipped (ways stay) or spells
// word[j - 1] (add ways[j - 1]). Running j downwards uses the previous letter's ways[j - 1], so a text
// letter is never used twice in one pick. The counts grow like binomial coefficients, so everything
// is kept modulo 1,000,000,007: both terms are below it, so their sum always fits in an Int.
// O(text · word) time, O(word) space.

public enum HiddenWordCount {
    public static func ways(text: String, word: String) -> Int {
        let modulus = 1_000_000_007
        let w = Array(word)
        var ways = Array(repeating: 0, count: w.count + 1)
        ways[0] = 1
        for letter in text {
            for j in stride(from: w.count, through: 1, by: -1) where w[j - 1] == letter {
                ways[j] = (ways[j] + ways[j - 1]) % modulus
            }
        }
        return ways[w.count]
    }
}
