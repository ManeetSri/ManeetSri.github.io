// Generated from src/dsa/content/lessons/design-structures/ds-autocomplete.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    var children: [Character: Node] = [:]
    var count = 0                                      // searches of the phrase ending here (0: none)
    var best: [(phrase: String, count: Int)] = []      // cached top k below this node, best first
}

final class Autocomplete {
    private let root = Node()
    private let k: Int
    var nodesVisited = 0

    init(k: Int) {
        self.k = k
    }

    private func ranksHigher(_ a: (phrase: String, count: Int), _ b: (phrase: String, count: Int)) -> Bool {
        a.count != b.count ? a.count > b.count : a.phrase < b.phrase
    }

    /// Adds searches of `phrase`, then refreshes the cache on every node of its path.
    func record(_ phrase: String, times: Int = 1) {
        var node = root
        var path = [root]
        for character in phrase {
            if node.children[character] == nil {
                node.children[character] = Node()
            }
            node = node.children[character]!
            path.append(node)
        }
        node.count += times
        for step in path {
            step.best.removeAll { $0.phrase == phrase }      // at most k entries: cheap
            step.best.append((phrase, node.count))
            step.best.sort(by: ranksHigher)
            if step.best.count > k {
                step.best.removeLast()
            }
        }
    }

    private func node(for prefix: String) -> Node? {
        var node = root
        for character in prefix {
            guard let next = node.children[character] else { return nil }
            node = next
        }
        return node
    }

    /// Design A: collect every phrase below the prefix, sort, keep k
    func collected(_ prefix: String) -> [String] {
        guard let start = node(for: prefix) else { return [] }
        var found: [(phrase: String, count: Int)] = []
        var stack = [(node: start, text: prefix)]
        while let (current, text) = stack.popLast() {
            nodesVisited += 1
            if current.count > 0 {
                found.append((text, current.count))
            }
            for (character, child) in current.children {
                stack.append((child, text + String(character)))
            }
        }
        found.sort(by: ranksHigher)
        return found.prefix(k).map(\.phrase)
    }

    /// Design B: the answer is already cached at the prefix's node
    func cached(_ prefix: String) -> [String] {
        nodesVisited += 1
        return node(for: prefix)?.best.map(\.phrase) ?? []
    }
}

let history = ["swift": 50, "swiftui": 90, "switch": 20, "sweater": 50, "struct": 70,
               "string": 65, "stride": 15, "set": 40, "sort": 55, "sorted": 30, "stack": 45]
let search = Autocomplete(k: 3)
for phrase in history.keys.sorted() {
    search.record(phrase, times: history[phrase]!)
}

for prefix in ["s", "sw", "st"] {
    search.nodesVisited = 0
    let a = search.collected(prefix)
    let visitedA = search.nodesVisited
    search.nodesVisited = 0
    let b = search.cached(prefix)
    print(prefix, a, "visited \(visitedA);", b == a ? "cache agrees" : "cache differs")
}

search.record("switch", times: 31)                     // switch: 20 + 31 = 51
print(search.cached("sw"), search.cached("swi"), search.cached("x"))
