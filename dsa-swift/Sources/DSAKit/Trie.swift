// A trie (prefix tree) of Strings, built in M40 · "Build a Trie: insert, search, startsWith".
//
// Every node stands for one prefix: the root is the empty prefix, and the edge to a child adds one
// Character. A node stores its children in a dictionary keyed by Character, a flag saying whether
// a stored word ends there, and `passCount`: how many stored words pass through it (end at it or
// below it). Pass counts make `count(withPrefix:)` O(prefix length), and they make removal simple:
// walk down the word decrementing them, and the first node whose count reaches 0 heads a branch
// that no other word uses, so that whole branch is cut off at once.
//
// Why Character keys? A Character is one user-perceived character, so any Unicode text works:
// "café" has four, and "e" followed by a combining accent is the same Character as "é", so both
// spellings find the same word. A fixed array of 26 children would be faster for lowercase a–z
// only, and that trade-off is the subject of the lesson.
//
// Why a struct? DSAKit's types are values, like Array, so copying a Trie gives an independent trie.
// The nodes are class instances, because operations walk down with one variable and change nodes in
// place, and the struct guards them with copy-on-write: a copy shares the nodes until one of the two
// is changed, and the first change copies every node, O(number of nodes). Iterators keep the nodes
// alive and shared, so changing a trie while iterating over it is safe.

/// A set of Strings stored as a prefix tree: membership, prefix queries and sorted listings cost
/// time proportional to the length of the word or prefix, however many words are stored.
///
/// ```swift
/// var words: Trie = ["car", "cart", "cat", "dog"]
/// words.contains("car")             // true
/// words.hasPrefix("ca")             // true
/// words.count(withPrefix: "ca")     // 3
/// words.words(withPrefix: "car")    // ["car", "cart"]
/// words.remove("cart")              // true, and the node for "t" is pruned
/// ```
///
/// Words are compared Character by Character, so any Unicode text works, and canonically equivalent
/// spellings (a precomposed "é" or "e" plus a combining accent) are the same word. Iteration and
/// `words(withPrefix:)` list words in Character order, which is the same as `sorted()` for ASCII and
/// for letters like "é" that are one Unicode scalar; characters made of several scalars, such as an
/// emoji with a skin tone, can sort differently.
public struct Trie {
    /// One node: the prefix spelled by the path from the root to it.
    final class Node {
        var children: [Character: Node] = [:]
        /// True when a stored word ends at this node.
        var isWord = false
        /// How many stored words end at this node or below it.
        var passCount = 0

        init() {}

        /// Releases the subtree with a loop rather than recursion, so a word hundreds of thousands
        /// of characters long can't overflow the stack when its chain of nodes is freed.
        deinit {
            guard !children.isEmpty else { return }
            var pending = Array(children.values)
            children.removeAll()
            while var node = pending.popLast() {
                // Take the children only if nothing else (an iterator, say) still holds this node
                if isKnownUniquelyReferenced(&node) {
                    pending.append(contentsOf: node.children.values)
                    node.children.removeAll()
                }
            }
        }

        /// A deep copy of the subtree rooted here. Iterative, for the same reason as `deinit`.
        func deepCopy() -> Node {
            let copy = Node()
            var pending: [(original: Node, copy: Node)] = [(self, copy)]
            while let (original, clone) = pending.popLast() {
                clone.isWord = original.isWord
                clone.passCount = original.passCount
                for (character, child) in original.children {
                    let childCopy = Node()
                    clone.children[character] = childCopy
                    pending.append((child, childCopy))
                }
            }
            return copy
        }
    }

    private var root = Node()

    /// The number of nodes below the root: one per distinct non-empty prefix of the stored words.
    /// A measure of memory use. O(1).
    public private(set) var nodeCount = 0

    /// Creates an empty trie. O(1).
    public init() {}

    /// Creates a trie holding `words`. Duplicates are stored once. O(total length of the words).
    public init<S: Sequence>(_ words: S) where S.Element == String {
        for word in words {
            insert(word)
        }
    }

    /// The number of distinct words stored. O(1).
    public var count: Int {
        root.passCount
    }

    /// True when the trie holds no words. O(1).
    public var isEmpty: Bool {
        root.passCount == 0
    }

    /// Copies the nodes if another Trie value shares them, so changes stay private to this one.
    private mutating func makeUnique() {
        if !isKnownUniquelyReferenced(&root) {
            root = root.deepCopy()
        }
    }

    /// The node for `prefix`, or nil if no stored word starts with it. O(prefix length).
    private func node(for prefix: String) -> Node? {
        var node = root
        for character in prefix {
            guard let next = node.children[character] else { return nil }
            node = next
        }
        return node
    }

