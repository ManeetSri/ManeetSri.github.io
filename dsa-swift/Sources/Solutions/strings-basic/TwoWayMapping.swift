// Reference solution: Isomorphic strings and word pattern. A valid mapping must be one-to-one in both
// directions, so keep two dictionaries and reject any pair that contradicts either of them.
// O(n) time, O(k) space for k distinct symbols.

public enum TwoWayMapping {
    public static func isomorphic(_ first: String, _ second: String) -> Bool {
        let a = Array(first)
        let b = Array(second)
        guard a.count == b.count else { return false }
        var forward: [Character: Character] = [:]
        var backward: [Character: Character] = [:]
        for (x, y) in zip(a, b) {
            if let mapped = forward[x], mapped != y { return false }
            if let mapped = backward[y], mapped != x { return false }
            forward[x] = y
            backward[y] = x
        }
        return true
    }

    public static func followsPattern(_ pattern: String, _ sentence: String) -> Bool {
        let letters = Array(pattern)
        let words = sentence.split(separator: " ").map(String.init)
        guard letters.count == words.count else { return false }
        var wordFor: [Character: String] = [:]
        var letterFor: [String: Character] = [:]
        for (letter, word) in zip(letters, words) {
            if let mapped = wordFor[letter], mapped != word { return false }
            if let mapped = letterFor[word], mapped != letter { return false }
            wordFor[letter] = word
            letterFor[word] = letter
        }
        return true
    }
}
