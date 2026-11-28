// Generated from src/dsa/content/lessons/topo-sort/topo-alien-dictionary.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func fits(_ alphabet: String, _ words: [String]) -> Bool {
    let used = Set(words.joined())
    guard alphabet.count == used.count, Set(alphabet) == used else { return false }  // each letter once
    var rank: [Character: Int] = [:]
    for (index, letter) in alphabet.enumerated() {
        rank[letter] = index
    }
    for (earlier, later) in zip(words, words.dropFirst()) {
        if let (a, b) = zip(earlier, later).first(where: { $0.0 != $0.1 }) {
            if rank[a]! > rank[b]! { return false }
        } else if earlier.count > later.count {
            return false
        }
    }
    return true
}

let glossary = ["rat", "rate", "re", "tar", "tea", "ear"]
for candidate in ["rate", "arte", "rtae", "tare", "rat"] {
    print(candidate, fits(candidate, glossary))
}
