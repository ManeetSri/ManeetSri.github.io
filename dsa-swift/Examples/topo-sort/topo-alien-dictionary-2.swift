// Generated from src/dsa/content/lessons/topo-sort/topo-alien-dictionary.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func alphabet(_ words: [String]) -> String {
    var letters: [Character] = []                     // every letter, in order of first appearance
    var after: [Character: [Character]] = [:]
    var waitingOn: [Character: Int] = [:]
    for word in words {
        for letter in word where waitingOn[letter] == nil {
            letters.append(letter)
            after[letter] = []
            waitingOn[letter] = 0
        }
    }

    var seen = Set<String>()                          // edges already added, such as "ae"
    for (earlier, later) in zip(words, words.dropFirst()) {
        guard let (a, b) = zip(earlier, later).first(where: { $0.0 != $0.1 }) else {
            if earlier.count > later.count { return "" }   // a longer word before its own prefix
            continue                                       // equal, or a prefix first: no edge
        }
        if seen.insert(String([a, b])).inserted {
            after[a]!.append(b)
            waitingOn[b]! += 1
        }
    }

    var order = letters.filter { waitingOn[$0] == 0 }
    var head = 0
    while head < order.count {
        let letter = order[head]
        head += 1
        for next in after[letter]! {
            waitingOn[next]! -= 1
            if waitingOn[next] == 0 {
                order.append(next)
            }
        }
    }
    return order.count == letters.count ? String(order) : ""   // short: the facts contradict
}

print(alphabet(["rat", "rate", "re", "tar", "tea", "ear"]))
print(alphabet(["ab", "ba", "ac"]).isEmpty)           // a before b, then b before a
print(alphabet(["tea", "te"]).isEmpty)                // a longer word before its prefix
print(alphabet(["moon"]))                             // no facts at all
