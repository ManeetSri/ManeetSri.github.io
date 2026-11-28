// Generated from src/dsa/content/lessons/swift-library/lib-swift-collections.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// What OrderedSet gives you, built from an Array and a Set
struct RecentSearches {
    private(set) var order: [String] = []
    private var members: Set<String> = []

    /// Adds the term at the end if it's new. Returns whether it was added. O(1) on average.
    mutating func append(_ term: String) -> Bool {
        guard members.insert(term).inserted else { return false }
        order.append(term)
        return true
    }

    func contains(_ term: String) -> Bool {
        members.contains(term)      // O(1), not a scan of `order`
    }
}

var searches = RecentSearches()
for term in ["swift", "heap", "swift", "deque", "heap", "bfs"] {
    print(term, searches.append(term))
}
print(searches.order)
print(searches.contains("deque"), searches.contains("trie"))
