// Reference solution: Count distinct substrings. Every substring is a prefix of some suffix, so insert
// every suffix into a trie (a suffix trie): each node then stands for exactly one distinct non-empty
// substring, and the answer is the number of nodes created. The trie lives in one flat array, 26
// child slots per node, with 0 meaning "no child"; it's allocated up front for the worst case of
// n(n + 1)/2 nodes. O(n²) time and O(n²) space, which is why this only suits small inputs: suffix
// arrays and suffix automata do the same job in O(n log n) or O(n).

public enum DistinctSubstringCount {
    public static func count(in text: String) -> Int {
        let letters = Array(text.utf8)
        let n = letters.count
        var children = [Int32](repeating: 0, count: 26 * (n * (n + 1) / 2 + 1))
        var nodes = 0
        for start in 0..<n {
            var node = 0                                        // the root
            for index in start..<n {
                let slot = 26 * node + Int(letters[index] - 97)
                if children[slot] == 0 {
                    nodes += 1                                  // a substring never seen before
                    children[slot] = Int32(nodes)
                }
                node = Int(children[slot])
            }
        }
        return nodes
    }
}
