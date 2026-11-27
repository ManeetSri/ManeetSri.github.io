// Generated from src/dsa/content/lessons/capstones/cap-spell-checker.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Levenshtein distance with two rows: insertions, deletions and replacements each cost 1
func editDistance(_ a: [Character], _ b: [Character]) -> Int {
    var previous = Array(0...b.count)
    var current = previous
    for i in stride(from: 1, through: a.count, by: 1) {
        current[0] = i
        for j in stride(from: 1, through: b.count, by: 1) {
            current[j] = a[i - 1] == b[j - 1]
                ? previous[j - 1]
                : 1 + min(previous[j - 1], previous[j], current[j - 1])
        }
        swap(&previous, &current)
    }
    return previous[b.count]
}

/// A BK-tree: each child hangs off its parent on an edge labelled with their distance.
/// Nodes live in arrays and point to each other by index.
struct BKTree {
    private var words: [[Character]] = []
    private var children: [[Int: Int]] = []        // edge distance -> child node
    private(set) var distancesComputed = 0

    var count: Int { words.count }

    mutating func insert(_ word: String) {
        let letters = Array(word)
        guard !words.isEmpty else {
            words.append(letters)
            children.append([:])
            return
        }
        var node = 0
        while true {
            let d = editDistance(letters, words[node])
            if d == 0 { return }                         // already stored
            if let child = children[node][d] {
                node = child                             // follow the edge with the same distance
            } else {
                words.append(letters)
                children.append([:])
                children[node][d] = words.count - 1
                return
            }
        }
    }

    /// Every stored word within `tolerance` edits of `query`
    mutating func search(_ query: String, tolerance: Int) -> [(word: String, distance: Int)] {
        guard !words.isEmpty else { return [] }
        let letters = Array(query)
        var found: [(word: String, distance: Int)] = []
        var stack = [0]
        while let node = stack.popLast() {
            let d = editDistance(letters, words[node])
            distancesComputed += 1
            if d <= tolerance {
                found.append((String(words[node]), d))
            }
            // Triangle inequality: a match under a child on edge e has |e - d| <= tolerance
            for (edge, child) in children[node] where abs(edge - d) <= tolerance {
                stack.append(child)
            }
        }
        return found
    }
}

let frequency = [
    "the": 5000, "would": 1500, "they": 1800, "then": 2000, "them": 900, "these": 700, "three": 400,
    "ten": 300, "tea": 150, "help": 500, "held": 200, "hello": 120, "hell": 60, "yellow": 90,
    "spring": 110, "string": 130, "shift": 140, "swift": 60, "spell": 70, "spelling": 40, "selling": 80,
    "swelling": 15, "spilling": 10, "work": 900, "world": 700, "word": 600, "wood": 160, "lord": 45,
    "ward": 35, "sword": 30,
]

var tree = BKTree()
for word in frequency.keys.sorted() {
    tree.insert(word)
}

/// Closest first; among equal distances, the more common word first; then alphabetical
func suggestions(for typo: String, limit: Int = 3) -> String {
    let before = tree.distancesComputed
    let ranked = tree.search(typo, tolerance: 2).sorted {
        ($0.distance, -frequency[$0.word]!, $0.word) < ($1.distance, -frequency[$1.word]!, $1.word)
    }
    let shown = ranked.prefix(limit).map { "\($0.word) (\($0.distance))" }.joined(separator: ", ")
    return "\(typo): \(shown)  [\(tree.distancesComputed - before) of \(tree.count) distances]"
}

for typo in ["teh", "helo", "speling", "wrod", "swfit", "thier"] {
    print(suggestions(for: typo))
}
