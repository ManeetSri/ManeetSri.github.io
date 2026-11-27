// Generated from src/dsa/content/lessons/mock-practice/mock-mistakes-review.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let notes = [
    "[edge] empty array crashed the 1..<n loop",
    "[off-by-one] window shrank one step too far; [swift] used removeFirst in BFS",
    "[edge] forgot a tree with a single node",
    "[pattern] tried a sliding window with negative numbers",
    "[edge] counted duplicates twice",
]

// Count every [tag] in every note
var counts: [String: Int] = [:]
for note in notes {
    var rest = Substring(note)
    while let open = rest.firstIndex(of: "["), let close = rest[open...].firstIndex(of: "]") {
        let tag = String(rest[rest.index(after: open)..<close])
        counts[tag, default: 0] += 1
        rest = rest[rest.index(after: close)...]
    }
}

// Most frequent first; ties alphabetical, so the order is always the same
let ranked = counts.sorted { $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key }
for (tag, count) in ranked {
    print(tag, count)
}
