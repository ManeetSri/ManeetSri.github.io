// Generated from src/dsa/content/lessons/capstones/cap-autocomplete.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// A trie whose every node remembers the best `k` words below it, so a query only walks the prefix.
/// Nodes live in arrays and refer to each other by index, as in "Index-based nodes vs class nodes".
struct Autocomplete {
    let k: Int
    private var children: [[Character: Int]] = [[:]]   // node 0 is the root: the empty prefix
    private var word: [String?] = [nil]                // the word ending at a node, if any
    private var frequency: [Int] = [0]
    private var top: [[Int]] = [[]]                    // word nodes in this subtree, best first, at most k
    var nodesVisited = 0                               // for comparing the two query strategies

    init(k: Int) {
        self.k = k
    }

    /// Higher frequency first; equal frequencies in alphabetical order, so results never depend on luck
    private func ranksAbove(_ a: Int, _ b: Int) -> Bool {
        frequency[a] != frequency[b] ? frequency[a] > frequency[b] : word[a]! < word[b]!
    }

    /// Adds `times` uses of `text`, then refreshes the cached lists on the path from the root
    mutating func record(_ text: String, times: Int = 1) {
        var path = [0]
        var node = 0
        for character in text {
            if let next = children[node][character] {
                node = next
            } else {
                children.append([:])
                word.append(nil)
                frequency.append(0)
                top.append([])
                children[node][character] = children.count - 1
                node = children.count - 1
            }
            path.append(node)
        }
        word[node] = text
        frequency[node] += times
        for ancestor in path {
            // Only this word's count changed, and it only went up, so it's the only word that can move
            var list = top[ancestor].filter { $0 != node }
            list.append(node)
            list.sort(by: ranksAbove)
            top[ancestor] = Array(list.prefix(k))
        }
    }

    private mutating func node(for prefix: String) -> Int? {
        var node = 0
        for character in prefix {
            nodesVisited += 1
            guard let next = children[node][character] else { return nil }
            node = next
        }
        return node
    }

    /// O(prefix length + k): read the cached list
    mutating func suggestions(for prefix: String) -> [String] {
        guard let start = node(for: prefix) else { return [] }
        return top[start].map { "\(word[$0]!) (\(frequency[$0]))" }
    }

    /// The slow way, for checking: visit the whole subtree, then sort what you found
    mutating func suggestionsBySearch(for prefix: String) -> [String] {
        guard let start = node(for: prefix) else { return [] }
        var found: [Int] = []
        var stack = [start]
        while let current = stack.popLast() {
            nodesVisited += 1
            if word[current] != nil { found.append(current) }
            stack.append(contentsOf: children[current].values)
        }
        return found.sorted(by: ranksAbove).prefix(k).map { "\(word[$0]!) (\(frequency[$0]))" }
    }
}

var engine = Autocomplete(k: 3)
let history = [("string", 60), ("swift", 50), ("struct", 45), ("swiftui", 40), ("static", 35),
               ("sweet", 30), ("switch", 25), ("state", 20), ("stride", 12), ("swim", 10), ("sword", 5)]
for (word, count) in history {
    engine.record(word, times: count)
}

for prefix in ["s", "sw", "swi", "str", "x"] {
    engine.nodesVisited = 0
    let fast = engine.suggestions(for: prefix)
    let fastCost = engine.nodesVisited
    engine.nodesVisited = 0
    let slow = engine.suggestionsBySearch(for: prefix)
    let shown = fast.isEmpty ? "nothing" : fast.joined(separator: ", ")
    print("\(prefix): \(shown)  [\(fastCost) vs \(engine.nodesVisited) nodes, \(fast == slow ? "same" : "DIFFERENT")]")
}

engine.record("sword", times: 48)          // the user keeps choosing "sword"
print("after 48 more swords:", engine.suggestions(for: "sw").joined(separator: ", "))
engine.record("swimming")                  // a brand-new word starts at 1
print("swim:", engine.suggestions(for: "swim").joined(separator: ", "))
