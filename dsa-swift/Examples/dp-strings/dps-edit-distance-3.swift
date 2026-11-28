// Generated from src/dsa/content/lessons/dp-strings/dps-edit-distance.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Edit distance with two rows. Returns nil as soon as every cell in a row is above `limit`,
/// because no later row can dip below this row's smallest value.
func distance(_ first: String, _ second: String, limit: Int) -> Int? {
    let a = Array(first), b = Array(second)
    var previous = Array(0...b.count)                 // row 0: j insertions
    var current = previous
    for i in stride(from: 1, through: a.count, by: 1) {
        current[0] = i
        for j in stride(from: 1, through: b.count, by: 1) {
            if a[i - 1] == b[j - 1] {
                current[j] = previous[j - 1]
            } else {
                current[j] = 1 + min(previous[j - 1], previous[j], current[j - 1])
            }
        }
        if current.min()! > limit {
            return nil                                // too far already: give up on this word
        }
        swap(&previous, &current)
    }
    return previous[b.count] <= limit ? previous[b.count] : nil
}

func suggestions(for typo: String, from words: [String], limit: Int) -> [String] {
    let scored = words.compactMap { word in
        distance(typo, word, limit: limit).map { (word, $0) }
    }
    return scored.sorted { ($0.1, $0.0) < ($1.1, $1.0) }.map { "\($0.0) (\($0.1))" }
}

let words = ["spelling", "spell", "spilling", "selling", "sapling", "swelling", "peeling", "spring", "swift"]
print(suggestions(for: "speling", from: words, limit: 2))
print(suggestions(for: "swfit", from: words, limit: 2))
