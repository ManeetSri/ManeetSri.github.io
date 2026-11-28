// Generated from src/dsa/content/lessons/dp-strings/dps-word-break.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Can `text` be split into words from `words`? ok[i] says whether its first i characters can.
func canSplit(_ text: String, _ words: [String]) -> Bool {
    let characters = Array(text)
    let dictionary = Set(words)
    let longest = words.map(\.count).max() ?? 0
    var ok = Array(repeating: false, count: characters.count + 1)
    ok[0] = true                                                 // the empty prefix: zero words
    for end in stride(from: 1, through: characters.count, by: 1) {
        for start in stride(from: end - 1, through: max(0, end - longest), by: -1) {
            if ok[start] && dictionary.contains(String(characters[start..<end])) {
                ok[end] = true                                   // a good prefix, then one word
                break
            }
        }
    }
    return ok[characters.count]
}

let words = ["ice", "cream", "icecream", "cone", "con"]
print(canSplit("icecreamcone", words))
print(canSplit("creamicecon", words))
print(canSplit("icecreamcones", words))
print(canSplit("", words))
let manyA = String(repeating: "a", count: 2_000) + "b"
print(canSplit(manyA, ["a", "aa", "aaa", "aaaa"]))
