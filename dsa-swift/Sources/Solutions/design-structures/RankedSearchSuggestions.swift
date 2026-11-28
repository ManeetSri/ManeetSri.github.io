// Reference solution: Ranked search suggestions. A trie of the phrases where every node caches the
// best `limit` phrases below it, with their counts, best first. Typing a character is one step down
// from the current node, and the answer is already there: O(1) per keystroke, plus copying at most
// `limit` strings. Counts only ever go up, so a submit only has to offer the submitted phrase to the
// caches on its own path: O(L × limit log limit) for a phrase of length L.

public enum RankedSearchSuggestions {
    public final class Engine {
        private final class Node {
            var children: [Character: Node] = [:]
            var best: [(phrase: String, count: Int)] = []     // at most `limit`, best first
        }

        private let limit: Int
        private let root = Node()
        private var counts: [String: Int] = [:]
        private var typed = ""
        private var current: Node?                 // the node for `typed`, or nil if nothing matches

        public init(history: [String: Int], limit: Int = 3) {
            precondition(limit > 0, "Show at least one suggestion")
            self.limit = limit
            for (phrase, count) in history where !phrase.isEmpty && count > 0 {
                add(count, to: phrase)
            }
            current = root
        }

        public var query: String {
            typed
        }

        public func type(_ character: Character) -> [String] {
            typed.append(character)
            current = current?.children[character]         // nil stays nil: no phrase matches
            return current?.best.map(\.phrase) ?? []
        }

        public func submit() {
            guard !typed.isEmpty else { return }
            add(1, to: typed)
            clear()
        }

        public func clear() {
            typed = ""
            current = root
        }

        public func suggestions(for prefix: String) -> [String] {
            var node = root
            for character in prefix {
                guard let next = node.children[character] else { return [] }
                node = next
            }
            return node.best.map(\.phrase)
        }

        /// Raises the phrase's count, then offers it to every cache on its path, creating nodes.
        private func add(_ amount: Int, to phrase: String) {
            counts[phrase, default: 0] += amount
            let count = counts[phrase]!
            var node = root
            offer(phrase, count, to: node)
            for character in phrase {
                if let next = node.children[character] {
                    node = next
                } else {
                    let made = Node()
                    node.children[character] = made
                    node = made
                }
                offer(phrase, count, to: node)
            }
        }

        /// Only this phrase's count changed, and only upwards, so the rest of the cache keeps its
        /// order: update or add it, re-sort the few entries, and drop the worst if there are too many.
        private func offer(_ phrase: String, _ count: Int, to node: Node) {
            if let index = node.best.firstIndex(where: { $0.phrase == phrase }) {
                node.best[index].count = count
            } else {
                node.best.append((phrase, count))
            }
            node.best.sort { $0.count != $1.count ? $0.count > $1.count : $0.phrase < $1.phrase }
            if node.best.count > limit {
                node.best.removeLast()
            }
        }
    }
}
