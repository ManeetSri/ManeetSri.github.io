// Reference solution: Split text into dictionary words.
// canSplit: ok[end] says whether text's first `end` characters split into words. It's true when some
// ok[start] is true and text[start..<end] is a word; only starts within the longest word's length of
// `end` can work. O(n · L) substring checks, each O(L), for words up to L characters.
// allSentences: memoised backtracking. sentences(from: start) lists every sentence for text[start...]
// and is computed once per start; a start with no way to finish returns [] at once, so dead ends are
// cheap. The output itself can be exponentially large, and building it dominates the time.

public enum DictionarySentenceSplitter {
    public static func canSplit(_ text: String, words: [String]) -> Bool {
        let characters = Array(text)
        let dictionary = Set(words)
        let longest = words.map(\.count).max() ?? 0
        var ok = Array(repeating: false, count: characters.count + 1)
        ok[0] = true
        for end in stride(from: 1, through: characters.count, by: 1) {
            for start in stride(from: end - 1, through: max(0, end - longest), by: -1)
            where ok[start] && dictionary.contains(String(characters[start..<end])) {
                ok[end] = true
                break
            }
        }
        return ok[characters.count]
    }

    public static func allSentences(_ text: String, words: [String]) -> [String] {
        let characters = Array(text)
        let dictionary = Set(words)
        let longest = words.map(\.count).max() ?? 0
        var memo: [Int: [String]] = [:]

        func sentences(from start: Int) -> [String] {
            if start == characters.count {
                return [""]
            }
            if let known = memo[start] {
                return known
            }
            var result: [String] = []
            for end in stride(from: start + 1, through: min(characters.count, start + longest), by: 1) {
                let word = String(characters[start..<end])
                guard dictionary.contains(word) else { continue }
                for rest in sentences(from: end) {
                    result.append(rest.isEmpty ? word : word + " " + rest)
                }
            }
            memo[start] = result
            return result
        }

        return sentences(from: 0)
    }
}
