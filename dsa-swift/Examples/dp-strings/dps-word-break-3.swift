// Generated from src/dsa/content/lessons/dp-strings/dps-word-break.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Every way to split `text` into words, as sentences
func allSentences(_ text: String, _ words: [String]) -> [String] {
    let characters = Array(text)
    let dictionary = Set(words)
    let longest = words.map(\.count).max() ?? 0
    var memo: [Int: [String]] = [:]                    // start → every sentence for characters[start...]

    func sentences(from start: Int) -> [String] {
        if start == characters.count {
            return [""]                                // one way to split nothing: no words
        }
        if let known = memo[start] {
            return known
        }
        var result: [String] = []
        let last = min(characters.count, start + longest)
        for end in stride(from: start + 1, through: last, by: 1) {
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

for sentence in allSentences("nowhere", ["no", "now", "where", "here", "w", "he", "re"]).sorted() {
    print(sentence)
}
print(allSentences("icecreamcones", ["ice", "cream", "icecream", "cone"]))
for n in [5, 10, 20] {
    print(n, allSentences(String(repeating: "a", count: n), ["a", "aa"]).count)
}
print(allSentences(String(repeating: "a", count: 1_000) + "b", ["a", "aa", "aaa"]).count)