    /// Adds `word` and returns true, or returns false if it was already stored. The empty string is
    /// a valid word. O(word length).
    @discardableResult
    public mutating func insert(_ word: String) -> Bool {
        if contains(word) { return false }
        makeUnique()
        var node = root
        node.passCount += 1
        for character in word {
            if let next = node.children[character] {
                node = next
            } else {
                let next = Node()
                node.children[character] = next
                nodeCount += 1
                node = next
            }
            node.passCount += 1
        }
        node.isWord = true
        return true
    }

    /// True when `word` itself is stored (not merely a prefix of a stored word). O(word length).
    public func contains(_ word: String) -> Bool {
        node(for: word)?.isWord ?? false
    }

    /// True when at least one stored word starts with `prefix`. A word counts as a prefix of itself,
    /// and the empty prefix matches whenever the trie isn't empty. O(prefix length).
    public func hasPrefix(_ prefix: String) -> Bool {
        count(withPrefix: prefix) > 0
    }

    /// The number of stored words that start with `prefix`, including `prefix` itself if it's
    /// stored. O(prefix length), however many words match.
    public func count(withPrefix prefix: String) -> Int {
        node(for: prefix)?.passCount ?? 0
    }

    /// The stored words that start with `prefix`, in Character order (see the type's notes), at
    /// most `limit` of them: the first `limit` in that order. Autocomplete passes a small limit, so
    /// the walk stops early. O(prefix length + the nodes visited until `limit` words are found).
    public func words(withPrefix prefix: String, limit: Int = .max) -> [String] {
        guard limit > 0, let start = node(for: prefix), start.passCount > 0 else { return [] }
        var result: [String] = []
        result.reserveCapacity(Swift.min(limit, start.passCount))
        var iterator = Iterator(owner: root, start: start, prefix: prefix)
        while result.count < limit, let word = iterator.next() {
            result.append(word)
        }
        return result
    }

    /// Removes `word` and returns true, or returns false if it wasn't stored. Nodes that no other
    /// word uses are pruned, so `nodeCount` drops to what it would be had the word never been added.
    /// O(word length).
    @discardableResult
    public mutating func remove(_ word: String) -> Bool {
        guard contains(word) else { return false }
        makeUnique()
        let characters = Array(word)
        var node = root
        node.passCount -= 1
        if characters.isEmpty {
            node.isWord = false
            return true
        }
        for (depth, character) in characters.enumerated() {
            let child = node.children[character]!
            child.passCount -= 1
            if child.passCount == 0 {
                // No other word passes through child: drop it and everything below it, which is
                // exactly the rest of this word's path
                node.children[character] = nil
                nodeCount -= characters.count - depth
                return true
            }
            node = child
        }
        node.isWord = false
        return true
    }

    /// Removes every word. O(1), plus the time to free the nodes.
    public mutating func removeAll() {
        root = Node()
        nodeCount = 0
    }
}

extension Trie: Sequence {
    /// Walks the trie depth first, visiting children in Character order, and returns each word as
    /// it reaches the node where the word ends. A word comes before its longer extensions.
    public struct Iterator: IteratorProtocol {
        /// Keeps the trie's nodes alive and shared, so changing the trie copies them instead.
        private let owner: Node
        private var pending: [(node: Node, word: String)]

        init(owner: Node, start: Node, prefix: String) {
            self.owner = owner
            pending = [(start, prefix)]
        }

        /// The next word in Character order, or nil when every word has been returned. O(length of
        /// the word plus the children sorted on the way), O(total length) over a whole iteration.
        public mutating func next() -> String? {
            while let (node, word) = pending.popLast() {
                // Push children largest first, so the smallest is popped next
                for (character, child) in node.children.sorted(by: { $0.key > $1.key }) {
                    pending.append((child, word + String(character)))
                }
                if node.isWord {
                    return word
                }
            }
            return nil
        }
    }

    /// An iterator over every word, in Character order. O(1) to create.
    public func makeIterator() -> Iterator {
        Iterator(owner: root, start: root, prefix: "")
    }

    /// The number of words, so `Array(trie)` reserves exactly enough room. O(1).
    public var underestimatedCount: Int {
        count
    }
}

extension Trie: ExpressibleByArrayLiteral {
    /// Creates a trie from an array literal of words. O(total length of the words).
    public init(arrayLiteral words: String...) {
        self.init(words)
    }
}

extension Trie: CustomStringConvertible {
    /// The words in Character order, for example `Trie(["car", "cat"])`. O(total length).
    public var description: String {
        "Trie(\(Array(self)))"
    }
}

extension Trie: Equatable {
    /// Two tries are equal when they store the same words. O(total length).
    public static func == (lhs: Trie, rhs: Trie) -> Bool {
        lhs.count == rhs.count && lhs.elementsEqual(rhs)
    }
}
