// Generated from src/dsa/content/lessons/linear-sorts/sort-bucket.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func topFrequent(_ words: [String], k: Int) -> [String] {
    var counts: [String: Int] = [:]
    var firstSeen: [String] = []                 // each word once, in order of first appearance
    for word in words {
        if counts[word] == nil { firstSeen.append(word) }
        counts[word, default: 0] += 1
    }
    // buckets[f] holds the words that appear exactly f times
    var buckets = [[String]](repeating: [], count: words.count + 1)
    for word in firstSeen {
        buckets[counts[word]!].append(word)
    }
    var result: [String] = []
    for frequency in stride(from: words.count, through: 1, by: -1) {
        for word in buckets[frequency] where result.count < k {
            result.append(word)
        }
    }
    return result
}

let tags = ["swift", "ios", "swift", "dsa", "ios", "swift", "ui", "dsa", "ios"]
print(topFrequent(tags, k: 2))
print(topFrequent(tags, k: 3))
