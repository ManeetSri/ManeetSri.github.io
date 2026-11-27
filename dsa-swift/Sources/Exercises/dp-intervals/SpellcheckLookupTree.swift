// Problem: The cheapest lookup tree (M56 · Optimal BST)

public enum SpellcheckLookupTree {
    /// A BST holds n sorted keys. Key i is searched `hits[i]` times, and `misses[g]` searches look for
    /// a word that isn't there and falls in gap g: before key 0 (g = 0), between keys g - 1 and g, or
    /// after the last key (g = n). A search costs one comparison per key it visits, counting the root,
    /// so finding a key at depth d costs d and a miss costs the depth of the last key it compared
    /// with. Returns the smallest total cost of any BST over the keys.
    public static func cheapestCost(hits: [Int], misses: [Int]) -> Int {
        // Write your solution here, then run:
        // swift test --filter SpellcheckLookupTreeTests
        return -1
    }
}
