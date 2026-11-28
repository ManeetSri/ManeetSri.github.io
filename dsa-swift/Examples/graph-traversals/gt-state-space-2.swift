// Generated from src/dsa/content/lessons/graph-traversals/gt-state-space.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// The word with each letter in turn replaced by "*": "cold" gives "*old", "c*ld", "co*d", "col*"
func patterns(of word: String) -> [String] {
    let letters = Array(word)
    return letters.indices.map { index in
        var pattern = letters
        pattern[index] = "*"
        return String(pattern)
    }
}

func ladder(from start: String, to target: String, words: [String]) -> [String] {
    var buckets: [String: [String]] = [:]               // pattern → the words that fit it
    for word in words {
        for pattern in patterns(of: word) {
            buckets[pattern, default: []].append(word)
        }
    }
    var parent: [String: String] = [start: start]      // also the visited set
    var queue = [start]
    var head = 0
    while head < queue.count && parent[target] == nil {
        let word = queue[head]
        head += 1
        for pattern in patterns(of: word) {
            for next in buckets[pattern] ?? [] where parent[next] == nil {
                parent[next] = word
                queue.append(next)
            }
        }
    }
    guard parent[target] != nil else { return [] }
    var path = [target]
    while path[path.count - 1] != start {
        path.append(parent[path[path.count - 1]]!)
    }
    return path.reversed()
}

let words = ["cold", "cord", "core", "card", "ward", "warm", "word", "worm", "wore",
             "lead", "load", "goad", "gold", "bold", "bolt"]
print(patterns(of: "cold"))
print(ladder(from: "cold", to: "warm", words: words))
print(ladder(from: "lead", to: "gold", words: words))
print(ladder(from: "bolt", to: "wore", words: words))
print(ladder(from: "cold", to: "cold", words: words))
print(ladder(from: "cold", to: "wolf", words: words))
