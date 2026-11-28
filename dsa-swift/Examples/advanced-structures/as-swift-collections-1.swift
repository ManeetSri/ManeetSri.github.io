// Generated from src/dsa/content/lessons/advanced-structures/as-swift-collections.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The idea behind OrderedSet: an array for the order, plus a dictionary from element to index
struct TinyOrderedSet<Element: Hashable> {
    private(set) var elements: [Element] = []
    private var indexOf: [Element: Int] = [:]

    // Like OrderedSet.append: adds at the end unless it's already there, and says where it is
    @discardableResult
    mutating func append(_ element: Element) -> (inserted: Bool, index: Int) {
        if let index = indexOf[element] { return (false, index) }
        indexOf[element] = elements.count
        elements.append(element)
        return (true, elements.count - 1)
    }

    func contains(_ element: Element) -> Bool {
        indexOf[element] != nil                  // O(1): a dictionary lookup, not a scan
    }

    func firstIndex(of element: Element) -> Int? {
        indexOf[element]
    }

    // O(n): everything after the removed element moves down, and its stored index must too
    @discardableResult
    mutating func remove(_ element: Element) -> Element? {
        guard let index = indexOf.removeValue(forKey: element) else { return nil }
        elements.remove(at: index)
        for i in index..<elements.count {
            indexOf[elements[i]] = i
        }
        return element
    }
}

// Recent searches: no duplicates, oldest first
var recent = TinyOrderedSet<String>()
for query in ["heap", "trie", "swift", "heap", "graph"] {
    let result = recent.append(query)
    print(query, result.inserted ? "added at \(result.index)" : "already at \(result.index)")
}
print(recent.elements, recent.contains("trie"), recent.firstIndex(of: "graph")!)
recent.remove("trie")
print(recent.elements, recent.firstIndex(of: "graph")!)
